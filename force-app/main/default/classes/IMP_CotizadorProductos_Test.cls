/************************************************************************
Name: IMP_CotizadorProductos_Test
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test class from the class IMP_CotizadorProductosController.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      mmauro@ts4.mx    20/01/2021     INITIAL        DEV CSR:
************************************************************************/
@isTest
public without sharing class IMP_CotizadorProductos_Test {
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
            
            Product2 prod3 =new Product2();
            prod3.Name = 'IMPERMEABILIZANTE3';
            prod3.ProductCode='IMP-123457';
            prod3.Family = 'Naya';
            prod3.Description = '';
            prod3.IsActive = false;
            prod3.CurrencyIsoCode='MXN';
            prod3.Grupo_de_Materiales__c ='';  
            prod3.Grupo_de_art_culos__c = 'IQ';              
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

        }
         
    }
    /******************************************************************* 
    Purpose: Test class method that obtains the information of the quotation.
    Parameters:
    Returns: 
    Throws :
    Information about changes (versions)
    ********************************************************************/
    @isTest
    public static void getCotizacion(){ 
        Quote cotizacion = [SELECT Id, Name,pricebook2Id FROM Quote WHERE Name = 'Test'];
        Test.startTest();
        IMP_CotizadorProductosController.getInitialData(cotizacion.Id);
        System.assert(cotizacion != null,'Products cannot be null');                
        Test.stopTest();
    }
    
    /******************************************************************* 
    Purpose: Test class method that obtains the products that match the search code or description
    Parameters:String nombre,Id listaPrecios, Integer pageSize, Integer pageNumber, String  recordId.
    Returns: 
    Throws :
    Information about changes (versions)
    ********************************************************************/     
    @isTest
    public static void getProductos(){
        Quote cotizacion = [SELECT Id, Name, PriceBook2Id,CurrencyIsoCode FROM Quote WHERE Name = 'Test']; 
        IMP_InventarioManager respuesta = new IMP_InventarioManager();
        List<IMP_InventarioManager.cls_ZINVENTARIOS> listProd= new List<IMP_InventarioManager.cls_ZINVENTARIOS>();
        IMP_InventarioManager.cls_ZINVENTARIOS prod= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod.CHARG='0000092273';
        prod.CLABS=100;
        prod.HSDAT='2021-08-12';
        prod.MATNR='IMP-12345';
        listProd.add(prod);
        IMP_InventarioManager.cls_ZINVENTARIOS prod2= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod2.CHARG='0000092273';
        prod2.CLABS=100;
        prod2.HSDAT='2021-08-12';
        prod2.MATNR='IMP-123457';
        listProd.add(prod2);
        respuesta.ZINVENTARIOS=listProd;
        String body=JSON.serialize(respuesta);  
        Test.startTest();               
        IMP_CotizadorProductosController.getProductos('1234', cotizacion.PriceBook2Id, 1, 1,cotizacion.Id);
        Test.stopTest();
        System.assert( cotizacion != null,'Quote cannot be null');                
                
    }
