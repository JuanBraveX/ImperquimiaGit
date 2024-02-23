/************************************************************************
Name: Quote_Test
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
public without sharing class Quote_Test {
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
        Insert prod;
        
        Product2 prod2 =new Product2();
        prod2.Name = 'IMPERMEABILIZANTE 2 ';
        prod2.ProductCode='IMP-123456';
        prod2.Family = 'Naya';
        prod2.Description = '';
        prod2.IsActive = true;
        prod2.CurrencyIsoCode='MXN';
        prod2.Grupo_de_Materiales__c ='04';            
        Insert prod2;
        
        Product2 prod3 =new Product2();
        prod3.Name = 'IMPERMEABILIZANTE  3';
        prod3.ProductCode='IMP-123457';
        prod3.Family = 'Naya';
        prod3.Description = '';
        prod3.IsActive = false;
        prod3.CurrencyIsoCode='MXN';
        prod3.Grupo_de_Materiales__c ='03';            
        Insert prod3;
        
        Id pricebookId = Test.getStandardPricebookId(); 

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name='AC01 - Distribuidor';
        listaPrecios.Sucursal__c='AC01';
        listaPrecios.CurrencyIsoCode='MXN';
        listaPrecios.IsActive=true;
        listaPrecios.Lista_de_precios_SAP__c='04';
        insert listaPrecios;
        
        PricebookEntry pbeSt = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            IsActive = true,
            CurrencyIsoCode='MXN',
            UnitPrice = 150,
            UseStandardPrice=false
        );
        
        insert pbeSt;    
        
        PricebookEntry pbeSt2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod2.Id,
            IsActive = true,
            CurrencyIsoCode='MXN',
            UnitPrice = 150,
            UseStandardPrice=false
        );
        
        insert pbeSt2; 
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod3.Id,
            IsActive = true,
            CurrencyIsoCode='MXN',
            UnitPrice = 500,
            UseStandardPrice=false
        );            
        insert pbe;
        
        
        Quote cotizacion = new Quote();
        cotizacion.Name = 'Test';
        cotizacion.OpportunityId = oportunidad.Id; 
        cotizacion.Pricebook2Id = pricebookId;
        cotizacion.CurrencyIsoCode='MXN';
        cotizacion.Tax=0.00;
        cotizacion.Status='Borrador'; 
        cotizacion.BillingName='Direccion Test'; 
        cotizacion.ShippingName='Direccion Test';
        Insert cotizacion;
        
        PoliticaDescuento__c  politicaDescuento = new PoliticaDescuento__c ();
        politicaDescuento.Name = 'Distribuidor A/ Populares';
        politicaDescuento.Activa__c  = true;
        politicaDescuento.CurrencyIsoCode = 'MXN';
        politicaDescuento.Descuento__c  = 70.2;
        politicaDescuento.Grupo_de_cliente_del__c = '01';
        politicaDescuento.Canaldistribucion__c = '04';        
        politicaDescuento.GrupoProducto__c = '03';
        Insert politicaDescuento;
        
        List<QuoteLineItem> listaQli=new List<QuoteLineItem>();
        
        QuoteLineItem productEdit = new QuoteLineItem();
        productEdit.Quantity  = 2;
        productEdit.QuoteId = cotizacion.Id;
        productEdit.Product2Id = prod.Id;
        productEdit.Descuento_adicional__c = 20.0;
        productEdit.DescuentoSAP__c = 46.0;
        productEdit.UnitPrice=150;
        productEdit.Discount=66.0;     
        productEdit.PricebookEntryId=pbeSt.Id; 
        productEdit.PoliticaDescuento__c=politicaDescuento.Id;
        listaQli.add(productEdit);
        
        QuoteLineItem productEdit1 = new QuoteLineItem();
        productEdit1.Quantity  = 2;
        productEdit1.QuoteId = cotizacion.Id;
        productEdit1.Product2Id = prod.Id;
        productEdit1.Descuento_adicional__c = 20.0;
        productEdit1.DescuentoSAP__c = 46.0;
        productEdit1.UnitPrice=500;
        productEdit1.Discount=66.0;     
        productEdit1.PoliticaDescuento__c=politicaDescuento.Id;
        productEdit1.PricebookEntryId=pbeSt.Id; 
        
        listaQli.add(productEdit1);     
        insert listaQli; 
    }
/******************************************************************* 
Purpose: Test class method that update opportunity fields when synced with a quote.
Parameters:PricebookEntry pricebook , Id cotizacion.
Returns: 
Throws :
Information about changes (versions)
********************************************************************/  
    @isTest public static void sincQuote(){
        Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE Name = 'Oportunidad Test'];
        Quote cotizacion = [SELECT Id, Name, PriceBook2Id,CurrencyIsoCode FROM Quote WHERE Name = 'Test'];                
        oportunidad.SyncedQuoteId = cotizacion.Id;
        update oportunidad;
    }

}