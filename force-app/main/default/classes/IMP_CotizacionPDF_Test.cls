/************************************************************************
Name: IMP_CotizacionPDF_Test
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test class from the class IMP_CotizacionPDF_CC.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      mmauro@ts4.mx    20/01/2021     INITIAL        DEV CSR:
************************************************************************/
@isTest
public class IMP_CotizacionPDF_Test { 
    /******************************************************************* 
    Purpose: Inserts all information to run the class method.
    Information about changes (versions):
    ********************************************************************/
    @testSetup static void inicializaDatos() {
        User administrador = [Select Id, UserRoleId From User Where Profile.Name='Administrador del sistema' AND isActive=true Limit 1];
        System.runAs(administrador){
            Profile perfilUser=[SELECT Name, Id FROM Profile WHERE Name='Administrador del sistema'];
            
            User usuario = new User();
            usuario.Username ='usuarioprueba19958@gmail.com';
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
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Pricebook2 listaPrecios = new Pricebook2(Name='AC01 - Mostrador', CurrencyIsoCode='MXN', 
                                                     IsActive=false, Description='Acapulco',Sucursal__c='AC01', 
                                                     Lista_de_precios_SAP__c='03');
            insert listaPrecios;
            Account cuentaTest = new Account(Name='Cuenta Prueba', BillingStreet='33 Calle Bahía de las Palmas', 
                                             BillingCity='Ciudad de México', BillingPostalCode='11300', BillingCountry='México', Phone='5523456783', 
                                             CurrencyIsoCode='MXN',
                                             clave_delcanal__c='04', centro_suministrador__c='AC01', grupo__c='08', 
                                             Condicion_de_expedicion__c='01', prioridad_de_entrega__c='02', 
                                             RFC__c='0011MYA12345', Esquema_cliente__c='1', Grupo_de_Cuentas__c='121000', 
                                             Grupo_de_precios__c='02', grupo_de_tesoreria__c='Y01', Sector__c='10',
                                             CorreoElectronico__c='cuentaprueba@gmail.com', 
                                             ListaPrecios__c='04', Proceso_Aprobado__c=false, 
                                             Lista_de_Precios_SF__c=listaPrecios.Id);
            insert cuentaTest;
            RecordType oportunidadDistribucionRT=[SELECT Name, DeveloperName, sobjecttype, Id FROM RecordType where sobjectType='Opportunity' and DeveloperName='Oportunidad_BIMSA'];
            System.runAs(usuario2) {
                Opportunity oportunidadTest = new Opportunity(AccountId=cuentaTest.Id, RecordTypeId=oportunidadDistribucionRT.Id, 
                                                            Name='Oportunidad Test', StageName='Obra Negociada', Probability=100, 
                                                            CloseDate=date.today(), ForecastCategoryName='Closed', 
                                                            CurrencyIsoCode='MXN', Budget_Confirmed__c=false, Discovery_Completed__c=false, 
                                                            ROI_Analysis_Completed__c=false,OwnerId=usuario2.Id);
                insert oportunidadTest;
                Product2 productoTest = new Product2(Name='Productoprueba', ProductCode='1234', 
                                                    Description='Producto de prueba', IsActive=true, 
                                                    Family='None', CurrencyIsoCode='MXN', Peso__c=2);
                insert productoTest;
                
                PricebookEntry entradaListaPrecios0 = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=productoTest.Id, 
                                                                        CurrencyIsoCode='MXN', UnitPrice=0, IsActive=false, UseStandardPrice=false);
                insert entradaListaPrecios0;
                PricebookEntry entradaListaPrecios = new PricebookEntry(Pricebook2Id=listaPrecios.Id, Product2Id=productoTest.Id, 
                                                                        CurrencyIsoCode='MXN', UnitPrice=150.00, IsActive=true, UseStandardPrice=false);
                insert entradaListaPrecios;
                Quote cotizacionTest = new Quote(Name='COT-TEST', CurrencyIsoCode='MXN',
                                                OpportunityId=oportunidadTest.Id, Pricebook2Id=listaPrecios.Id, 
                                                Status='Aceptada', BillingName='Cuenta Prueba', PrecioTotal__c =500,Tax =200,
                                                ShippingName='Cuenta Prueba', CanCreateQuoteLineItems=false);
                insert cotizacionTest;
                QuoteLineItem partidaQuote = new QuoteLineItem(QuoteId=cotizacionTest.Id, 
                                                            PricebookEntryId=entradaListaPrecios.Id, Quantity=5.00, UnitPrice=150.00, 
                                                            Product2Id=productoTest.Id);
                insert partidaQuote;
            }
        }
        
    }
    /************************************************************************** 
    Purpose: Complete the information obtained in the general class.
    Information about changes (versions)
    **************************************************************************/
    @isTest 
    public static void cotizacionPDFTest() {
        Quote cotizacionTest=[SELECT Id FROM Quote WHERE Name='COT-TEST' LIMIT 1];
        
        Test.startTest();
            Test.setCurrentPage(new PageReference('/apex/IMP_CotizacionPDF?id='+cotizacionTest.Id));
            IMP_CotizacionPDF_CC pdf = new IMP_CotizacionPDF_CC();
            String idPdf = ApexPages.currentPage().getParameters().get('id');
            System.assert(idPdf != null, '');
        Test.stopTest();
    }
    /************************************************************************** 
    Purpose: Completes the part of the catch that is obtained in the 
    general class.
    Information about changes (versions)
    **************************************************************************/
    @isTest 
    public static void cotizacionPDFErrTest() {
        Test.startTest();
            Test.setCurrentPage(new PageReference('/apex/IMP_CotizacionPDF?id=null'));
            IMP_CotizacionPDF_CC pdfError=new IMP_CotizacionPDF_CC();
            String idPdf2 = ApexPages.currentPage().getParameters().get('id');
            System.assert(idPdf2 == 'null', '');
        Test.stopTest();
    }
}