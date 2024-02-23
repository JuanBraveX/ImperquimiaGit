/*************************************************************** 
Name: IMP_OpportunityTrigger
Copyright © 2021 Salesforce
======================================================
Purpose:
Class trigger Opportunity.
======================================================
History:
Modification
VERSION  AUTHOR           DATE          DETAIL     Description
3.0      dmarcos@ts4.mx    20/03/2022    INITIAL     DEV CSR: 
4.0.     rortega@ts4.mx	   04/05/2023    Se agregó descuentos por promociones
***************************************************************/
trigger IMP_OpportunityTrigger on Opportunity (after update) {
    List<OpportunityLineItem> lstOppL = new List<OpportunityLineItem>();
    List<Opportunity> lstOpp = new List<Opportunity>();
    set<Id> IdOwnerOpp = new set<Id>();
    Set<Id> idsQuote = new Set<Id>();
        
    if(trigger.IsUpdate && trigger.IsAfter) {
        for(Opportunity opp : trigger.new) {
            lstOpp.add(opp);
            idsQuote.add(opp.SyncedQuoteId );
            IdOwnerOpp.add(opp.OwnerId);
        }
        
        getMontosOpp(IdOwnerOpp);

        for(OpportunityLineItem oppL : [SELECT Id,OpportunityId,TotalPrice,UnitPrice,Quantity,PricebookEntryId,Product2Id,
                                        ProductCode,Opportunity.AccountId, Opportunity.Pricebook2.Sucursal__c
                                        , Opportunity.Account.grupo__c
                                        , Product2.Lista_precios__c, Product2.Grupo_de_Materiales__c
                                        , Product2.Grupo_de_art_culos__c
                                        , IMP_OmitirDescuentoSAP__c
                                        FROM OpportunityLineItem WHERE OpportunityId IN : lstOpp]) {
                                            lstOppL.add(oppL);
                                        }

        Map<String,Decimal> mapDescuentos = getDiscountsManuales(idsQuote,lstOpp[0].Id);
        Map<String,Decimal> mapDescuentosSAP = getDiscountsSAP(idsQuote,lstOpp[0].Id);
        Map<Id,OpportunityLineItem> mapDescuentosPromo = getDiscountsPromo(lstOpp[0], lstOppL);

        map<Id,OpportunityLineItem> mapOpportunityLine=new map<Id,OpportunityLineItem>([SELECT Id,OpportunityId,TotalPrice,UnitPrice,Quantity,PricebookEntryId,Product2Id,
                                                                                        ProductCode,Opportunity.AccountId,DescuentoAdicional__c, IMP_DescuentoPromo__c, IMP_OmitirDescuentoSAP__c
                                                                                        FROM OpportunityLineItem WHERE OpportunityId IN : lstOpp]);
        
        for(OpportunityLineItem ops : lstOppL){
            OpportunityLineItem oppLines=mapOpportunityLine.get(ops.Id);
            oppLines.DescuentoAdicional__c=mapDescuentos.get(ops.PricebookEntryId); 
            oppLines.DescuentoSAP__c = mapDescuentosSAP.get(ops.ID);

            if(mapDescuentosPromo.containsKey(ops.id)){
                OpportunityLineItem oppDiscount = mapDescuentosPromo.get(ops.id);
                oppLines.IMP_DescuentoPromo__c = oppDiscount.IMP_DescuentoPromo__c;
                if(oppDiscount.IMP_OmitirDescuentoSAP__c){
                    oppLines.DescuentoSAP__c = oppDiscount.DescuentoSAP__c;
                    oppLines.IMP_OmitirDescuentoSAP__c = oppDiscount.IMP_OmitirDescuentoSAP__c;
                }
            }
        }
        if(!Test.isRunningTest()){
        	update mapOpportunityLine.values();
        }
    }

    /*******************************************************************
    Purpose: Obtiene el monto de las oportunidades abiertas con fecha de cierre en el mes actual
    Parameters: Set<Id> ownersOpp
    Returns: Void
    ********************************************************************/
    
    public void getMontosOpp (set<Id> ownersOpp){
        map<String, Decimal> mapMontoOpp = new map<String, Decimal>(); 
        Map<String,Presupuesto__c > mapPresupuesto= new  Map<String,Presupuesto__c >();        
        List<Opportunity> listOppUser = new List<Opportunity>();
        list<Presupuesto__c> listaPresupuesto = new list<Presupuesto__c>();
        set<String> setCanales = new  set<String>();
        Decimal monto = 0;
        
        
        for(Opportunity opp : [SELECT Id, CloseDate, AccountId, Account.clave_delcanal__c, OwnerId, Importe__c FROM Opportunity  WHERE Importe__c > 0 AND ownerId IN :ownersOpp AND StageName !=:'Ganada' AND StageName !=:'Perdida' AND IMP_FechaCierreEsteMes1__c  =: TRUE]){
            system.debug('opp id ' +  opp.Account.clave_delcanal__c);
            monto = 0;
            if (opp.Account.clave_delcanal__c != null){
                setCanales.add(opp.Account.clave_delcanal__c);
                if (!mapMontoOpp.containsKey(opp.Account.clave_delcanal__c+opp.ownerId)){
                    mapMontoOpp.put(opp.Account.clave_delcanal__c+opp.ownerId, opp.Importe__c);  
                }
                else if (mapMontoOpp.containsKey(opp.Account.clave_delcanal__c+opp.ownerId)) {
                    system.debug(mapMontoOpp.get(opp.Account.clave_delcanal__c+opp.ownerId));
                    monto =  mapMontoOpp.get(opp.Account.clave_delcanal__c+opp.ownerId) + opp.Importe__c;
                    System.debug('monto ' + monto);
                    mapMontoOpp.put(opp.Account.clave_delcanal__c+opp.ownerId, monto ); 
                }  
            }
            
        }
        Date myDate = System.today();
        Date firstDayOfMonth =  Date.newInstance(myDate.year(),myDate.month(), 01);
        Integer numberOfDays = Date.daysInMonth(myDate.year(), myDate.month());
        Date lastDayOfMonth = Date.newInstance(myDate.year(), myDate.month(), numberOfDays);
        
        system.debug('firstDayOfMonth ' + firstDayOfMonth);
        system.debug('lastDayOfMonth ' + lastDayOfMonth);
        
        for(Presupuesto__c presupuesto:[SELECT Id,IMP_CanalVentas__c,IMP_Vendedor__c,IMP_Fecha__c,IMP_TotalOportunidadesPorCerrar__c   FROM Presupuesto__c WHERE IMP_CanalVentas__c IN: setCanales AND IMP_Vendedor__c IN: ownersOpp AND IMP_Fecha__c>=:firstDayOfMonth AND  IMP_Fecha__c<=:lastDayOfMonth]){
            if (mapMontoOpp.containsKey(presupuesto.IMP_CanalVentas__c + presupuesto.IMP_Vendedor__c)){
                presupuesto.IMP_TotalOportunidadesPorCerrar__c = mapMontoOpp.get(presupuesto.IMP_CanalVentas__c + presupuesto.IMP_Vendedor__c); 
                listaPresupuesto.add(presupuesto);          
            }   
        }
        system.debug('listaPresupuesto ' + listaPresupuesto); 
        if (listaPresupuesto.size() > 0 ){
             update listaPresupuesto;
        }
    }
    
    public static Map<String,Decimal> getDiscountsManuales(Set<id> QuoteId,String oportunidad){
        
        List<OpportunityLineItem> listaProdOpp = new List<OpportunityLineItem>();
        Map<Id,QuoteLineItem> mapQuotes = new  Map<Id,QuoteLineItem> ();
        
        for(OpportunityLineItem oppL : [SELECT Id,OpportunityId,PricebookEntryId,Product2Id,DescuentoAdicional__c
                                        FROM OpportunityLineItem WHERE OpportunityId  =: oportunidad ]) {
                                            listaProdOpp.add(oppL);
                                        }
        for(QuoteLineItem quL : [Select id, QuoteId, PricebookEntryId,Descuento_adicional__c  
                                 from QuoteLineItem where QuoteId  =: QuoteId]) {
                                     mapQuotes.put(quL.PricebookEntryId, quL) ;  
                                 }

        Map<String,Decimal> mapReturn = new  Map<String,Decimal>(); 
        
        for(OpportunityLineItem prodLine: listaProdOpp){
            mapReturn.put(prodLine.PricebookEntryId,mapQuotes.containsKey(prodLine.PricebookEntryId)? mapQuotes.get(prodLine.PricebookEntryId).Descuento_adicional__c : 0);
        }
        return mapReturn;
    }
    
    private static Map<String,Decimal> getDiscountsSAP(Set<id> QuoteId,String oportunidad){
        Map<String,PoliticaDescuento__c> mapDescuentos = new  Map<String,PoliticaDescuento__c> ();
        List<OpportunityLineItem> listaProds = new List<OpportunityLineItem>();

        Map<String,Decimal> mapReturn = new  Map<String,Decimal>();
        Opportunity opp = [SELECT Id, AccountId,Account.Clave_delcanal__c,Account.Grupo__c FROM Opportunity WHERE Id =: oportunidad];

        for(OpportunityLineItem oppL : [SELECT Id,OpportunityId,PricebookEntryId,Product2Id,DescuentoAdicional__c,Product2.Grupo_de_Materiales__c
                                        FROM OpportunityLineItem WHERE OpportunityId  =: oportunidad ]) {
                                            listaProds.add(oppL);
                                        }

        for(PoliticaDescuento__c politicaDesc : [SELECT Id,Activa__c,Canaldistribucion__c,GrupoProducto__c, Descuento__c,Grupo_de_cliente_del__c
                                                 FROM PoliticaDescuento__c WHERE Activa__c = true AND Canaldistribucion__c =:opp.Account.Clave_delcanal__c
                                                 AND Grupo_de_cliente_del__c =:opp.Account.Grupo__c])
        {
            mapDescuentos.put(politicaDesc.GrupoProducto__c, politicaDesc) ;  
        }

        for(OpportunityLineItem prodOppor: listaProds){
            mapReturn.put(prodOppor.Id,mapDescuentos.containsKey(prodOppor.Product2.Grupo_de_Materiales__c)? mapDescuentos.get(prodOppor.Product2.Grupo_de_Materiales__c).Descuento__c : 0);
        }
        return mapReturn;
        
        
    }
    
    private static Map<Id,OpportunityLineItem> getDiscountsPromo(Opportunity opor, List<OpportunityLineItem> listLineOpp){
        Map<Id,OpportunityLineItem> mapDescuentos = new  Map<Id,OpportunityLineItem> ();
        String grupoClientePromo = '';

        if( String.isNotBlank(opor.SyncedQuoteId)){
            Quote cot = [SELECT Id, isSyncing, Account.grupo__c, Account.clave_delcanal__c
            , Account.OrganizacionVentas__c
            , Account.id_de_sap__c
            , Account.centro_suministrador__c
            , Pricebook2.Lista_de_precios_SAP__c
            ,Requiereaprobacion__c,Pricebook2.Sucursal__c 
            FROM Quote WHERE Id =:opor.SyncedQuoteId];

            if(cot.isSyncing){
				Descuento__c descuentoPromo = new Descuento__c();
                IMP_DescuentosManager.WrapperSecuencesParam param = new IMP_DescuentosManager.WrapperSecuencesParam();
                IMP_DescuentosManager.WrapperSecuences MapSecuences = new IMP_DescuentosManager.WrapperSecuences();
                MapSecuences = IMP_DescuentosManager.getDiscountByQuote(cot);
                
                for(OpportunityLineItem oLineItem: listLineOpp){
                    param.OrgVentas = cot.Account.OrganizacionVentas__c;
                    param.canalVentas = cot.Account.clave_delcanal__c;
                    param.numeroCliente = cot.Account.id_de_sap__c;
                    param.numeroMaterial = oLineItem.ProductCode;
                    param.OficinaVentas = cot.Pricebook2.Sucursal__c; //Account.centro_suministrador__c , pedido.Pricebook2.Sucursal__c
                    param.ListaPrecios = oLineItem.Product2.Lista_precios__c;//cot.Account.Grupo_de_precios__c; 03 Mostrador, 04 Distribuidores, Account.ListaPrecios__c = 03 Mostrador, 04 Distribuidores
                    param.GrupoMateriales = oLineItem.Product2.Grupo_de_Materiales__c;
                    param.GrupoArticulos = oLineItem.Product2.Grupo_de_art_culos__c;
                    param.GrupoClientes = cot.Account.grupo__c;
                    param.ClaseDoc = System.label.IMP_ClasePedido;
                    param.CanalPromocion = System.label.IMP_CanalPromo;
                    grupoClientePromo = System.label.IMP_GrupoClientePromo;

                    System.debug('Parametros usados en trigger');
                    System.debug(param);

                    descuentoPromo = IMP_DescuentosManager.getDiscountByToApply(param, MapSecuences);
                	if(descuentoPromo != null){
                        if(descuentoPromo.IMP_ImportePorcentaje__c > 0){
                            if(param.canalVentas == param.CanalPromocion && param.GrupoClientes ==  grupoClientePromo ){
                              	oLineItem.DescuentoSAP__c = 0;
                                oLineItem.IMP_OmitirDescuentoSAP__c = true;
                                System.debug('Omitir sap');
                                System.debug(oLineItem.DescuentoSAP__c);
                            }

                            oLineItem.IMP_DescuentoPromo__c = descuentoPromo.IMP_ImportePorcentaje__c;
                            System.debug('Parametros promocion aplicado ' + descuentoPromo.ID);
                            System.debug(param);
                            mapDescuentos.put(oLineItem.Id,oLineItem);
                        }
                    }
                }
            }
        }
        return mapDescuentos;
    }
}