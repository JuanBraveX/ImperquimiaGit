/************************************************************************
Name: IMP_JsonOutput
Copyright © 2022 Salesforce
========================================================================
Purpose:
Wrapper de la respuesta para exposición de servicio retorna clave y
id_salesforce o en su caso el error.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  2.0      mvilchis@ts4.mx    11/04/2022     Limpieza y optimización de 
  código
************************************************************************/
public with sharing class IMP_JsonOutput {
    /*******************************************************************
    Purpose: Wrapper de la respuesta de la exposición del servicio,
    se retorna id salesforce y la clave SAP.
    Parameters: List<Account> lstAccIns
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static string output(List<Account> lstAccIns) {
        List<ErrorWrapper> lstError = new List<ErrorWrapper>();
        List<CreacionClientesWrapper> lstAccount = new List<CreacionClientesWrapper>();
        for(Account acc : lstAccIns) {
            system.debug('Entro al JSOn ');
            CreacionClientesWrapper creacion = new CreacionClientesWrapper();
            creacion.id_SFDC = acc.Id;
            creacion.clave_SAP = acc.id_de_sap__c;
            creacion.VKORG=acc.OrganizacionVentas__c;
            creacion.VTWEG=acc.clave_delcanal__c;
            creacion.SPART=acc.Sector__c;
            lstAccount.add(creacion);
        }
        for(Account acc : lstAccIns) {
            ErrorWrapper error = new ErrorWrapper();
            error.mensaje = '';
            error.time_stamp = '';
            lstError.add(error);
        }
        ResponseWrapper jsonRes = new ResponseWrapper();
        jsonRes.status_SFDC = 'SUCESS';
        jsonRes.error_SFDC = lstError;
        jsonRes.creacion_SFDC = lstAccount;
        String output = (String)JSON.serialize(jsonRes);
        return output;
    }
    public class ResponseWrapper {
        public String status_SFDC {get;set;}
        public List<ErrorWrapper> error_SFDC {get;set;}
        public List<CreacionClientesWrapper> creacion_SFDC {get;set;}
    }
    public class ErrorWrapper {
        public String mensaje {get;set;}
        public String time_stamp {get;set;}
    }
    public class CreacionClientesWrapper {
        public String id_SFDC {get;set;}
        public String clave_SAP {get;set;}
        public String VKORG {get;set;}
        public String VTWEG {get;set;}
        public String SPART {get;set;}
    }
}