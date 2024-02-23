/************************************************************************
Name: IMP_CrearClienteSap_Test
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test del controlador IMP_CrearClienteSap_CC
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      mvilchis@ts4.mx    11/04/2022     INITIAL        DEV CSR:
************************************************************************/
@isTest
public without sharing class IMP_CrearClienteSap_Test {
    /*******************************************************************
    Purpose: Inserta 1 cuenta de prueba.
    Information about changes (versions) []:
    ********************************************************************/
    @testSetup
    private static void testSetup() {
        Account acc = new Account();
        acc.Name='Test Test';
        acc.Tipo_de_persona__c=true;
        acc.RFC__c='AX091234ER5T6';
        acc.id_de_sap__c='2021';
        acc.clave_delcanal__c='07';
        acc.Credito_SAP__c=false;
        insert acc;
    }

    /*******************************************************************
    Purpose: Post de una cuenta con respuesta success.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void postAccount() {
        Account cuenta=[SELECT Id FROM Account Where RFC__c='AX091234ER5T6' LIMIT 1];
        IMP_CrearClienteSap_CC returnWrapper = IMP_CrearClienteSap_CC.sapValidated(cuenta.Id);
        List<Id> lstAcc = new List<Id>{cuenta.Id};
        String token = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(200, 'success', '{"E_CLIENTE": "0001036236","V_MSG": ""}', null));
        IMP_CrearClienteSap_CC.Wrapper response = IMP_CrearClienteSap_CC.postAccount(token, lstAcc);
        System.assertEquals('SUCCESS', response.status,'ok');
        Test.stopTest();
    }
    /*******************************************************************
    Purpose: Post de una cuenta con respuesta error.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void postAccount2() {
        
        Account cuenta=[SELECT Id FROM Account Where RFC__c='AX091234ER5T6' LIMIT 1];
        List<Id> lstAcc = new List<Id>{cuenta.Id};
        String token = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(200, 'success', '{"E_CLIENTE": "0001036236","V_MSG": " "}', null));
        IMP_CrearClienteSap_CC.Wrapper response = IMP_CrearClienteSap_CC.postAccount(token, lstAcc);
        System.assertEquals('ERROR', response.status,'ok');
        Test.stopTest();
    }
    /*******************************************************************
    Purpose: Post de cuenta con error.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void postAccount1() {
        Account cuenta=[SELECT Id FROM Account Where RFC__c='AX091234ER5T6' LIMIT 1];
        List<Id> lstAcc = new List<Id>{cuenta.Id};
        String token = '';
        Test.startTest();
        IMP_CrearClienteSap_CC.postAccount(token, lstAcc);
        list<Integration_Logs__c> logs= [SELECT Id FROM Integration_Logs__c];
        System.assertEquals(1, logs.size(),'ok');
        Test.stopTest();
    }

    
    
    /*******************************************************************
    Purpose: Covertura del Trigger account_Trigger.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void triggerAccountTest() {
        Test.startTest();
        Account cuenta=[SELECT Id FROM Account Where RFC__c='AX091234ER5T6' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(200, 'OK', '', null));
        cuenta.Credito_SAP__c=true;
        update cuenta;
        Test.stopTest();
       // System.assertEquals('2021', cuentaResponse.id_de_sap__c,'ok');
    }
    
}