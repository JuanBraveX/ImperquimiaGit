/************************************************************************
Name: MuestraTrigger_Test
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test class from the trigger Quote.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      dmarcos@ts4.mx    15/02/2022     INITIAL        DEV CSR:
************************************************************************/
@isTest
public without sharing class MuestraTrigger_Test {

/******************************************************************* 
    Purpose: Inserts all information to run the class method.
    Information about changes (versions):
    ********************************************************************/    
    @testSetup static void setup(){
        
        Account cuenta = new Account();
        cuenta.name = 'Cuenta Prueba';
        cuenta.RFC__c = '0011MYA1';
        cuenta.CurrencyIsoCode = 'MXN';
        cuenta.centro_suministrador__c = 'AC01';
        cuenta.clave_delcanal__c = '04';
        cuenta.grupo__c = '01';
        insert cuenta;
        
        RecordType recordTypeOportunidad=[SELECT Name, DeveloperName,sobjecttype, Id FROM RecordType where sobjectType='Opportunity' and DeveloperName='Oportunidad'];
        
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = cuenta.Id;
        oportunidad.Name = 'Oportunidad Test';
        oportunidad.StageName = 'Plan';
        oportunidad.CurrencyIsoCode = 'MXN';
        oportunidad.CloseDate = Date.today().addDays(30);
        oportunidad.RecordTypeId=recordTypeOportunidad.Id;
        oportunidad.Amount=3850.6;
        oportunidad.Probability=100; 
        insert oportunidad;
        
        Product2 prod =new Product2();
        prod.Name = 'IMPERMEABILIZANTE';
        prod.ProductCode='IMP-12345';
        prod.Family = 'Naya';
        prod.Description = '';
        prod.IsActive = true;
        prod.CurrencyIsoCode='MXN';
        prod.Grupo_de_Materiales__c ='03';            
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId(); 

        PricebookEntry pbeSt = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            IsActive = true,
            CurrencyIsoCode='MXN',
            UnitPrice = 150,
            UseStandardPrice=false
        );
        
        insert pbeSt; 
        
        SolicitudMuestra__c solicitudMuestra = new SolicitudMuestra__c(
        Name = 'Solicitud prueba',
        Estatus__c ='Nuevo',
        tipo_muestra__c ='Desarrollo',
        Oportunidad__c = oportunidad.Id
        );
        
        insert solicitudMuestra;
        
        Muestras__c muestras = new Muestras__c (
        Name ='Muestra test',
        Lista_de_precios_del__c = pricebookId,
        Producto_del__c = prod.Id,
        Solicitud_de_muestra_del__c  = solicitudMuestra.Id
        );
        
        insert muestras;
        
        
    }
/******************************************************************* 
Purpose: Test class method to consult the PricebookEntry in relation to the Product and Price list of the sample.
Parameters:PricebookEntry pricebook , Id cotizacion.
Returns: 
Throws :
Information about changes (versions)
********************************************************************/   
    @isTest public static void crearMuestra(){
        Muestras__c muestra = [SELECT Id FROM Muestras__c WHERE Name ='Muestra test'];
    }
    

}