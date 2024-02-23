/*************************************************************** 
Name: LML_SyncingMobile_CC
Copyright © 2023 Salesforce
======================================================
Purpose:
Custom controller to ejecute process of sync quotes.
======================================================
History:
Creation
VERSION  AUTHOR           DATE          DETAIL     Description
1.0      rotrejo@ts4.mx   23/03/2023    INITIAL     DEV CSR: 
***************************************************************/
public without sharing class IMP_SyncingMobile_cc {
    
    /******************************************************************* 
    Purpose: It gets the information about the quote know the status, 
    if It´s syncing quote, unsyncing or replace.
    Parameters: Quote Id.
    Returns: DataWrapperSync.
    Throws :
    Information about changes (versions)
    ********************************************************************/ 
    @auraEnabled
    public static DataWrapperSync getQuote(Id idQuote)
    {
        DataWrapperSync returnD=new DataWrapperSync();
        Quote q=[SELECT Id, Name,Opportunity.Name,Opportunity.Amount,Status,OpportunityId,IsSyncing,Opportunity.SyncedQuoteId,Opportunity.SyncedQuote.Name FROM Quote WHERE Id=:idQuote];
        if(q.IsSyncing)
        {
            returnD.header='Detener sincronización';
        }
        else if(q.Opportunity.SyncedQuoteId!=null)
        {
            returnD.header='Reemplazar sincronización';
        }
        else
        {
            returnD.header='Sincronizar cotización';
        }
        returnD.cotizacion=q;
        return returnD;
    }
    
    /******************************************************************* 
    Purpose: It gets the information about the quote know the status, 
    if It´s syncing quote, unsyncing or replace.
    Parameters: Quote and if it´s unsyncing.
    Returns: 
    Throws :
    Information about changes (versions)
    ********************************************************************/ 
    @auraEnabled
    public static DataWrapperSync saveSync(Quote cotizacion,boolean unSync)
    {
        DataWrapperSync returnData=new DataWrapperSync();
        String mensaje;
        String status;
        if(unSync)
        {
            try{
                cotizacion.Opportunity.SyncedQuoteId=null; 
                cotizacion.Opportunity.Amount=0;
                update cotizacion.Opportunity;
                
                delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId=:cotizacion.OpportunityId];
                
                status = 'SUCCESS';
                mensaje = '';
                
            }catch(Exception e){
                status = 'ERROR';
                mensaje = e.getMessage();
                System.debug('ERROR');
                System.debug(e.getLineNumber()+' - '+e.getMessage());
            }
        }
        else
        {
            try{
                cotizacion.Opportunity.SyncedQuoteId=cotizacion.Id;
                update cotizacion.Opportunity;
                status = 'SUCCESS';
                mensaje = '';
            }catch(Exception e){
                status = 'ERROR';
                mensaje = e.getMessage();
            }
        }
        returnData.status = status;
        returnData.mensaje = mensaje;
        return returnData;        
    }
    
    public class DataWrapperSync
    {
        @auraEnabled public String header {get;set;}
        @auraEnabled public Quote cotizacion {get;set;}
        @AuraEnabled public string mensaje {get; set;}
        @auraEnabled public String status {get;set;}
    }
    
}