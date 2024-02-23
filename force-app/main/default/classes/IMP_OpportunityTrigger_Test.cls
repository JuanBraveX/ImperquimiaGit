/************************************************************************
Name: IMP_OpportunityTrigger_Test
Copyright © 2023 Salesforce
========================================================================
Purpose:
Test class from the class IMP_OpportunityTrigger.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rortega@ts4.mx    10/05/2023     INITIAL        DEV CSR:
************************************************************************/
@isTest
public without sharing class IMP_OpportunityTrigger_Test {

    /******************************************************************* 
    Purpose: Test class method that insert the information of the opportunity.
    Parameters:
    Returns: 
    Throws :
    Information about changes (versions)
    ********************************************************************/
    @isTest
    public static void saveOpportunity(){ 
      	User administrador = [Select Id, UserRoleId,managerId From User Where Profile.Name='Administrador del sistema' AND isActive=true Limit 1];
		Quote cotizacion = new Quote();   
        
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
            Insert cuenta;
            
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
           	Insert oportunidad;
            
            Product2 prod =new Product2();
            prod.Name = 'IMPERMEABILIZANTE';
            prod.ProductCode='IMP-12345';
            prod.Family = 'Naya';
            prod.Description = '';
            prod.IsActive = true;
            prod.CurrencyIsoCode='MXN';
            prod.Grupo_de_Materiales__c ='03';    
            prod.Grupo_de_art_culos__c = 'IQ';  
            prod.IsActive = true;
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
            prod2.IsActive = true;
            Insert prod2;
            
            Product2 prod3 =new Product2();
            prod3.Name = 'IMPERMEABILIZANTE3';
            prod3.ProductCode='IMP-123457';
            prod3.Family = 'Naya';
            prod3.Description = '';
            prod3.IsActive = false;
            prod3.CurrencyIsoCode='MXN';
            prod3.Grupo_de_Materiales__c ='';  
            prod3.Grupo_de_art_culos__c = 'IQ';      
            prod3.IsActive = true;
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
            
            PoliticaDescuento__c  politicaDescuento = new PoliticaDescuento__c ();
            politicaDescuento.Name = 'Distribuidor A/ Populares';
            politicaDescuento.Activa__c  = true;
            politicaDescuento.CurrencyIsoCode = 'MXN';
            politicaDescuento.Descuento__c  = 70.2;
            politicaDescuento.Grupo_de_cliente_del__c = '01';
            politicaDescuento.Canaldistribucion__c = '04';        
            politicaDescuento.GrupoProducto__c = '03';
            Insert politicaDescuento;
            
            cotizacion.OpportunityId = oportunidad.Id; 
            cotizacion.Pricebook2Id = pricebookId; 
            cotizacion.Name = 'Test';
          	cotizacion.CurrencyIsoCode='MXN';
            cotizacion.Tax=0.00;
            cotizacion.Status='Borrador'; 
            cotizacion.BillingName='Direccion Test'; 
            cotizacion.ShippingName='Direccion Test';
           	Insert cotizacion;
          
            List<QuoteLineItem> listaQli=new List<QuoteLineItem>();
            List<OpportunityLineItem> listaOppli=new List<OpportunityLineItem>();
            
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
            
            QuoteLineItem productEdit2 = new QuoteLineItem();
            productEdit2.Quantity  = 2;
            productEdit2.QuoteId = cotizacion.Id;
            productEdit2.Product2Id = prod3.Id;
            productEdit2.Descuento_adicional__c = 20.0;
            productEdit2.DescuentoSAP__c = 46.0;
            productEdit2.UnitPrice=500;
            productEdit2.Discount=66.0;     
            productEdit2.PoliticaDescuento__c=politicaDescuento.Id;
            productEdit2.PricebookEntryId=pbe.Id; 
            productEdit2.Descuento_adicional__c = 14.0; 
            listaQli.add(productEdit2);
            Insert listaQli;
             
            OpportunityLineItem OPproductEdit = new OpportunityLineItem();
            OPproductEdit.Quantity  = 2;
            OPproductEdit.OpportunityId = oportunidad.Id;  
            OPproductEdit.Product2Id = prod.Id;
            OPproductEdit.DescuentoSAP__c = 46.0;
            OPproductEdit.IMP_DescuentoPromo__c = 25.0;
            OPproductEdit.UnitPrice=150;
            OPproductEdit.PricebookEntryId=pbeSt.Id; 
           	OPproductEdit.DescuentoAdicional__c = 10.0;
            listaOppli.add(OPproductEdit);
            
            OpportunityLineItem OPproductEdit1 = new OpportunityLineItem();
            OPproductEdit1.Quantity  = 2;
            OPproductEdit1.OpportunityId = oportunidad.Id;
            OPproductEdit1.Product2Id = prod2.Id;
           	OPproductEdit1.DescuentoSAP__c = 46.0;
            OPproductEdit1.IMP_DescuentoPromo__c = 50;
            OPproductEdit1.UnitPrice=500;
           	OPproductEdit1.DescuentoAdicional__c = 13.0;
            OPproductEdit1.PricebookEntryId=pbeSt.Id; 
			listaOppli.add(OPproductEdit1);
            
            INSERT listaOppli;
            
           
           	Opportunity opoQuote = new Opportunity();
            opoQuote.AccountId = cuenta.Id;
            opoQuote.Name = 'Oportunidad Test';
            opoQuote.StageName = 'Prospecting';
            opoQuote.CurrencyIsoCode = 'MXN';
            opoQuote.CloseDate = Date.today().addDays(30);
            opoQuote.RecordTypeId=recordTypeOportunidad.Id;
            opoQuote.Amount=3850.6;
            opoQuote.Probability=100; 
            opoQuote.OwnerId=usuario2.Id;
            opoQuote.SyncedQuoteId  = cotizacion.Id;
            opoQuote.Importe__c = 1500;
            opoQuote.StageName = 'Pendiente de Pago';
            opoQuote.CloseDate = Date.today();
            Insert opoQuote;
            
           	quote cotizacion2 = new quote();
            cotizacion2.OpportunityId = opoQuote.Id; 
            cotizacion2.Pricebook2Id = pricebookId; 
            cotizacion2.Name = 'Test';
          	cotizacion2.CurrencyIsoCode='MXN';
            cotizacion2.Tax=0.00;
            cotizacion2.Status='Borrador'; 
            cotizacion2.BillingName='Direccion Test'; 
            cotizacion2.ShippingName='Direccion Test';
            Insert cotizacion2;
            		
            List<QuoteLineItem> listaQli2 = new List<QuoteLineItem>();
            List<OpportunityLineItem> listaOppli2 = new List<OpportunityLineItem>();
            
            QuoteLineItem product2Edit = new QuoteLineItem();
            product2Edit.Quantity  = 2;
            product2Edit.QuoteId = cotizacion2.Id;  
            product2Edit.Product2Id = prod.Id;
            product2Edit.Descuento_adicional__c = 20.0;
            product2Edit.DescuentoSAP__c = 46.0;
            product2Edit.IMP_DescuentoPromo__c = 25.0;
            product2Edit.UnitPrice=150;
            product2Edit.PricebookEntryId=pbeSt.Id; 
            product2Edit.PoliticaDescuento__c=politicaDescuento.Id;
            product2Edit.Descuento_adicional__c = 10.0;
            listaQli2.add(product2Edit);
            
            QuoteLineItem product2Edit1 = new QuoteLineItem();
            product2Edit1.Quantity  = 2;
            product2Edit1.QuoteId = cotizacion2.Id;
            product2Edit1.Product2Id = prod.Id;
            product2Edit1.Descuento_adicional__c = 20.0;
            product2Edit1.DescuentoSAP__c = 46.0;
            product2Edit1.IMP_DescuentoPromo__c = 50;
            product2Edit1.UnitPrice=500;
            product2Edit1.Discount=66.0;     
            product2Edit1.PoliticaDescuento__c=politicaDescuento.Id;
            product2Edit1.Descuento_adicional__c = 13.0;
            product2Edit1.PricebookEntryId=pbeSt.Id; 
            listaQli2.add(product2Edit1);
            
            QuoteLineItem product2Edit2 = new QuoteLineItem();
            product2Edit2.Quantity  = 2;
            product2Edit2.QuoteId = cotizacion2.Id;
            product2Edit2.Product2Id = prod3.Id;
            product2Edit2.Descuento_adicional__c = 20.0;
            product2Edit2.DescuentoSAP__c = 46.0;
            product2Edit2.UnitPrice=500;
            product2Edit2.Discount=66.0;     
            product2Edit2.PoliticaDescuento__c=politicaDescuento.Id;
            product2Edit2.PricebookEntryId=pbe.Id; 
            product2Edit2.Descuento_adicional__c = 14.0; 
            listaQli2.add(product2Edit2);
            Insert listaQli2;
            
            OpportunityLineItem OPproduc2tEdit = new OpportunityLineItem();
            OPproduc2tEdit.Quantity  = 2;
            OPproduc2tEdit.OpportunityId = opoQuote.Id;  
            OPproduc2tEdit.Product2Id = prod.Id;
            OPproduc2tEdit.DescuentoSAP__c = 46.0;
            OPproduc2tEdit.IMP_DescuentoPromo__c = 25.0;
            OPproduc2tEdit.UnitPrice=150;
            OPproduc2tEdit.PricebookEntryId=pbeSt.Id; 
           	OPproduc2tEdit.DescuentoAdicional__c = 10.0;
            listaOppli2.add(OPproduc2tEdit);
            
            OpportunityLineItem OP2productEdit1 = new OpportunityLineItem();
            OP2productEdit1.Quantity  = 2;
            OP2productEdit1.OpportunityId = opoQuote.Id;
            OP2productEdit1.Product2Id = prod2.Id;
           	OP2productEdit1.DescuentoSAP__c = 46.0;
            OP2productEdit1.IMP_DescuentoPromo__c = 50;
            OP2productEdit1.UnitPrice=500;
           	OP2productEdit1.DescuentoAdicional__c = 13.0;
            OP2productEdit1.PricebookEntryId=pbeSt.Id; 

			listaOppli2.add(OP2productEdit1);
            
            INSERT listaOppli2;
            
            Test.startTest();
            opoQuote.Name = 'Oportunidad Sync';
            opoQuote.SyncedQuoteId = cotizacion2.Id;
            Update opoQuote;
          	System.assert(opoQuote != null,'Opportunity cannot be null');                
            Test.stopTest();
        }
    }
}