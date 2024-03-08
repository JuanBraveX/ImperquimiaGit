/************************************************************************
Name: IMP_HandleDescuentos
Copyright © 2023 Salesforce
========================================================================
Purpose:
Aplica los descuentos a la partida de la cotización
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
3.0      rotrejo@ts4.mx     11/05/2023     
************************************************************************/
public inherited sharing class IMP_HandleDescuentos {
    
    /*******************************************************************
    Purpose: Aplica descuentos a la partida de cotización
    Parameters: List<QuoteLineItem> listOrderItem
    Returns: 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static void applyDiscounts(List<QuoteLineItem> listOrderItem){
        
        Quote quote = [SELECT Id,Account.clave_delcanal__c, Account.id_de_sap__c,Account.OrganizacionVentas__c,
                       Pricebook2.Sucursal__c,Pricebook2.Lista_de_precios_SAP__c,Account.grupo__c
                       FROM Quote WHERE Id=: listOrderItem[0].QuoteId];
        set<Id> setProdIds = new set<Id>();
        set<Id> setPbeIds = new set<Id>();
        for(QuoteLineItem quoteLineItem : listOrderItem){
            setProdIds.add(quoteLineItem.Product2Id);
            setPbeIds.add(quoteLineItem.PricebookEntryId);
        }
        Map<Id,PricebookEntry> mapPbe = new Map<Id,PricebookEntry>([SELECT Id,Product2.Grupo_de_art_culos__c,UnitPrice,Product2.Grupo_de_Materiales__c,Product2.ProductCode FROM PricebookEntry WHERE Id IN:setPbeIds]);
        Map<String,PoliticaDescuento__c> mapPoliticas =  getDiscountPolitica(quote);
        IMP_DescuentosManager.WrapperSecuences mapSecuences = IMP_DescuentosManager.getDiscountByQuote(quote);
        String grupoClientePromo = System.label.IMP_GrupoClientePromo;

        for(QuoteLineItem quoteLineItem : listOrderItem){
            
            Descuento__c descuentoPromo = getDiscountByLineItem(quoteLineItem,quote,mapSecuences,mapPbe);
            Decimal PrecioTotalDescuentos =  mapPbe.get(quoteLineItem.PricebookEntryId).UnitPrice *  quoteLineItem.Quantity;
            PoliticaDescuento__c politica = new PoliticaDescuento__c();
            String grupoMateriales = mapPbe.get(quoteLineItem.PricebookEntryId).Product2.Grupo_de_Materiales__c;
            politica = mapPoliticas.ContainsKey(quote.Account.clave_delcanal__c+quote.Account.grupo__c+grupoMateriales) ? mapPoliticas.get(quote.Account.clave_delcanal__c+quote.Account.grupo__c+grupoMateriales):null ;
            
            PrecioTotalDescuentos = politica!= null ?PrecioTotalDescuentos - (PrecioTotalDescuentos * (politica.Descuento__c  / 100)):PrecioTotalDescuentos ;
            quoteLineItem.Discount = politica!= null ? politica.Descuento__c : 0;
            quoteLineItem.DescuentoSAP__c = politica!= null ? politica.Descuento__c : 0;
            quoteLineItem.PoliticaDescuento__c =  politica!= null ? politica.Id : null;

            if(descuentoPromo != null){
                
                if(descuentoPromo.IMP_ImportePorcentaje__c > 0){
                    
                    if(quote.Account.clave_delcanal__c == System.label.IMP_CanalPromo && quote.Account.grupo__c == grupoClientePromo){
                        PrecioTotalDescuentos =  mapPbe.get(quoteLineItem.PricebookEntryId).UnitPrice * quoteLineItem.Quantity;
                        quoteLineItem.DescuentoSAP__c = 0;
                        quoteLineItem.Discount = 0;
                        quoteLineItem.IMP_OmitirDescuentoSAP__c = true;
                        quoteLineItem.PrecioTotalConDescuentos__c = PrecioTotalDescuentos;
                    }
                    quoteLineItem.IMP_DescuentoPromo__c = descuentoPromo.IMP_ImportePorcentaje__c;
                    quoteLineItem.IMP_Descuento__c = descuentoPromo.Id;
                    if(descuentoPromo.IMP_UnidadCondicion__c.trim() == '%'){
                        PrecioTotalDescuentos =  PrecioTotalDescuentos - (PrecioTotalDescuentos * (descuentoPromo.IMP_ImportePorcentaje__c  / 100));
                        System.debug('PRECIO TOTAL DESCUENTOS::'+PrecioTotalDescuentos);
                    }
                    else {
                        PrecioTotalDescuentos = PrecioTotalDescuentos - descuentoPromo.IMP_ImportePorcentaje__c;
                    }
                  
                }
            }
            quoteLineItem.PrecioTotalConDescuentos__c = PrecioTotalDescuentos;
        }
    }
    
    /*******************************************************************
    Purpose: Obtiene el descuento Temporal por partida
    Parameters: List<QuoteLineItem> listOrderItem
    Returns: 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static Descuento__c getDiscountByLineItem(QuoteLineItem quoteLineItem, Quote quote,IMP_DescuentosManager.WrapperSecuences mapSecuences,Map<Id,PricebookEntry> mapProducts){
       System.debug('getDiscountByLineItem');
        Descuento__c descuentoPromo = new Descuento__c();
        IMP_DescuentosManager.WrapperSecuencesParam param = new IMP_DescuentosManager.WrapperSecuencesParam();
        param.OrgVentas = quote.Account.OrganizacionVentas__c;
        param.canalVentas = quote.Account.clave_delcanal__c;
        param.numeroCliente = quote.Account.id_de_sap__c;
        param.numeroMaterial = mapProducts.containsKey(quoteLineItem.PricebookEntryId) ? mapProducts.get(quoteLineItem.PricebookEntryId).Product2.ProductCode : '';
        param.OficinaVentas = quote.PriceBook2.Sucursal__c;
        param.ListaPrecios = quote.Pricebook2.Lista_de_precios_SAP__c;
        param.GrupoMateriales = mapProducts.containsKey(quoteLineItem.PricebookEntryId) ? mapProducts.get(quoteLineItem.PricebookEntryId).Product2.Grupo_de_Materiales__c : '';
        param.GrupoArticulos = mapProducts.containsKey(quoteLineItem.PricebookEntryId) ? mapProducts.get(quoteLineItem.PricebookEntryId).Product2.Grupo_de_art_culos__c : '';
        param.GrupoClientes = quote.Account.grupo__c;
        param.ClaseDoc = System.label.IMP_ClasePedido;
        param.CanalPromocion = System.label.IMP_CanalPromo;
        descuentoPromo =  IMP_DescuentosManager.getDiscountByToApply(param, mapSecuences);
        return descuentoPromo;
        
    }
    
    /*******************************************************************
    Purpose: Aplica el descuento por politica a la partida de cotización
    Parameters: List<QuoteLineItem> listOrderItem
    Returns: 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static Map<String,PoliticaDescuento__c> getDiscountPolitica(Quote quote){
        Map<String,PoliticaDescuento__c> mapPoliticas = new  Map<String,PoliticaDescuento__c>();
        for(PoliticaDescuento__c politica : [SELECT Id,Activa__c,Canaldistribucion__c, GrupoProducto__c,Descuento__c,Grupo_de_cliente_del__c
                                                        FROM PoliticaDescuento__c WHERE Activa__c = true AND Canaldistribucion__c =:quote.Account.clave_delcanal__c
                                                        AND Grupo_de_cliente_del__c =:quote.Account.grupo__c]){
         mapPoliticas.put(politica.Canaldistribucion__c+politica.Grupo_de_cliente_del__c+politica.GrupoProducto__c,politica);
        }
        return mapPoliticas;
    }
    
}