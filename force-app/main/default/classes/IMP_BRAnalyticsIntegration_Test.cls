/************************************************************************
Name: IMP_BRAnalyticsIntegration_Test
Copyright © 2022 Salesforce
========================================================================
Purpose:
Clase test de la clase apex IMP_BRAnalyticsIntegration
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      mvilchis@ts4.mx    04/05/2022     INITIAL        DEV CSR:
************************************************************************/
@isTest
public class IMP_BRAnalyticsIntegration_Test {

    /*******************************************************************
    Purpose: Test del método getDataAnalytics para integración con BIMSA
    Information about changes (versions) []:
    ********************************************************************/
    @IsTest
    static void getProspectos(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(200, 'SUCCESS','', null));
        IMP_BRAnalyticsIntegration.getDataAnalytics('2022-05-22');
        Test.stopTest();
        
    }
    /*******************************************************************
    Purpose: Test del método getDataAnalytics para integración con BIMSA
    sin productos que registrar al lead.
    Information about changes (versions) []:
    ********************************************************************/
    @IsTest
    static void getProspectosError(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(200, 'SUCCESS','error', null));
        IMP_BRAnalyticsIntegration.getDataAnalytics('2022-05-22');
        Test.stopTest();
        List<Lead> listLead = new List<Lead>([SELECT Id FROM Lead]);
        System.assertEquals(0, listLead.size(),'ok');
    }
    /*******************************************************************
    Purpose: Se llama al servicio para actualizar los prospectos.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static  void insertProspectos() {
        DateTime fecha=System.now();
        String hora = '0 0 23 * * ?';
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(200, 'SUCCESS','', null));
        Test.startTest();

            String jobId = System.schedule('Integración Bimsa',
                hora,
                new IMP_BRAnalyticsSchedule());      
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
            NextFireTime
            FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(0, ct.TimesTriggered,'ok');
        Test.stopTest();
    }
}