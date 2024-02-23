/************************************************************************
Name: IMP_AprobarCotizacionController
Copyright © 2022 Salesforce
========================================================================
Purpose:
Clase controller para mostrar datos de la cotización en el componente de IMP_AprobarCotizacion
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
 2.0      dmarcos@ts4.mx     11/03/2022     
************************************************************************/
public without sharing class IMP_AprobarCotizacionController {
    
    /*******************************************************************
   Purpose: Mostrar información de la cotización en el componente IMP_AprobarCotizacion .
   Parameters: Id cotizacionId
   Returns: DataQuoteWrapper
   Throws [Exceptions]:
   Information about changes (versions) []:
   ********************************************************************/
    @auraEnabled
    public static DataQuoteWrapper getInitialData(Id cotizacionId){
        
        DataQuoteWrapper returnData = new DataQuoteWrapper();
          
        Quote cotizacion=[SELECT Id ,Name, Pricebook2Id,Pricebook2.Sucursal__c, CurrencyIsoCode, Opportunity.Id, Opportunity.Name,
                          Status, IsSyncing,TotalPrice,Tax,GrandTotal,Requiereaprobacion__c,Account.Name, Account.ListaPrecios__c,
                          TotalPartidas__c,PrecioTotal__c, QuoteNumber,AprobacionCliente__c
                          FROM Quote WHERE Id =: cotizacionId];
        
        list<QuoteLineItem> listQuoteslines=[SELECT Id,Discount, Quantity, TotalPrice,PoliticaDescuento__c,DescuentoSAP__c,
                                             UnitPrice,PricebookEntryId, PricebookEntry.Id, PricebookEntry.Name, PricebookEntry.UnitPrice,
                                             PricebookEntry.Product2.Id,PricebookEntry.Product2.IsActive,Product2.Name, PricebookEntry.Product2.Description, Product2.Family,
                                             Product2.ProductCode,Product2.Grupo_de_Materiales__c,
                                             Product2.IsActive,QuoteId,Descuento_adicional__c,PrecioTotalConDescuentos__c
                                             FROM QuoteLineItem WHERE QuoteId = :cotizacionId ORDER BY CreatedDate];
        
        
        returnData.status='SUCCESS';
        returnData.cotizacion=cotizacion;
        returnData.listQuoteLineItems=listQuoteslines;      
        return returnData;
        
    }
    
    /*******************************************************************
   Purpose: Actualiza la cotización con estatus de Aprobada o Rechazada según el valor de la lista de selección.
   Parameters: String cotizacionId,String valuePickList
   Returns: DataQuoteWrapper
   Throws [Exceptions]:
   Information about changes (versions) []:
   ********************************************************************/
    @AuraEnabled
    public static DataQuoteWrapper actualizarCotizacion(String cotizacionId, String valuePickList){
        DataQuoteWrapper returnData = new DataQuoteWrapper();
        try {
            Quote cotizacion = [SELECT Id,AprobacionCliente__c
                                              FROM Quote 
                                              WHERE Id =: cotizacionId];
            cotizacion.AprobacionCliente__c=valuePickList;
            upsert cotizacion;
            returnData.status = 'Ok';
            
        } catch(Exception e) {
            returnData.status = 'Error';
        }
        
        return returnData;
    }
    
    /*******************************************************************
   Purpose: Mostrar valores del campo AprobacionCliente__c en el componente IMP_AprobarCotizacion.
   Parameters: 
   Returns: Map<String, String>
   Throws [Exceptions]:
   Information about changes (versions) []:
   ********************************************************************/
    @AuraEnabled 
    public static Map<String, String> getAprobacionFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Quote.AprobacionCliente__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    public class DataQuoteWrapper{
        @auraEnabled public Quote cotizacion {get; set;}  
        @auraEnabled public list<QuoteLineItem> listQuoteLineItems {get; set;}
        @auraEnabled public String status {get;set;}

    }
}