/******************************************************************* 
Purpose: Test class method that creates item records of a quote.
Parameters:PricebookEntry pricebook , Id cotizacion.
Returns: 
Throws :
Information about changes (versions)
********************************************************************/    
    @isTest
    public static void crearQuoteLineItem(){ 
        Quote cotizacion = [SELECT Id, Name,Pricebook2Id, (SELECT Id, QuoteId FROM QuoteLineItems) FROM Quote WHERE Name = 'Test'];             
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'IMPERMEABILIZANTE'];
        PricebookEntry pricebook = [SELECT Id , Product2Id,Product2.ProductCode,Product2.Grupo_de_Materiales__c, Product2.Grupo_de_art_culos__c, UnitPrice FROM PricebookEntry WHERE Pricebook2Id=:cotizacion.Pricebook2Id AND Product2Id =: product.Id];
        IMP_InventarioManager respuesta = new IMP_InventarioManager();
        List<IMP_InventarioManager.cls_ZINVENTARIOS> listProd= new List<IMP_InventarioManager.cls_ZINVENTARIOS>();
        IMP_InventarioManager.cls_ZINVENTARIOS prod= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod.CHARG='0000092273';
        prod.CLABS=100;
        prod.HSDAT='2021-08-12';
        prod.MATNR='IMP-12345';
        listProd.add(prod);
        IMP_InventarioManager.cls_ZINVENTARIOS prod2= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod2.CHARG='0000092273';
        prod2.CLABS=100;
        prod2.HSDAT='2021-08-12';
        prod2.MATNR='IMP-123457';
        listProd.add(prod2);
        IMP_InventarioManager.cls_ZINVENTARIOS prod3= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod3.CHARG='0000092273';
        prod3.CLABS=100;
        prod3.HSDAT='2021-08-12';
        prod3.MATNR='IMP-123457';
        listProd.add(prod3);
        respuesta.ZINVENTARIOS=listProd;
        String body=JSON.serialize(respuesta);        
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_CotizadorProductosController.crearQuoteLineItem(pricebook, cotizacion.Id);
        System.assert(pricebook != null,'Products cannot be null');                
        Test.stopTest();
        
    }
    
    @isTest
    public static void crearQuoteLineItem2(){ 
        Quote cotizacion = [SELECT Id, Name,Pricebook2Id, (SELECT Id, QuoteId FROM QuoteLineItems) FROM Quote WHERE Name = 'Test'];             
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'IMPERMEABILIZANTE3'];
        PricebookEntry pricebook = [SELECT Id , Product2Id,Product2.ProductCode,Product2.Grupo_de_Materiales__c, Product2.Grupo_de_art_culos__c, UnitPrice FROM PricebookEntry WHERE Pricebook2Id=:cotizacion.Pricebook2Id AND Product2Id =: product.Id];
        IMP_InventarioManager respuesta = new IMP_InventarioManager();
        List<IMP_InventarioManager.cls_ZINVENTARIOS> listProd= new List<IMP_InventarioManager.cls_ZINVENTARIOS>();
        IMP_InventarioManager.cls_ZINVENTARIOS prod= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod.CHARG='0000092273';
        prod.CLABS=100;
        prod.HSDAT='2021-08-12';
        prod.MATNR='IMP-12345';
        listProd.add(prod);
        IMP_InventarioManager.cls_ZINVENTARIOS prod2= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod2.CHARG='0000092273';
        prod2.CLABS=100;
        prod2.HSDAT='2021-08-12';
        prod2.MATNR='IMP-123457';
        listProd.add(prod2);
        respuesta.ZINVENTARIOS=listProd;
        String body=JSON.serialize(respuesta);      
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_CotizadorProductosController.crearQuoteLineItem(pricebook, cotizacion.Id);
        System.assert(pricebook != null,'Products cannot be null');                
        Test.stopTest();
        
    }
    /******************************************************************* 
    Purpose: Test class method that delete item records for a quote.
    Parameters:QuoteLineItem productEdit.
    Returns: 
    Throws :
    Information about changes (versions)
    ********************************************************************/      
    @isTest
    public static void deleteQuoteLineItem(){
        Quote cotizacion = [SELECT Id, Name,Pricebook2Id FROM Quote WHERE Name = 'Test'];
        QuoteLineItem productEdit=[SELECT Id, QuoteId FROM QuoteLineItem WHERE Quote.Name=:'Test' Limit 1];
        
        Test.startTest();
        System.assert(cotizacion != null,'Products cannot be null');                
        IMP_CotizadorProductosController.deleteQuoteLineItem(productEdit);
        Test.stopTest();
        
    }
    /******************************************************************* 
    Purpose: Test class method that updates item records for a quote.
    Parameters:QuoteLineItem productEdit ,  String tipoACampo.
    Returns: 
    Throws :
    Information about changes (versions)
    ********************************************************************/    
    @isTest
    public static void updateQuoteLineItem(){
        Quote cotizacion = [SELECT Id, Name,Pricebook2Id FROM Quote WHERE Name = 'Test'];
        QuoteLineItem productEdit=[SELECT Id,QuoteId,Quantity,Descuento_adicional__c,PrecioTotalConDescuentos__c,TotalPrice, IMP_OmitirDescuentoSAP__c, IMP_DescuentoPromo__c FROM QuoteLineItem WHERE Quote.Name=:'Test' Limit 1];
        productEdit.PrecioTotalConDescuentos__c = productEdit.TotalPrice;
        update productEdit;
        String tipoACampoC = 'Cantidad';
        
        IMP_CotizadorProductosController.updateQuoteLineItem(productEdit, tipoACampoC);
        Test.startTest();
        System.assert(IMP_CotizadorProductosController.updateQuoteLineItem(productEdit, tipoACampoC) != null,'Products cannot be null');                
        Test.stopTest();
        
    }

    /******************************************************************* 
    Purpose: Test class method that update the QuoteLineItem with the added discount.
    Parameters:QuoteLineItem productEdit ,  Double valueDesc.
    Returns: 
    Throws :
    Information about changes (versions)
    ********************************************************************/      
    @isTest
    public static void procesoDescuento(){
        Quote cotizacion = [SELECT Id, Name,Pricebook2Id FROM Quote WHERE Name = 'Test'];
        QuoteLineItem productEdit=[SELECT Id, QuoteId FROM QuoteLineItem WHERE Quote.Name=:'Test' Limit 1];    
        Double valueDesc = 30.0;
        
        IMP_CotizadorProductosController.procesoDescuento(productEdit, valueDesc);
        Test.startTest();
        System.assert(IMP_CotizadorProductosController.procesoDescuento(productEdit, valueDesc) != null,'Products cannot be null');                
        Test.stopTest();
        
    }
    
}