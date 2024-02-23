/************************************************************************
Name: Quote
Copyright © 2022 Salesforce
========================================================================
Purpose:
Trigger to update opportunity fields when synced with a quote
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      dmarcos@ts4.mx    08/02/2022     INITIAL        DEV CSR:
************************************************************************/
trigger Quote on Quote (before insert,before update, before delete, after update) {
    
    if(trigger.isBefore && trigger.isUpdate) {
        map<String,Quote> quoteOld = new map<String,Quote>(trigger.old);
        list<Opportunity> listOportunity= new list<Opportunity>();
        
        for(Quote q : trigger.new){
            if( quoteOld.get(q.Id).IsSyncing != q.IsSyncing){
                if(q.IsSyncing){                      
                    Opportunity op= new Opportunity(
                        Id=q.OpportunityId,
                        Condiciones_de_pago__c  = q.condiciones_de_pago__c,
                        payment_terms__c = q.payment_terms__c,
                        PrecioTotal__c = q.PrecioTotal__c,
                        Importe__c = q.TotalPartidas__c
                    );
                    listOportunity.add(op);
                }                 
            }          
        }
        if(listOportunity.size()>0){
            update listOportunity;
        }
        
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        set<Id> opportunityIds=new set<Id>();
        for(Quote cotizacion : trigger.new){
            opportunityIds.add(cotizacion.OpportunityId);
        }
        
        List<Opportunity> listOpp = new  List<Opportunity>();
        for(Quote cotizacion : trigger.new){
            if(!cotizacion.isSyncing  &&  trigger.oldMap.get(cotizacion.Id).isSyncing != cotizacion.isSyncing)
            {
                listOpp.add(new Opportunity(
                    Id = cotizacion.OpportunityId,
                    condiciones_de_pago__c= null,
                    payment_terms__c = null,
                    PrecioTotal__c = null
                ));
            }
        }
        try{
            if(listOpp.size()>0){
                update listOpp;  
            }
        }catch(Exception e){
            System.debug(e.getLineNumber()+' - '+e.getMessage());
        }
        
    }
}