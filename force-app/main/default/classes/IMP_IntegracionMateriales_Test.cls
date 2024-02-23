/************************************************************************
Name: IMP_IntegracionMateriales_Test
Copyright © 2022 Salesforce
========================================================================
Purpose:
Clase test de la clase IMP_IntegracionMateriales y del scheduler
IMP_Materiales_Schedule
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      mvilchis@ts4.mx    11/04/2022     INITIAL        DEV CSR:
************************************************************************/
@isTest
public without sharing class IMP_IntegracionMateriales_Test {
    
    /*******************************************************************
    Purpose: Se inserta información de 2 productos.
    Information about changes (versions) []:
    ********************************************************************/
    @testSetup
    private static void testSetup() {
        Product2 nuevo = new Product2();
        nuevo.Name='TEST PROD';
        nuevo.centro_suministrador__c='';
        nuevo.ProductCode='10000247';
        nuevo.IMP_IdExterno__c='10000247';
        nuevo.Grupo_de_art_culos__c='IMPERC';
        nuevo.sku__c=Decimal.valueOf('10000247');
        nuevo.tipo_impuesto__c='';
        nuevo.QuantityUnitOfMeasure='UN';
        nuevo.IsActive=true;  
    	insert nuevo;

        Product2 prodNew2 = new Product2();
        prodNew2.Name='TEST PROD';
        prodNew2.centro_suministrador__c='';
        prodNew2.ProductCode='10000640';
        prodNew2.IMP_IdExterno__c='10000640';
        prodNew2.Grupo_de_art_culos__c='IMPERC';
        prodNew2.sku__c=Decimal.valueOf('10000640');
        prodNew2.tipo_impuesto__c='';
        prodNew2.QuantityUnitOfMeasure='UN';
        prodNew2.IsActive=true;  
    	insert prodNew2;
    }
    /*******************************************************************
    Purpose: Se inserta información de un producto y se realiza la llamada
    al servicio para actualizar.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static  void materialesWS() {
        DateTime fecha=System.now();
        String hora = '0 0 23 * * ?';
        String body='{"IT_MATERIALES": [{"MATNR": "000000000010000637","WERKS": "SATE","MAKTX": "ELASTON 4 ROJO, 19LT","KONWA": "","MATKL": "IMPERC","KONDM": "08","SKU": "000000000010000637","TAXKM": "","PLTYP": "","MEINS": "UN","LVORM": ""},{"MATNR": "000000000010000640","WERKS": "","MAKTX": "ELASTON 4 BLANCO DOBLE ACCION, 19LT","KONWA": "","MATKL": "IQ","KONDM": "03","SKU": "000000000010000640","TAXKM": "","PLTYP": "","MEINS": "UN","LVORM": "X"},{"MATNR": "000000000010000247","WERKS": "SATE","MAKTX": "GUARDQUIM EPOXI 630 AQUA TRANSPAREN, 4LT","KONWA": "","MATKL": "GUARQM","KONDM": "03","SKU": "000000000010000247","TAXKM": "","PLTYP": "","MEINS": "UN","LVORM": "X"}]}';
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(200, 'OK', body, null));
        Test.startTest();

            String jobId = System.schedule('IMP_Materiales_Schedule',
                hora,
                new IMP_Materiales_Schedule());      
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(0, ct.TimesTriggered,'ok');
        Test.stopTest();
    }
    @isTest
    public static void materialesWS1() {
        Test.startTest();
        IMP_IntegracionMateriales.getMateriales('20220328','20220328');
        Test.stopTest(); 
        list<Integration_Logs__c> listIntegraciones=[SELECT Id FROM Integration_Logs__c];
        System.assertEquals(2, listIntegraciones.size(),'ok');
    }

    
    

}