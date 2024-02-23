/************************************************************************
Name: IMP_DescuentosManager_tst
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test de la clase controller IMP_DescuentosManager
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
3.0      rotrejo@ts4.mx        13/04/2023   
************************************************************************/
@isTest
public class IMP_DescuentosManager_tst {
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
            cuenta.name = 'Cuenta Prueba';
            cuenta.RFC__c = '0011MYA12345';
            cuenta.CurrencyIsoCode = 'MXN';
            cuenta.centro_suministrador__c = 'AC01';
            cuenta.clave_delcanal__c = '02';
            cuenta.Phone='+52 7225398962';
            cuenta.OrganizacionVentas__c='IMPQ';
            cuenta.id_de_sap__c='0001032287';
            cuenta.ListaPrecios__c='03';
            cuenta.grupo__c='14';
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
            prod.ProductCode='10000307';
            prod.Family = 'Naya';
            prod.Description = '';
            prod.IsActive = true;
            prod.CurrencyIsoCode='MXN';
            prod.Grupo_de_Materiales__c ='03'; 
            prod.Grupo_de_art_culos__c='IMPERC';
            Insert prod;
            
            Product2 prod2 =new Product2();
            prod2.Name = 'IMPERMEABILIZANTE 2 ';
            prod2.ProductCode='10000308';
            prod2.Family = 'Naya';
            prod2.Description = '';
            prod2.IsActive = true;
            prod2.CurrencyIsoCode='MXN';
            prod2.Grupo_de_Materiales__c ='04';  
            prod2.Grupo_de_art_culos__c='IMPERC';
            Insert prod2;
            
            Product2 prod3 =new Product2();
            prod3.Name = 'IMPERMEABILIZANTE3';
            prod3.ProductCode='10000309';
            prod3.Family = 'Naya';
            prod3.Description = '';
            prod3.IsActive = false;
            prod3.CurrencyIsoCode='MXN';
            prod3.Grupo_de_Materiales__c ='';  
            prod3.Grupo_de_art_culos__c='IMPERC';
            Insert prod3;
            
            Id pricebookId = Test.getStandardPricebookId(); 
            
            Pricebook2 listaPrecios = new Pricebook2();
            listaPrecios.Name='AC01 - Distribuidor';
            listaPrecios.Sucursal__c='AC01';
            listaPrecios.CurrencyIsoCode='MXN';
            listaPrecios.IsActive=true;
            listaPrecios.Lista_de_precios_SAP__c='03';
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
            
            ///
            List<PricebookEntry> listpbe= new  List<PricebookEntry>();
            listpbe.add(new PricebookEntry(
                Pricebook2Id = listaPrecios.id,
                Product2Id = prod.Id,
                IsActive = true,
                CurrencyIsoCode='MXN',
                UnitPrice = 150,
                UseStandardPrice=false
            ));
            
            listpbe.add( new PricebookEntry(
                Pricebook2Id = listaPrecios.Id,
                Product2Id = prod2.Id,
                IsActive = true,
                CurrencyIsoCode='MXN',
                UnitPrice = 150,
                UseStandardPrice=false
            ));
            
            
            listpbe.add(new PricebookEntry(
                Pricebook2Id = listaPrecios.Id,
                Product2Id = prod3.Id,
                IsActive = true,
                CurrencyIsoCode='MXN',
                UnitPrice = 500,
                UseStandardPrice=false
            ));            
            insert listpbe;
            
            Quote cotizacion = new Quote();
            cotizacion.Name = 'COTI SEQ';
            cotizacion.OpportunityId = oportunidad.Id; 
            cotizacion.Pricebook2Id = listaPrecios.Id;
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
            productEdit.PricebookEntryId=listpbe[0].Id; 
            productEdit.PoliticaDescuento__c=politicaDescuento.Id;
            productEdit.Descuento_adicional__c = 10.0;
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
            productEdit1.Descuento_adicional__c = 13.0;
            productEdit1.PricebookEntryId=listpbe[1].Id; 
            
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
            productEdit2.PricebookEntryId=listpbe[2].Id; 
            productEdit2.Descuento_adicional__c = 14.0; 
            
            listaQli.add(productEdit2);
            Insert listaQli;
            
