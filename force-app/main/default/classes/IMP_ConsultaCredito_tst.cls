/************************************************************************
Name: IMP_ConsultaCredito_tst
Copyright © 2022 Salesforce
========================================================================
Purpose: Class used to test the class IMP_ConsultaCredito
Controller
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
1.0      rotrejo@ts4.mx    22/03/2022     INITIAL        DEV CSR:
************************************************************************/

@isTest
public without sharing class IMP_ConsultaCredito_tst {
    
    /*******************************************************************
    Purpose: Inserta 1 cuenta de prueba.
    Information about changes (versions) []:
    ********************************************************************/
    @testSetup static void inicializarDatos()
    {
        Account cuenta = new Account();
        cuenta.name = 'Cuenta Prueba';
        cuenta.RFC__c = '123456789101';
        cuenta.CurrencyIsoCode = 'MXN';
        cuenta.centro_suministrador__c = 'AC01';
        cuenta.clave_delcanal__c = '04';
        cuenta.grupo__c = '01';
        cuenta.id_de_sap__c='10001';
        cuenta.Credito_Acumulado__c = 0;
        cuenta.IMP_TotalEstadosCuenta__c = 0;
        cuenta.IMP_SaldoVencido__c = 0;
        cuenta.IMP_SaldoComprometido__c = 0;
        cuenta.LineaCredito__c = 0;
        cuenta.IMP_Saldo30__c = 0;
        cuenta.IMP_Saldo60__c = 0;
        cuenta.IMP_Saldo90__c = 0;
        cuenta.IMP_Documentos30dias__c = 0;
        cuenta.IMP_Documentos60dias__c = 0;
        cuenta.IMP_Documentos90dias__c = 0;
        cuenta.IMP_TotalFacturas__c = 0;
        cuenta.IMP_TotalFacturasVencidas__c = 0;
        insert cuenta;
        
        EstadoCuenta__c edoCuenta = new EstadoCuenta__c();
        edoCuenta.Cuenta__c = cuenta.Id;
        edoCuenta.Prefijo__c ='RV';
        edoCuenta.Name = '1234';
        edoCuenta.Valor__c = 2300;
        edoCuenta.IMP_LlaveExclusiva__c= '1234';
        insert edoCuenta;
        
    }
    
    /*******************************************************************
    Purpose: Covertura del método updateCredito.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void updateCreditoTest()
    {
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok','',null));
        Test.startTest();
        IMP_ConsultaCredito.updateCredito('10001', 30000);  
        Test.stopTest(); 
    }
  
    /*******************************************************************
    Purpose: Covertura del método IMP_ConsultaCredito/getCredito.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getCreditoTest()
    {
        IMP_ConsultaCredito credito = new IMP_ConsultaCredito();
        List<IMP_ConsultaCredito.cls_credito> creditoRespuesta = new List<IMP_ConsultaCredito.cls_credito>();
        IMP_ConsultaCredito.cls_credito newCredito = new IMP_ConsultaCredito.cls_credito();
        newCredito.KUNNR='10001';
        newCredito.KLIMK=10000;
        newCredito.KLIME=3000;
        creditoRespuesta.add(newCredito);
        credito.credito=creditoRespuesta;
        String body = JSON.serialize(credito);
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_ConsultaCredito.getCredito('10001');  
        Test.stopTest();
    }
    /*******************************************************************
    Purpose: Covertura del método consultaIdSAP.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void consultaIdSAPTest()
    {
        Test.startTest();
        Account cuenta=[SELECT Id FROM Account];
        cuenta = IMP_ConsultaCredito.consultaIdSAP(cuenta.Id);
        Test.stopTest();
        
    }
    
    /*******************************************************************
    Purpose: Covertura del método updateCreditoCuentaTest.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void updateCreditoCuentaTest()
    {
        IMP_ConsultaCredito credito = new IMP_ConsultaCredito();
        List<IMP_ConsultaCredito.cls_credito> creditoRespuesta = new List<IMP_ConsultaCredito.cls_credito>();
        IMP_ConsultaCredito.cls_credito newCredito = new IMP_ConsultaCredito.cls_credito();
        newCredito.KUNNR='10001';
        newCredito.KLIMK=10000;
        newCredito.KLIME=3000;
        creditoRespuesta.add(newCredito);
        credito.credito=creditoRespuesta;
        String body = JSON.serialize(credito);
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_ConsultaCredito.updateCreditoCuenta('10001');  
        Test.stopTest();
    }
    
    /*******************************************************************
    Purpose: Covertura del método updateCreditoCuenta.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void updateCreditoCuentaError()
    {
        delete [SELECT Id FROM Account];
        IMP_ConsultaCredito credito = new IMP_ConsultaCredito();
        List<IMP_ConsultaCredito.cls_credito> creditoRespuesta = new List<IMP_ConsultaCredito.cls_credito>();
        IMP_ConsultaCredito.cls_credito newCredito = new IMP_ConsultaCredito.cls_credito();
        newCredito.KUNNR='10001';
        newCredito.KLIMK=10000;
        newCredito.KLIME=3000;
        creditoRespuesta.add(newCredito);
        credito.credito=creditoRespuesta;
        String body = JSON.serialize(credito);
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_ConsultaCredito.updateCreditoCuenta('10001');  
        Test.stopTest();
    }
    
     @isTest
    public static void updateEdoCuentaTest()
    {
        IMP_ConsultaCredito newCredito = new IMP_ConsultaCredito();
        List<IMP_ConsultaCredito.cls_IT_DOCUMENTOS> documentosRespuesta = new List<IMP_ConsultaCredito.cls_IT_DOCUMENTOS>();
        IMP_ConsultaCredito.cls_IT_DOCUMENTOS newDocumentos = new IMP_ConsultaCredito.cls_IT_DOCUMENTOS();
        newDocumentos.DATE_OFF = Date.today();
        newDocumentos.DOC_NO='12345';
        newDocumentos.DOC_TYPE ='RV';
        newDocumentos.LC_AMOUNT =5400;
        documentosRespuesta.add(newDocumentos);
        newCredito.IT_DOCUMENTOS = documentosRespuesta;
        newCredito.KUNNR='10001';
        newCredito.BUKRS='IMQ';
        newCredito.SALDO_TOTAL =23000;
        newCredito.V_COMPROMETIDO =23000;
        newCredito.V_LIMITE_CREDITO =23000;
        newCredito.V_SALDO_30_DIAS =23000;
        newCredito.V_SALDO_60_DIAS =23000;
        newCredito.V_SALDO_90_DIAS =23000;
        newCredito.V_TOTAL_30_DIAS =23000;
        newCredito.V_TOTAL_60_DIAS =23000;
        newCredito.V_TOTAL_90_DIAS =23000;
        newCredito.V_TOTAL_ACTUAL_LINE =23000;
        newCredito.V_TOTAL_LINE =23000;
        newCredito.V_TOTAL_VENCID_LINE =23000;
        newCredito.SALDO_VENCIDO =23000;
		Account cuenta=[SELECT Id FROM Account limit 1];
        String body = JSON.serialize(newCredito);
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_ConsultaCredito.updateEdoCuenta('10001',cuenta.Id);  
        Test.stopTest();
    }     
    
}