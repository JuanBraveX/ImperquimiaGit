/************************************************************************
Name: IMP_SyncingMobile_tst
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test class from the class IMP_SyncingMobile_cc.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    27/03/2023     INITIAL        DEV CSR:
************************************************************************/
@isTest
public without sharing class IMP_SyncingMobile_tst {
    /******************************************************************* 
    Purpose: Inserts all information to run the class method.
    Information about changes (versions):
    ********************************************************************/ 
    @testSetup static void setup(){
        User administrador = [Select Id, UserRoleId,managerId From User Where Profile.Name='Administrador del sistema' AND isActive=true Limit 1];
        
        System.runAs(administrador){
            
            Profile perfilUser=[SELECT Name, Id FROM Profile WHERE Name='Administrador del sistema'];
            
            User usuario = new User();
            usuario.Username ='usuarioprueba1@gmail.com';
            usuario.LastName ='Usuario1';
            usuario.FirstName ='Prueba1';
            usuario.CompanyName ='Imperquimia1';
            usuario.Email='usuariotest1@test.com';
            usuario.Phone = '45.56.12.34.10';
            usuario.IsActive =true;
            usuario.CommunityNickname='IMPQ1';
            usuario.TimeZoneSidKey='America/Mexico_City';
            usuario.LocaleSidKey='es_MX';
            usuario.EmailEncodingKey='UTF-8';
            usuario.Alias='impq1';
            usuario.ProfileId=perfilUser.Id;
            usuario.ManagerId=administrador.Id;
            usuario.LanguageLocaleKey='es';
            insert usuario;
            
            
            User usuario2 = new User();
            usuario2.Username ='usuarioprueba219998@gmail.com';
            usuario2.LastName ='Usuario2';
            usuario2.FirstName ='Prueba2';
            usuario2.CompanyName ='Imperquimia';
            usuario2.Email='usuariotest2@test.com';
            usuario2.Phone = '45.56.12.34.12';
            usuario2.IsActive =true;
            usuario2.CommunityNickname='IMPQ2';
            usuario2.TimeZoneSidKey='America/Mexico_City';
            usuario2.LocaleSidKey='es_MX';
            usuario2.EmailEncodingKey='UTF-8';
            usuario2.Alias='impqus2';
            usuario2.ProfileId=perfilUser.Id;
            usuario2.LanguageLocaleKey='es';
            usuario2.ManagerId=usuario.Id;
            insert usuario2;
            
            Account cuenta = new Account();
            cuenta.name = 'Cuenta Prueba';
            cuenta.RFC__c = '0011MYA12345';
            cuenta.CurrencyIsoCode = 'MXN';
            cuenta.centro_suministrador__c = 'AC01';
            cuenta.clave_delcanal__c = '04';
            cuenta.grupo__c = '01';
            cuenta.Phone='+52 7225398962';
            insert cuenta;
            
            RecordType recordTypeOportunidad=[SELECT Name, DeveloperName,sobjecttype, Id FROM RecordType where sobjectType='Opportunity' and DeveloperName='Oportunidad'];
            System.runAs(usuario2) {
                
                Opportunity oportunidad = new Opportunity();
                oportunidad.AccountId = cuenta.Id;
                oportunidad.Name = 'Oportunidad Test';
                oportunidad.StageName = 'Plan';
                oportunidad.CurrencyIsoCode = 'MXN';
                oportunidad.CloseDate = Date.today().addDays(30);
                oportunidad.RecordTypeId=recordTypeOportunidad.Id;
                oportunidad.Amount=3850.6;
                oportunidad.Probability=100; 
                oportunidad.OwnerId=usuario2.Id;
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
            prod3.Name = 'IMPERMEABILIZANTE3';
            prod3.ProductCode='IMP-123457';
            prod3.Family = 'Naya';
            prod3.Description = '';
            prod3.IsActive = true;
            prod3.CurrencyIsoCode='MXN';
            prod3.Grupo_de_Materiales__c ='';            
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
            cotizacion.Name = 'Test SyncMobile';
            cotizacion.OpportunityId = oportunidad.Id; 
            cotizacion.Pricebook2Id = pricebookId;
            cotizacion.CurrencyIsoCode='MXN';
            cotizacion.Tax=0.00;
            cotizacion.Status='Borrador'; 
            cotizacion.BillingName='Direccion Test'; 
            cotizacion.ShippingName='Direccion Test';
            Insert cotizacion;
            
             Quote cotizacion2 = new Quote();
            cotizacion2.Name = 'Test SyncMobile v2';
            cotizacion2.OpportunityId = oportunidad.Id; 
            cotizacion2.Pricebook2Id = pricebookId;
            cotizacion2.CurrencyIsoCode='MXN';
            cotizacion2.Tax=0.00;
            cotizacion2.Status='Borrador'; 
            cotizacion2.BillingName='Direccion Test'; 
            cotizacion2.ShippingName='Direccion Test';
            Insert cotizacion2;
            
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
            productEdit.PricebookEntryId=pbeSt.Id; 
            productEdit.PoliticaDescuento__c=politicaDescuento.Id;
            productEdit.Descuento_adicional__c = 10.0;
            listaQli.add(productEdit);
            
            QuoteLineItem productEdit1 = new QuoteLineItem();
            productEdit1.Quantity  = 2;
            productEdit1.QuoteId = cotizacion.Id;
            productEdit1.Product2Id = prod.Id;
            productEdit1.DescuentoSAP__c = 46.0;
            productEdit1.UnitPrice=500;
            productEdit1.Discount=66.0;     
            productEdit1.PoliticaDescuento__c=politicaDescuento.Id;
            productEdit1.Descuento_adicional__c = 13.0;
            productEdit1.PricebookEntryId=pbeSt.Id; 
            
            listaQli.add(productEdit1);
            
            QuoteLineItem productEdit2 = new QuoteLineItem();
            productEdit2.Quantity  = 2;
            productEdit2.QuoteId = cotizacion.Id;
            productEdit2.Product2Id = prod3.Id;
            productEdit2.DescuentoSAP__c = 46.0;
            productEdit2.UnitPrice=500;
            productEdit2.Discount=66.0;     
            productEdit2.PoliticaDescuento__c=politicaDescuento.Id;
            productEdit2.PricebookEntryId=pbe.Id; 
            productEdit2.Descuento_adicional__c = 14.0; 
                
                listaQli.add(productEdit2);
                Insert listaQli;
            }
            
        }
    }
    
    /******************************************************************* 
    Purpose: Test class method that Sync quotes with a Opportunity
    Parameters:
    Returns: 
    Throws :
    Information about changes (versions)
    ********************************************************************/
    @isTest
    public static void syncQuote_tst(){ 
        Quote quote = [SELECT Id, Name, Opportunity.SyncedQuoteId , pricebook2Id FROM Quote WHERE Name = 'Test SyncMobile'];
        Test.startTest();
        IMP_SyncingMobile_cc.DataWrapperSync incialData = IMP_SyncingMobile_cc.getQuote(quote.Id);
        Assert.isTrue(incialData.header=='Sincronizar cotización');
        IMP_SyncingMobile_cc.DataWrapperSync responseSync = IMP_SyncingMobile_cc.saveSync(quote,false);
        Assert.isTrue(responseSync.status=='SUCCESS');
        Quote quoteV2 = [SELECT Id, Name FROM Quote WHERE Name ='Test SyncMobile v2'];
        IMP_SyncingMobile_cc.DataWrapperSync newQuoteSync = IMP_SyncingMobile_cc.getQuote(quoteV2.Id);
        Assert.isTrue(newQuoteSync.header=='Reemplazar sincronización');
        IMP_SyncingMobile_cc.DataWrapperSync finalData = IMP_SyncingMobile_cc.getQuote(quote.Id);
        Assert.isTrue(finalData.header=='Detener sincronización');
        IMP_SyncingMobile_cc.saveSync(quote,true);
        Test.stopTest();
    }
    
    /******************************************************************* 
    Purpose: Test class method that Sync a Quote that generate exceptions.
    Parameters:
    Returns: 
    Throws :
    Information about changes (versions)
    ********************************************************************/
    @isTest
    public static void syncQuoteExceptions_tst(){ 
        Quote quote = [SELECT Id, Name, Opportunity.SyncedQuoteId , pricebook2Id FROM Quote WHERE Name = 'Test SyncMobile'];
        Test.startTest();
        Product2 product = [SELECT Id,Name FROM Product2 WHERE ProductCode ='IMP-12345'];
        product.IsActive = false;
        update product;
        IMP_SyncingMobile_cc.DataWrapperSync responseSync = IMP_SyncingMobile_cc.saveSync(quote,false);
        Assert.isTrue(responseSync.status=='ERROR');
        Assert.isTrue(responseSync.mensaje.contains('no se puede sincronizar porque tiene productos inactivos o archivados.'));
        IMP_SyncingMobile_cc.DataWrapperSync responseUnSync = IMP_SyncingMobile_cc.saveSync(null,true);
        Assert.isTrue(responseUnSync.status=='ERROR');
        Test.stopTest();
    }

}