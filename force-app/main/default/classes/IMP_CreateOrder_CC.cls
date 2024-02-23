/************************************************************************
Name: IMP_CreateOrder_CC
Copyright © 2022 Salesforce
========================================================================
Purpose:
Clase controller que crea un pedido a partir de las partidas de
oportunidad 
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
 2.0      mvilchis@ts4.mx    29/03/2022     
************************************************************************/
public with sharing class IMP_CreateOrder_CC {
   /*******************************************************************
   Purpose: Valida si existen partidas asociadas para crear un pedido
   de lo contrario regresa un mensaje de error.
   Parameters: String oppRec
   Returns: String
   Throws [Exceptions]:
   Information about changes (versions) []:
   ********************************************************************/
    @AuraEnabled
    public static String getOpportunity(String oppRec) {
        String idOrder;
        Opportunity opp =[SELECT Id,StageName,AccountId,Account.grupo__c, Account.clave_delcanal__c, CloseDate,Pricebook2Id,SyncedQuoteId FROM Opportunity WHERE Id =: oppRec ];
        list<OpportunityLineItem> lstOppL = [SELECT Id
                                        , OpportunityId,Product2.Grupo_de_Materiales__c
                                        , TotalPrice, UnitPrice, Quantity, PricebookEntryId, Product2Id,
                                        ProductCode, Opportunity.AccountId, DescuentoAdicional__c,
                                        IMP_DescuentoPromo__c, DescuentoSAP__c, IMP_OmitirDescuentoSAP__c,
                                        Opportunity.Pricebook2.Sucursal__c, Opportunity.Account.grupo__c
                                        , Product2.Lista_precios__c, Product2.Grupo_de_art_culos__c
                                        FROM OpportunityLineItem WHERE OpportunityId =:oppRec];
        if(lstOppL.size() > 0) {
            idOrder=createdOrder(lstOppL, opp);
        }
        else {
            throw new AuraHandledException('No puede crear un pedido, no tiene partidas asociadas');
        }
        return [SELECT Id, OrderNumber FROM Order WHERE Id=:idOrder].OrderNumber;
    }
    /*******************************************************************
    Purpose: Inserta el pedido a partir de la información de la oportunidad.
    Parameters: List<OpportunityLineItem> lstOppItem, Opportunity opp
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    private static String createdOrder(List<OpportunityLineItem> lstOppItem, Opportunity opp) {
        Order prodOrder = new Order (AccountId = opp.AccountId, Status = 'Draft', OpportunityId = opp.Id,
                                    EffectiveDate = opp.CloseDate,Pricebook2Id = opp.Pricebook2Id);
        insert prodOrder;
        createdOrderItem(lstOppItem, opp, prodOrder.Id);
        return prodOrder.Id;
    }
    /*******************************************************************
    Purpose: Crea las partidas del pedido
    Parameters: List<OpportunityLineItem> lstOppItem,String pedidoId
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    private static void createdOrderItem (List<OpportunityLineItem> lstOppItem,Opportunity opor,  String pedidoId) {
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        List<String> lstOpp = new List<String>();
        Map<String,Id> mapOrdOpp = new Map<String,Id>();
        String grupoClientePromo = '';
        String CanalPromocion = '';
        
        try {
            Map<String,Decimal> mapDescuentos = getDiscounts(lstOppItem,pedidoId);
            Map<String,Descuento__c> mapDescuentosPromo = getDiscountsPromo(opor, lstOppItem);
            grupoClientePromo = System.label.IMP_GrupoClientePromo;
            CanalPromocion = System.label.IMP_CanalPromo;

            for(OpportunityLineItem oppl : lstOppItem) {
                OrderItem prodOrderItem = new OrderItem (
                    UnitPrice = oppl.UnitPrice,Quantity = oppl.Quantity,OrderId = pedidoId,
                    PricebookEntryId = oppl.PricebookEntryId,DescuentoSAP__c= mapDescuentos.get(oppl.Id),
                    Product2Id = oppl.Product2Id , DescuentoManual__c =oppl.DescuentoAdicional__c 
                    );

                if(mapDescuentosPromo.containsKey(oppl.Id)){
                    Descuento__c descuento = mapDescuentosPromo.get(oppl.Id);
                    
                    if(opor.Account.clave_delcanal__c == CanalPromocion && opor.Account.grupo__c == grupoClientePromo){
                        prodOrderItem.DescuentoSAP__c = 0;
                        prodOrderItem.IMP_OmitirDescuentoSAP__c = true;
                    }
                    prodOrderItem.IMP_DescuentoPromo__c = descuento.IMP_ImportePorcentaje__c;
                    prodOrderItem.IMP_Descuento__c = descuento.Id;
                }
                lstOrderItem.add(prodOrderItem);
            }
            insert lstOrderItem;

        }
        catch(DmlException e) {
            AuraHandledException errorAura = new AuraHandledException('');
            errorAura.setMessage(e.getMessage());
            throw errorAura;
        }
    }
    /*******************************************************************
    Purpose: Obtiene los descuentos de cada producto
    Parameters: List<OpportunityLineItem> listaProds,String pedidoId
    Returns: Map<String,Decimal> 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    private static Map<String,Decimal> getDiscounts(List<OpportunityLineItem> listaProds,String pedidoId){
        Map<String,PoliticaDescuento__c> mapDescuentos = new  Map<String,PoliticaDescuento__c> ();
        Map<String,Decimal> mapReturn = new  Map<String,Decimal>();
        Order pedido = [SELECT Id, AccountId,Account.Clave_delcanal__c,Account.Grupo__c FROM Order WHERE Id =: pedidoId];

        for(PoliticaDescuento__c politicaDesc : [SELECT Id,Activa__c,Canaldistribucion__c,GrupoProducto__c, Descuento__c,Grupo_de_cliente_del__c
                                                 FROM PoliticaDescuento__c WHERE Activa__c = true AND Canaldistribucion__c =:pedido.Account.Clave_delcanal__c
                                                 AND Grupo_de_cliente_del__c =:pedido.Account.Grupo__c])
        {
            mapDescuentos.put(politicaDesc.GrupoProducto__c, politicaDesc) ;  
        }
        for(OpportunityLineItem prodOppor: listaProds){
            mapReturn.put(prodOppor.Id,mapDescuentos.containsKey(prodOppor.Product2.Grupo_de_Materiales__c)? mapDescuentos.get(prodOppor.Product2.Grupo_de_Materiales__c).Descuento__c : 0);
        }
        return mapReturn;
    }
    /*******************************************************************
    Purpose: Obtiene los descuentos de promoción de cada producto
    Parameters: List<OpportunityLineItem> listaProds,String pedidoId
    Returns: Map<String,Decimal> 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    private static Map<String,Descuento__c> getDiscountsPromo(Opportunity opor, List<OpportunityLineItem> listLineOpp){
        Map<String,Descuento__c> mapDescuentos = new  Map<String ,Descuento__c> ();
        List<QuoteLineItem> listaProds = new List<QuoteLineItem>();
        Decimal PrecioTotalDescuentos = 0;
       

        Quote cot = [SELECT Id, isSyncing, Account.grupo__c, Account.clave_delcanal__c
        , Account.OrganizacionVentas__c
        , Account.id_de_sap__c
        , Account.centro_suministrador__c
        , Pricebook2.Lista_de_precios_SAP__c
        ,Requiereaprobacion__c,Pricebook2.Sucursal__c 
        FROM Quote WHERE Id =:opor.SyncedQuoteId];

        Descuento__c descuentoPromo = new Descuento__c();
        IMP_DescuentosManager.WrapperSecuences DiscountsBySecuence = new IMP_DescuentosManager.WrapperSecuences();
        IMP_DescuentosManager.WrapperSecuencesParam param = new IMP_DescuentosManager.WrapperSecuencesParam();
        
        DiscountsBySecuence = IMP_DescuentosManager.getDiscountByQuote(cot);
        
        for(OpportunityLineItem oLineItem: listLineOpp){
            param.OrgVentas = cot.Account.OrganizacionVentas__c;
            param.canalVentas = cot.Account.clave_delcanal__c;
            param.numeroCliente = cot.Account.id_de_sap__c;
            param.numeroMaterial = oLineItem.ProductCode;
            param.OficinaVentas = cot.Pricebook2.Sucursal__c; //Account.centro_suministrador__c , pedido.Pricebook2.Sucursal__c
            param.ListaPrecios = cot.Pricebook2.Lista_de_precios_SAP__c;//cot.Account.Grupo_de_precios__c; 03 Mostrador, 04 Distribuidores, Account.ListaPrecios__c = 03 Mostrador, 04 Distribuidores
            param.GrupoMateriales = oLineItem.Product2.Grupo_de_Materiales__c;
            param.GrupoArticulos = oLineItem.Product2.Grupo_de_art_culos__c;
            param.GrupoClientes = cot.Account.grupo__c;
            param.ClaseDoc = System.label.IMP_ClasePedido;
          
            System.debug('Parametros usados en trigger');
            System.debug(param);

            descuentoPromo = IMP_DescuentosManager.getDiscountByToApply(param, DiscountsBySecuence);
            if(descuentoPromo != null){
                if(descuentoPromo.IMP_ImportePorcentaje__c > 0){
                    mapDescuentos.put(oLineItem.Id, descuentoPromo);
                }
            }
        }

        
        return mapDescuentos;
    }
    
}