            Descuento__c descuentoSF = new Descuento__c(
                IMP_SecuenciaAcceso__c  = 'A999',
                IMP_ClaseCondicion__c = 'K00',
                IMP_IdExterno__c  ='0001');
            insert descuentoSF;
        }
         
    }
    /*******************************************************************
    Purpose: Covertura de la clase IMP_FlujoDocumentos al metodo getFacturasPedido with error
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getDescuento()
    {
        Quote quote = [SELECT Id,Account.clave_delcanal__c, Account.id_de_sap__c,Account.OrganizacionVentas__c,Pricebook2.Sucursal__c,Pricebook2.Lista_de_precios_SAP__c,Account.grupo__c FROM Quote WHERE Name ='COTI SEQ'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',getBodyDiscount(),null));
        IMP_DescuentosManager.upsertDiscounts();
        Test.stopTest();

        System.debug('Listado de Descuentos :: '+[SELECT ID FROM Descuento__c ].size());
        Assert.isTrue([SELECT ID FROM Descuento__c ].size()==7);
        IMP_DescuentosManager.WrapperSecuences MapSecuences=IMP_DescuentosManager.getDiscountByQuote(quote);

        IMP_DescuentosManager.WrapperSecuencesParam param305 = new IMP_DescuentosManager.WrapperSecuencesParam();
        param305.OrgVentas = quote.Account.OrganizacionVentas__c;
        param305.canalVentas = quote.Account.clave_delcanal__c;
        param305.numeroCliente = quote.Account.id_de_sap__c;
        param305.numeroMaterial = '10000307';
        Descuento__c d305 = IMP_DescuentosManager.getDiscountByToApply(param305, MapSecuences);
        Assert.isTrue(d305.IMP_SecuenciaAcceso__c=='A305');  
        
        IMP_DescuentosManager.WrapperSecuencesParam param999 = new IMP_DescuentosManager.WrapperSecuencesParam();
        param999.OrgVentas = quote.Account.OrganizacionVentas__c;
        param999.OficinaVentas = quote.Pricebook2.Sucursal__c;
        param999.ListaPrecios = quote.Pricebook2.Lista_de_precios_SAP__c;
        param999.numeroMaterial = '10000307';
        Descuento__c d999= IMP_DescuentosManager.getDiscountByToApply(param999, MapSecuences);
        Assert.isTrue(d999.IMP_SecuenciaAcceso__c=='A999'); 
        
        IMP_DescuentosManager.WrapperSecuencesParam param993 = new IMP_DescuentosManager.WrapperSecuencesParam();
        param993.GrupoClientes = quote.Account.grupo__c;
        param993.GrupoArticulos = 'IMPERC';
        Descuento__c d993= IMP_DescuentosManager.getDiscountByToApply(param993, MapSecuences);
        Assert.isTrue(d993.IMP_SecuenciaAcceso__c=='A993'); 
        
        IMP_DescuentosManager.WrapperSecuencesParam param996 = new IMP_DescuentosManager.WrapperSecuencesParam();
        param996.OrgVentas = quote.Account.OrganizacionVentas__c;
        param996.OficinaVentas = quote.Pricebook2.Sucursal__c;
        param996.ListaPrecios = quote.Pricebook2.Lista_de_precios_SAP__c;
        param996.numeroMaterial = '10000308';
        Descuento__c d996 = IMP_DescuentosManager.getDiscountByToApply(param996, MapSecuences);
        Assert.isTrue(d996.IMP_SecuenciaAcceso__c=='A996'); 

        IMP_DescuentosManager.WrapperSecuencesParam param997 = new IMP_DescuentosManager.WrapperSecuencesParam();
        param997.OrgVentas = quote.Account.OrganizacionVentas__c;
        param997.OficinaVentas = quote.Pricebook2.Sucursal__c;
        param997.GrupoClientes = quote.Account.grupo__c;
        param997.GrupoMateriales = '01';
        Descuento__c d997 = IMP_DescuentosManager.getDiscountByToApply(param997, MapSecuences);
        Assert.isTrue(d997.IMP_SecuenciaAcceso__c=='A997'); 
        
        IMP_DescuentosManager.WrapperSecuencesParam param940 = new IMP_DescuentosManager.WrapperSecuencesParam();
        param940.ClaseDoc = 'TA';
        Descuento__c d940 = IMP_DescuentosManager.getDiscountByToApply(param940, MapSecuences);
        Assert.isTrue(d940.IMP_SecuenciaAcceso__c=='A940'); 
    }
    
    public static String getBodyDiscount(){
         IMP_DescuentosManager newDiscounts = new IMP_DescuentosManager();
        List<IMP_DescuentosManager.T_A000> listA305 = new  List<IMP_DescuentosManager.T_A000>();
        List<IMP_DescuentosManager.T_A000> listA940 = new  List<IMP_DescuentosManager.T_A000>();
        List<IMP_DescuentosManager.T_A000> listA993 = new  List<IMP_DescuentosManager.T_A000>();
        List<IMP_DescuentosManager.T_A000> listA996 = new  List<IMP_DescuentosManager.T_A000>();
        List<IMP_DescuentosManager.T_A000> listA997 = new  List<IMP_DescuentosManager.T_A000>();
        List<IMP_DescuentosManager.T_A000> listA999 = new  List<IMP_DescuentosManager.T_A000>();

        IMP_DescuentosManager.T_A000 sA305 = new  IMP_DescuentosManager.T_A000();
        sA305.KSCHL='KA00';
        sA305.VKORG='IMPQ';
        sA305.VTWEG='02';
        sA305.KUNNR='0001032287';
        sA305.MATNR='10000307';
        sA305.DATAB='20230502';
        sA305.DATBI='99991231';
        sA305.KBETR='10';
        sA305.KONWA='%';
        sA305.KNUMH='sA305';
        listA305.add(sA305);
        IMP_DescuentosManager.T_A000 sA940 = new  IMP_DescuentosManager.T_A000();
        sA940.KSCHL='KA00';
        sA940.AUART_SD='TA';
        sA940.DATAB='20230502';
        sA940.DATBI='99991231';
        sA940.KBETR='10';
        sA940.KONWA='%';
        sA940.KNUMH='sA940';
        listA940.add(sA940);
        IMP_DescuentosManager.T_A000 sA993 = new  IMP_DescuentosManager.T_A000();
        sA993.KSCHL='KA00';
        sA993.KDGRP='14';
        sA993.MATKL='IMPERC';
        sA993.KUNNR='0001032287';
        sA993.MATNR='10000307';
        sA993.DATAB='20230502';
        sA993.DATBI='99991231';
        sA993.KBETR='10';
        sA993.KONWA='%';
        sa993.KNUMH='sA993';
        listA993.add(sA993);
        IMP_DescuentosManager.T_A000 sA996 = new  IMP_DescuentosManager.T_A000();
        sA996.KSCHL='KA00';
        sA996.VKORG='IMPQ';
        sA996.VKBUR='AC01';
        sA996.PLTYP='03';
        sA996.VTWEG='02';
        sA996.MATNR='10000308';
        sA996.DATAB='20230502';
        sA996.DATBI='99991231';
        sA996.KBETR='10';
        sA996.KONWA='%';
        sA996.KNUMH='sA996';
        listA996.add(sA996);
        IMP_DescuentosManager.T_A000 sA997 = new  IMP_DescuentosManager.T_A000();
        sA997.KSCHL='KA00';
        sA997.VKORG='IMPQ';
        sA997.VKBUR='AC01';
        sA997.KONDM='01';
        sA997.KDGRP='14';
        sA997.MATNR='10000307';
        sA997.DATAB='20230502';
        sA997.DATBI='99991231';
        sA997.KBETR='10';
        sA997.KONWA='%';
        sA997.KNUMH='sA997';
        listA997.add(sA997);
        IMP_DescuentosManager.T_A000 sA999 = new  IMP_DescuentosManager.T_A000();
        sA999.KSCHL='KA00';
        sA999.VKORG='IMPQ';
        sA999.VKBUR='AC01';
        sA999.KDGRP='01';
        sA999.PLTYP='03';
        sA999.MATNR='10000307';
        sA999.CHARG='0000105156';
        sA999.DATAB='20230502';
        sA999.DATBI='99991231';
        sA999.KBETR='10';
        sA999.KONWA='%';
        sA999.KNUMH='sA999';
        listA999.add(sA999);
        newDiscounts.T_A305= listA305;
        newDiscounts.T_A940= listA940;
        newDiscounts.T_A993= listA993;
        newDiscounts.T_A996= listA996;
        newDiscounts.T_A997= listA997;
        newDiscounts.T_A999= listA999;

        return JSON.serialize(newDiscounts);   
    }
}