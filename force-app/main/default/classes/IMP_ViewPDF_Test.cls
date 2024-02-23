/************************************************************************
Name: IMP_ViewPDF_Test
Copyright © 2023 Salesforce
========================================================================
Purpose:
Test class from the class IMP_ViewPDF_Test.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rortega@ts4.mx    12/10/2023     INITIAL        DEV CSR:
************************************************************************/
@isTest
public class IMP_ViewPDF_Test {
    
	/******************************************************************* 
    Purpose: Inserts all information to run the class method.
    Information about changes (versions):
    ********************************************************************/
    @testSetup static void inicializaDatos() {
        try{
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
                                                 ListaPrecios__c='04', Proceso_Aprobado__c=false
                                                );
                Insert cuentaTest;
                
                RecordType oportunidadDistribucionRT=[SELECT Name, DeveloperName, sobjecttype, Id FROM RecordType where sobjectType='Opportunity' and DeveloperName='Oportunidad_BIMSA'];
                
                Opportunity oportunidadTest = new Opportunity(AccountId=cuentaTest.Id, RecordTypeId=oportunidadDistribucionRT.Id, 
                                                          Name='Oportunidad Test', StageName='Obra Negociada', Probability=100, 
                                                          CloseDate=date.today(), ForecastCategoryName='Closed', 
                                                          CurrencyIsoCode='MXN', Budget_Confirmed__c=false, Discovery_Completed__c=false, 
                                                          ROI_Analysis_Completed__c=false, OwnerId=usuario2.Id);
            	Insert oportunidadTest;
            
                Order pedido = new Order(Name='ORD-TEST', CurrencyIsoCode = 'MXN', 
                                         OpportunityId= oportunidadTest.Id, Pricebook2Id = listaPrecios.Id,Precio_Total__c = 500, 
                                         Status='Draft', AccountId = cuentaTest.Id, condiciones_de_pago__c = 'NT00'
                                         , EffectiveDate=Date.newInstance(2023, 04, 15)
                                         , ViaPago__c = 'C'
                                        );
                Insert pedido;
                
                Quote cotizacion = new Quote();
                cotizacion.Name = 'Test';
                cotizacion.OpportunityId = oportunidadTest.Id; 
                cotizacion.Pricebook2Id = listaPrecios.Id;
                cotizacion.CurrencyIsoCode='MXN';
                cotizacion.Tax=0.00;
                cotizacion.Status='Borrador'; 
                cotizacion.BillingName='Direccion Test'; 
                cotizacion.ShippingName='Direccion Test';
                Insert cotizacion;
            }
        }
        catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getCause());
            System.debug(ex.getLineNumber());
        }
    }
    
    /************************************************************************** 
    Purpose: Test the method to get the type of sboject
    Information about changes (versions)
    **************************************************************************/
    @isTest 
    public static void getObjectTypeNameOrder() {
        Order orderTest=[SELECT Id FROM Order WHERE Name='ORD-TEST' LIMIT 1];
		String idOrder =  orderTest.Id;       
        Test.startTest();
        String typeObjecto = IMP_ViewPDF_CC.getObjectTypeName(idOrder);
        System.assert(typeObjecto != null, '');
        Test.stopTest();
    }
    
    /************************************************************************** 
    Purpose: Test the method getPDF for create a record and saved it such as Order.
    Information about changes (versions)
    **************************************************************************/
    @isTest 
    public static void getPDFTestOrder() {
        Order orderTest=[SELECT Id FROM Order WHERE Name='ORD-TEST' LIMIT 1];
		String idOrder =  orderTest.Id;       
        Test.startTest();
        String idPdf = IMP_ViewPDF_CC.getPDF(idOrder, 'Order');
        System.assert(idPdf != null, '');
        Test.stopTest();
    }
    
    /************************************************************************** 
    Purpose: Test the method getPDF for create a record and saved it such as Quote.
    Information about changes (versions)
    **************************************************************************/
    @isTest 
    public static void getPDFTestQuote() {
        Quote quoteTest=[SELECT Id FROM Quote WHERE Name='Test' LIMIT 1];
		String idQuote =  quoteTest.Id;       
        Test.startTest();
        String idPdf = IMP_ViewPDF_CC.getPDF(idQuote, 'Quote');
        System.assert(idPdf != null, '');
        Test.stopTest();
    }
}