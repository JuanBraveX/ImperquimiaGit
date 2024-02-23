/************************************************************************
Name: IMP_CreateOrder_Test
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test de la clase controller IMP_CreateOrder_CC
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
2.0      mvilchis@ts4.mx        29/03/2022   
3.0      rortega@ts4.mx         10/05/2025   
************************************************************************/
@isTest
public without sharing class IMP_CreateOrder_Test {
    /****************************************************************** 
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
            usuario.LanguageLocaleKey='es';
            usuario.ManagerId=administrador.Id;
            insert usuario;
            
            
            User usuario2 = new User();
            usuario2.Username ='usuarioprueba2@gmail.com';
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
            usuario2.ManagerId=administrador.Id;
            insert usuario2;
            
            Account cuenta = new Account();
            cuenta.OrganizacionVentas__c = 'IMPQ';
            cuenta.name = 'Cuenta Prueba';
            cuenta.id_de_sap__c = '0001032287';
            cuenta.RFC__c = '0011MYA12345';
            cuenta.CurrencyIsoCode = 'MXN';
            cuenta.centro_suministrador__c = 'AC01';
            cuenta.clave_delcanal__c = '02';
            cuenta.ListaPrecios__c='03';
            cuenta.grupo__c = '17';
            cuenta.Phone='+52 7225398962';
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
            prod.Grupo_de_art_culos__c = 'IQ';        
            Insert prod;
            
            Product2 prod2 =new Product2();
            prod2.Name = 'IMPERMEABILIZANTE 2 ';
            prod2.ProductCode='IMP-123456';
            prod2.Family = 'Naya';
            prod2.Description = '';
            prod2.IsActive = true;
            prod2.CurrencyIsoCode='MXN';
            prod2.Grupo_de_Materiales__c ='04'; 
            prod2.Grupo_de_art_culos__c = 'IQ';               
            Insert prod2;

            
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
            politicaDescuento.Grupo_de_cliente_del__c = '17';
            politicaDescuento.Canaldistribucion__c = '02';        
            politicaDescuento.GrupoProducto__c = '03';
            Insert politicaDescuento;
            
            List<QuoteLineItem> listaQli=new List<QuoteLineItem>();
            
            QuoteLineItem productEdit = new QuoteLineItem();
            productEdit.Quantity  = 2;
            productEdit.QuoteId = cotizacion.Id;  
            productEdit.Product2Id = prod.Id;
            productEdit.Descuento_adicional__c = 20.0;
            productEdit.DescuentoSAP__c = 46.0;
            productEdit.IMP_DescuentoPromo__c = 25.0;
            productEdit.UnitPrice=150;
            productEdit.PricebookEntryId=pbeSt.Id; 
            productEdit.PoliticaDescuento__c=politicaDescuento.Id;
            productEdit.Descuento_adicional__c = 10.0;
            listaQli.add(productEdit);
            
            QuoteLineItem productEdit1 = new QuoteLineItem();
            productEdit1.Quantity  = 2;
            productEdit1.QuoteId = cotizacion.Id;
            productEdit1.Product2Id = prod.Id;
            productEdit1.Descuento_adicional__c = 20.0;
            productEdit1.DescuentoSAP__c = 46.0;
            productEdit1.IMP_DescuentoPromo__c = 50;
            productEdit1.UnitPrice=500;
            productEdit1.Discount=66.0;     
            productEdit1.PoliticaDescuento__c=politicaDescuento.Id;
            productEdit1.Descuento_adicional__c = 13.0;
            productEdit1.PricebookEntryId=pbeSt.Id; 
            
            listaQli.add(productEdit1);
            

            Insert listaQli;

            Descuento__c descuento = new Descuento__c();
            descuento.IMP_SecuenciaAcceso__c = 'A993';
            descuento.IMP_OrganizacionVentas__c = 'IMPQ';
            descuento.IMP_ClaseCondicion__c = 'KA00';
            descuento.IMP_CanalVentas__c = '02';
            descuento.IMP_GrupoArticulos__c = 'IQ';
            descuento.IMP_GrupoClientes__c = '17';
            descuento.IMP_FechaInicial__c =  Date.newInstance(2023, 3, 29); 
            descuento.IMP_FechaFinal__c = Date.newInstance(2100, 12, 31);
            descuento.IMP_ImportePorcentaje__c = 20;
            descuento.IMP_UnidadCondicion__c = '%';
            Insert descuento;
            oportunidad.SyncedQuoteId=cotizacion.Id;
            update oportunidad;
        }
         
    }
    
    /*******************************************************************
    Purpose: Realiza la llamada al método getOpportunity para crear
    el pedido.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest public static void insertOpp(){
        Test.startTest();
        Opportunity opp = [SELECT Id,Name,AccountId,CloseDate,Pricebook2Id FROM Opportunity LIMIT 1];
        IMP_CreateOrder_CC.getOpportunity(opp.Id);
        Test.stopTest();
        List<Order> pedidos=[SELECT Id FROM Order WHERE OpportunityId=:opp.Id];
        System.assertEquals(1, pedidos.size(),'ok' );

    }
    /*******************************************************************
    Purpose: Realiza la llamada al método getOpportunity para crear
    el pedido con error.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest public static void validateOrder(){
        Test.startTest();
        Opportunity opp = [SELECT Id,Name,AccountId,CloseDate,Pricebook2Id FROM Opportunity LIMIT 1];
        delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId=:opp.Id];
        try {
            IMP_CreateOrder_CC.getOpportunity(opp.Id);
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(),'ok');
        }
        Test.stopTest();
        

    }
}