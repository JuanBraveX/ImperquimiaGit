/************************************************************************
Name: Quote
Copyright © 2022 Salesforce
========================================================================
Purpose:
Trigger to consult the PricebookEntry in relation to the Product and Price list of the sample.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      dmarcod@ts4.mx    14/02/2022     INITIAL        DEV CSR:
************************************************************************/
trigger MuestraTrigger on Muestras__c (before insert,before update) {
    
    if(trigger.isBefore && trigger.isInsert || trigger.isBefore && trigger.isUpdate){
        Set<Id> productoId = new Set<Id>();
        Set<Id> listaPreciosId = new Set<Id>();

        for(Muestras__c muestra : trigger.new){
            productoId.add(muestra.Producto_del__c);
            listaPreciosId.add(muestra.Lista_de_precios_del__c);
        }

        try{
            PricebookEntry entradaListaP = [SELECT Id,Pricebook2Id, Product2Id,UnitPrice FROM PricebookEntry
                                            WHERE Pricebook2Id IN:listaPreciosId AND Product2Id IN:productoId];
            
            for(Muestras__c muestra: trigger.new){
                muestra.Costo__c =entradaListaP.UnitPrice; 
                
                
            }
        }catch(Exception e){
            for(Muestras__c muestra: trigger.new){
                muestra.addError('No existe existe entrada de lista de precios relacionada.');          
            }
            
        }
        
    }
    
}