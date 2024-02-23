/************************************************************************
Name: IMP_IntegracionClientesWs_Test
Copyright © 2022 Salesforce
========================================================================
Purpose:
Clase test de la clase IMP_IntegracionClientesWs.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  2.0      mvilchis@ts4.mx    11/04/2022     Se realizaron mejoras y 
  optimización de código para completar la covertura de la clase.
************************************************************************/
@isTest
public without sharing class IMP_IntegracionClientesWs_Test {

	/*******************************************************************
	Purpose: Se define un Response para simular la entrada de datos
	y entrada con error.
	Information about changes (versions) []:
	********************************************************************/
    @isTest
    public static void createAccount() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateAccount/';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        Account cuentaTest=new Account();
        cuentaTest.Name='Cuenta Test Dup';
        cuentaTest.id_de_sap__c='1001234';
        cuentaTest.Rfc__c='QED345RFTGYH';
        cuentaTest.IMP_LlaveExterna__c='1001234IMPQ0210';
        cuentaTest.OrganizacionVentas__c='IMPQ';
        cuentaTest.clave_delcanal__c = '02';
        cuentaTest.ListaPrecios__c='03';
        cuentaTest.grupo__c='14';
        insert cuentaTest;
        IMP_IntegracionClientesWs.accountsWrapper obj = new IMP_IntegracionClientesWs.accountsWrapper();
        obj.BUILDING='19';	
		obj.HOUSE_NO='12';	
		obj.BEGRU='606';	
		obj.WAERS='MXN';	
		obj.VKBUR='CA01';	
		obj.VKGRP='006';	
		obj.VWERK='CA01';	
		obj.INCO2='COSTES Y FLETE';	
		obj.INCO1='CFR';	
		obj.PLTYP='03';	
		obj.KONDA='02';	 
		obj.BZIRK='000001';	
		obj.KDGRP='14';	
		obj.SPART='10';	
		obj.VTWEG='02';	
		obj.VKORG='IMPQ';	
		obj.FDGRV='Y01';	
		obj.KTGRD='01';	 
		obj.ZWELS='CDEFGHINT';	
		obj.ZTERM='NT00';	
		obj.AKONT='121000';	
		obj.STKZN='X';
		obj.STCD1='MELM830221WM6';	
		obj.STRAS='Calle Bahía de las Palmas';	
		obj.REGIO='AGS';	
		obj.PSTLZ='11300';	
		obj.CITY2='Delegacion';	
		obj.CITY1='Altavista';	
		obj.TEL1='5549016100';	
		obj.NAME2='';
		obj.NAME1='Centro Comercial Santa Fe version 4';
		obj.LAND='MX';	
        obj.KUNNR_SF='';
        obj.KUNNR='1001234'; 
		
		list<IMP_IntegracionClientesWs.accountsWrapper> lstAcc = new list<IMP_IntegracionClientesWs.accountsWrapper>{obj};
		System.debug('Hola Juan'+JSON.serialize( lstAcc ));
		IMP_IntegracionClientesWs.accountPost(lstAcc);
		IMP_IntegracionClientesWs.accountPost(null);
		Test.stopTest();
		
		Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
String[] toaddresses = new String[] {'jpedraza@ts4.mx'}; 
mymail.setToAddresses(toAddresses);
mymail.setSenderDisplayName('Salesforce Support');
mymail.setSubject('An email from Salesforce');
mymail.setPlainTextBody('This email has been sent through Apex');
mymail.setHtmlBody('<p>'+ JSON.serialize( lstAcc ) +'</p>');

Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });
		list<Account> cuenta=[SELECT Id, id_de_sap__c FROM Account WHERE id_de_sap__c='1001234'];
		System.assertEquals(1, cuenta.size(),'ok');

    }
    /*******************************************************************
	Purpose: Se define un Response para simular la entrada de datos.
	Information about changes (versions) []:
	********************************************************************/
    @isTest
    public static void createAccount2() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateAccount/';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        IMP_IntegracionClientesWs.accountsWrapper obj = new IMP_IntegracionClientesWs.accountsWrapper();
        obj.BUILDING='19';	
		obj.HOUSE_NO='12';	
		obj.BEGRU='606';	
		obj.WAERS='MXN';	
		obj.VKBUR='CA01';	
		obj.VKGRP='006';	
		obj.VWERK='CA01';	
		obj.INCO2='COSTES Y FLETE';	
		obj.INCO1='CFR';	
		obj.PLTYP='03';	
		obj.KONDA='02';	 
		obj.BZIRK='000001';	
		obj.KDGRP='14';	
		obj.SPART='10';	
		obj.VTWEG='02';	
		obj.VKORG='IMPQ';	
		obj.FDGRV='Y01';	
		obj.KTGRD='01';	 
		obj.ZWELS='CDEFGHINT';	
		obj.ZTERM='NT00';	
		obj.AKONT='121000';	
		obj.STKZN='X';
		obj.STCD1='MELM830221WM6';	
		obj.STRAS='Calle Bahía de las Palmas';	
		obj.REGIO='AGS';	
		obj.PSTLZ='11300';	
		obj.CITY2='Delegacion';	
		obj.CITY1='Altavista';	
		obj.TEL1='5549016100';	
		obj.NAME2='';
		obj.NAME1='Centro Comercial Santa Fe version 4';
		obj.LAND='MX';	
        obj.KUNNR_SF='';
        obj.KUNNR='1001234'; 
		
		list<IMP_IntegracionClientesWs.accountsWrapper> lstAcc = new list<IMP_IntegracionClientesWs.accountsWrapper>{obj};
		IMP_IntegracionClientesWs.accountPost(lstAcc);
		IMP_IntegracionClientesWs.accountPost(null);
		Test.stopTest();
		list<Account> cuenta=[SELECT Id, id_de_sap__c FROM Account WHERE id_de_sap__c='1001234'];
		System.assertEquals(1, cuenta.size(),'ok');

    }
    
	/*******************************************************************
	Purpose: Covertura de la clase IMP_CalloutUtils doRequest, con una
	respuesta error.
	Information about changes (versions) []:
	********************************************************************/
    @isTest
    public static void createAccountError() {
        
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(400, 'error', 'error', null));
		Map<String,String> prams=new map<String,String>{'key'=>'prueba'};
        HttpRequest req=IMP_CalloutUtils.generateRequest('POST', 'TEST', prams, null, 1200, 'TEST');
		try {
			IMP_CalloutUtils.doRequest(req, true);
		} catch(Exception e) {
			System.assertEquals('400,error', e.getMessage(),'ok');
		}
        Test.stopTest(); 
    }
}