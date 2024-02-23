/************************************************************************
Name: CheckinController
Copyright © 2023 Salesforce
========================================================================
Purpose:
validar check-in, check-out
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
2.0            rortega@ts4.mx    20/04/2023   Se modifica el check-in, check out, se genera con base a la dirección de Event
usando un contacto temporal para poder generar la geolocalización
************************************************************************/
public without sharing class CheckinController {
    @AuraEnabled 
    public static wrapperContryAndState getCountriesAndStates(String recordId) {
        wrapperContryAndState dataAddress = new wrapperContryAndState();
        try {
            List<String> lstPais =  getPicklistValues(Event.IMP_Pais__c);
            List<String> lstState =  getPicklistValues(Event.IMP_Estado__c);
			//Valida si existe un check-in pendiente del usuario 
			List<Event> lstCheckInPending = [SELECT Id, Geolocation__latitude__s
                    , Geolocation__longitude__s
                    , IMP_Geo_Latitude_CheckOut__c 
                    , IMP_Geo_Longitude_CheckOut__c 
                    , IMP_Pais__c, IMP_Ciudad__c
                    , IMP_Estado__c, IMP_Calle__c
                    , IMP_CodigoPostal__c
                    , IMP_Check_In__c
                    , IMP_Check_Out__c
            FROM Event WHERE OwnerId =: UserInfo.getUserId() 
            AND IMP_Check_In__c = true
            AND IMP_Check_Out__c = false
            AND ID !=: recordId ORDER BY CreatedDate DESC LIMIT 1];

            if(lstCheckInPending.size() > 0){
                dataAddress.CheckInPending = lstCheckInPending[0];
            }
            else {
                dataAddress.CheckInPending = null;
            }

            //obtener información del check-in actual
            List<Event> lstCheckEvent = [SELECT ID, Geolocation__latitude__s
                                        , Geolocation__longitude__s
                                        , IMP_Geo_Latitude_CheckOut__c 
                                        , IMP_Geo_Longitude_CheckOut__c 
                                        , IMP_Pais__c, IMP_Ciudad__c
                                        , IMP_Estado__c, IMP_Calle__c
                                        , IMP_CodigoPostal__c
                                        , Description
                                        , IMP_Check_In__c
                                        , IMP_Check_Out__c
                                        , CreatedBy.Id
                                        , CreatedBy.Name
                                        , Owner.name
                                FROM Event WHERE ID =: recordId LIMIT 1];
            
            if(lstCheckEvent[0].CreatedBy.Id != UserInfo.getUserId()){
                dataAddress.IsEventAnotherUser = true;
                dataAddress.NameAnotherUser = lstCheckEvent[0].CreatedBy.name;
            }
            else {
                dataAddress.IsEventAnotherUser = false;
                dataAddress.NameAnotherUser = '';
            }
                    
            if(lstCheckEvent.size() > 0){
                dataAddress.CheckInEvent = lstCheckEvent[0];
            }
			dataAddress.ListCountry = lstPais;
            dataAddress.ListState = lstState;
        }
        catch (Exception ex) {
             throw new AuraHandledException('Error al crear el caso '+ ex.getStackTraceString() + ' ,' + ex.getMessage() + ' , Linea:' + ex.getLineNumber() + ', Causa: ' + ex.getCause());
        }
        return dataAddress;
    }

    public static List<String> getPicklistValues(SObjectField fld) {
        List<String> ListValues = new List<String>();
        Schema.DescribeFieldResult dfr = fld.getDescribe();
        List<Schema.PicklistEntry> plvs = dfr.getPicklistValues();
        for (PicklistEntry ple: plvs) {
            ListValues.add(ple.getValue());
        }
        return ListValues;
    }

    @AuraEnabled
    public static String createContactTemp(Event eventAddress) {
        String result='';

        try {
            Contact contactTemp = new Contact();
            contactTemp.LastName = 'Contacto Temporal';
            contactTemp.firstName = 'Para obtener la geolocation';
            contactTemp.MailingCountry = eventAddress.IMP_Pais__c;
            contactTemp.MailingCity = eventAddress.IMP_Ciudad__c;
            contactTemp.MailingState = eventAddress.IMP_Estado__c;
            contactTemp.MailingStreet = eventAddress.IMP_Calle__c;
            contactTemp.MailingPostalCode = eventAddress.IMP_CodigoPostal__c;
            contactTemp.MailingGeocodeAccuracy = 'Street';
            contactTemp.Phone = '5555555555';

            INSERT contactTemp;
            result = contactTemp.Id;
        }
        catch (Exception e) {
            result = e.getMessage();
        }
        return result;
    }

    @AuraEnabled
    public static list<String> getGeoCode(String idContact) {
        List<String> lstUbicacion = new List<String>();
		Contact clatitud = [SELECT MailingLatitude, MailingLongitude from Contact WHERE ID =: idContact];
        lstUbicacion.add(String.valueOf(clatitud.MailingLatitude));
        lstUbicacion.add(String.valueOf(clatitud.MailingLongitude));
        DELETE clatitud; 
        
        return lstUbicacion;
    }
	
    @AuraEnabled
    public static String userLocation(Event checkEvent, decimal latitude, decimal longitude) {
        String result='SUCCESS';
        
        Event evt = new Event(); 
        evt.Id = checkEvent.Id;
        evt.Tipo__c = checkEvent.Tipo__c;

        try {
            if(checkEvent.Tipo__c == 'Check In'){
                evt.Geolocation__Latitude__s = latitude;
                evt.Geolocation__Longitude__s =longitude;
                evt.Description = checkEvent.description;
            }
            else if(checkEvent.Tipo__c == 'Check Out'){
                evt.IMP_Geo_Latitude_CheckOut__c = latitude; 
                evt.IMP_Geo_Longitude_CheckOut__c =longitude; 
            }
            UPDATE evt;
        }
        catch (Exception e) {
            result = 'FAIL';
        }
        return result;
    }
   
    public class wrapperContryAndState {
        public wrapperContryAndState (){}
        @AuraEnabled
        public List<String> ListCountry {get; set;}
        @AuraEnabled
        public List<String> ListState {get; set;}
        @AuraEnabled
        public Event CheckInEvent {get; set;}
        @AuraEnabled
        public Event CheckInPending {get; set;}
        @AuraEnabled
        public Boolean IsEventAnotherUser {get; set;}
        @AuraEnabled
        public String NameAnotherUser {get; set;}
    }
}