/************************************************************************
Name: IMP_EjecutarJobs_tst
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test del controlador IMP_EjecutarJobs_cc
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    13/04/2023     INITIAL        DEV CSR:
************************************************************************/
@isTest
public class IMP_EjecutarJobs_tst {
    /*******************************************************************
    Purpose: Inserta datos de prueba
    Information about changes (versions) []:
    ********************************************************************/
    @testSetup static void inicializarDatos()
    {
        List<Product2> listProds = new  List<Product2>();
        for(Integer i = 1 ; i<= 20 ; i++){
            listProds.add(new Product2(Name='GUARDQUIM POLI RA 28, 18LT z'+i, ProductCode='1000010'+i, Family='2200 - MATIX', 
                                       CurrencyIsoCode='USD', sku__c =10000686+i));
        }
        insert listProds;
        Pricebook2  listaPrecios= new Pricebook2(Name='MIXC-Mostrador',CurrencyIsoCode='MXN',  Description ='Mixcoac',
                                                 Sucursal__c='MIXC',Lista_de_precios_SAP__c='03');
        insert listaPrecios;
        Pricebook2 pricebook= new Pricebook2();
        pricebook.Id=Test.getStandardPricebookId();
        pricebook.Description='AC01';
        update pricebook;
        List<PricebookEntry> listPricebooks = new  List<PricebookEntry>();
        listPricebooks.add(new PricebookEntry(Product2Id=listProds[0].Id,Pricebook2Id=pricebook.Id,UnitPrice=0));
        listPricebooks.add(new PricebookEntry(Product2Id=listProds[1].Id,Pricebook2Id=pricebook.Id,UnitPrice=0));
        listPricebooks.add(new PricebookEntry(Product2Id=listProds[0].Id,Pricebook2Id=listaPrecios.Id,UnitPrice=1000,IdExterno__c=listProds[0].Id+'/'+listaPrecios.Name));
        insert listPricebooks;
        
        Account cuenta = new Account();
        cuenta.name = 'Cuenta Prueba';
        cuenta.RFC__c = '0011MYA12345';
        cuenta.CurrencyIsoCode = 'MXN';
        cuenta.centro_suministrador__c = 'AC01';
        cuenta.clave_delcanal__c = '04';
        cuenta.grupo__c = '01';
        cuenta.Sector__c='10';
        cuenta.id_de_sap__c='0001000193';
        cuenta.OrganizacionVentas__c='IMPQ';
        insert cuenta;

        Product2 prod =new Product2();
        prod.Name = 'IMPERMEABILIZANTE';
        prod.ProductCode='10000321';
        prod.Family = 'Naya';
        prod.Description = '';
        prod.IsActive = true;
        prod.CurrencyIsoCode='MXN';
        prod.Grupo_de_Materiales__c ='03';            
        Insert prod;
        
        PricebookEntry entradaListaPreciosTest=new PricebookEntry( Pricebook2Id=pricebook.Id, 
                                                                  Product2Id=prod.Id, CurrencyIsoCode='MXN', UnitPrice=100,UseStandardPrice=false,isActive=true);
        insert entradaListaPreciosTest;
        
        Order pedido = new Order();
        pedido.AccountId = cuenta.Id;
        pedido.Pricebook2Id=pricebook.Id;
        pedido.pedido__c  ='0001036225';
        pedido.EffectiveDate=Date.today();
        pedido.Status ='Draft';
        insert pedido;    
        
        OrderItem prodPedido = new OrderItem();
        prodPedido.Product2Id=prod.Id;
        prodPedido.OrderId=pedido.Id;
        prodPedido.PricebookEntryId=entradaListaPreciosTest.Id;
        prodPedido.Quantity=1520.00;
        prodPedido.UnitPrice=100;
        prodPedido.ListPrice=100;
        prodPedido.IMP_Posicion__c=10;
        prodPedido.IMP_LlaveExclusiva__c='0001036225-10-10000321';
        
        insert prodPedido;
    }
        
     /*******************************************************************
    Purpose: Covertura de la clase IMP_EjecutarJobs al metodo getPrices
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getPricesTest()
    {
        List<IMP_PriceManager.cls_MATPRECIO> listaProductos= new List<IMP_PriceManager.cls_MATPRECIO>();
        for(Product2 prod : [SELECT Id, ProductCode FROM Product2 Limit 20]){
            IMP_PriceManager.cls_MATPRECIO prodResponse = new IMP_PriceManager.cls_MATPRECIO();
            prodResponse.VKBUR='MIXC';
            prodResponse.PLTYP='03';
            prodResponse.MATNR=prod.ProductCode;
            prodResponse.NETWR=Decimal.valueof((Math.random() * 10000));
            prodResponse.KONWA='MXN';
            listaProductos.add(prodResponse);
        }
        IMP_PriceManager respuesta = new IMP_PriceManager();
        respuesta.MATPRECIO=listaProductos;
        String body=JSON.serialize(respuesta);        
        
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_EjecutarJobs_cc.getPrices();
        System.assertEquals(1, [SELECT id FROM PricebookEntry WHERE Pricebook2.Name='MIXC-Mostrador'].Size(),'ok');
        Test.stopTest();
    }
    
    /******************************************************************
    Purpose: Se inserta información de un producto y se realiza la llamada
    al servicio para actualizar.
    Information about changes (versions) []:
    ********************************************************************/
	@isTest
    public static void materialesWS() {

        Test.startTest();
        String body='{"IT_MATERIALES": [{"MATNR": "000000000010000637","WERKS": "SATE","MAKTX": "ELASTON 4 ROJO, 19LT","KONWA": "","MATKL": "IMPERC","KONDM": "08","SKU": "000000000010000637","TAXKM": "","PLTYP": "","MEINS": "UN","LVORM": ""},{"MATNR": "000000000010000640","WERKS": "","MAKTX": "ELASTON 4 BLANCO DOBLE ACCION, 19LT","KONWA": "","MATKL": "IQ","KONDM": "03","SKU": "000000000010000640","TAXKM": "","PLTYP": "","MEINS": "UN","LVORM": "X"},{"MATNR": "000000000010000247","WERKS": "SATE","MAKTX": "GUARDQUIM EPOXI 630 AQUA TRANSPAREN, 4LT","KONWA": "","MATKL": "GUARQM","KONDM": "03","SKU": "000000000010000247","TAXKM": "","PLTYP": "","MEINS": "UN","LVORM": "X"}]}';
        Date fechaInicial=Date.today();
        Date fechaFinal=Date.today();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(200, 'OK', body, null));
        IMP_EjecutarJobs_cc.getMateriales(fechaInicial,fechaFinal);
        System.assertEquals(true, [SELECT id FROM Product2 ].Size()>0,'ok');
        Test.stopTest();
    }
    
    /*******************************************************************
    Purpose: Covertura de la clase IMP_EjecutarJobs al metodo getFacturas
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getFacturasPedido()
    {
        Test.startTest();
        Order pedido = [SELECT Id,pedido__c FROM Order Limit 1];
        IMP_FlujoDocumentos.getPedido(pedido.Id);
        String body= getBodyDocs();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Date fechaInicial=Date.today();
        Date fechaFinal=Date.today();
        IMP_FlujoDocumentos.Wrapper wrapper = IMP_EjecutarJobs_cc.getFacturas(fechaInicial,fechaFinal);
        Assert.isTrue(wrapper.noFacturas== 10);
        try{
            IMP_EjecutarJobs_cc.getFacturas(fechaInicial,fechaFinal+10);
        }catch(Exception ex){
            Assert.isTrue('Script-thrown exception'== ex.getMessage());
        }
        Test.stopTest();
    }
    
    
    /*******************************************************************
    Purpose: Covertura de la clase IMP_EjecutarJobs al metodo getFacturas
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getDescuentos(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',getBodyDiscount(),null)); 
        IMP_EjecutarJobs_cc.getDescuentos();
        Test.stopTest();
        
    }
    
       /*******************************************************************
    Purpose: Covertura de la clase IMP_EjecutarJobs al metodo getFacturas
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getPedidos(){
        Date fechaInicial=Date.today();
        Date fechaFinal=Date.today();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok','{"IT_PEDIDOS":[{"E_VBELN":"0000630351","ZLSCH":"C","AUART":"TA","I_VKBUR":"AC01","I_VKORG":"IMPQ","SPART":"10","I_KUNNR":"0001042355","I_VKGRP":"001","BEZEI":"Metropolitan","LTEXT":"ACAPULCO","PRCTR":"AV5402302","NETWR":"             6618.06","ERNAM":"SFUSER","GBSTK":"A","ZTERM":"NT00","I_VTWEG":"02","BSTDK":"20230504","EXT1":"AC01","EXT2":""}]}',null)); 
        IMP_EjecutarJobs_cc.getPedidos(fechaInicial,fechaFinal);
        Test.stopTest();
    }

    
    /*******************************************************************
    Purpose: Covertura de la clase IMP_Documentos_Shedule 
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getSheduleDocs()
    {
        DateTime fecha=System.now();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',getBodyDocs(),null)); 
        Test.startTest();
        String hora = '0 0 0 '+fecha.day()+' '+ fecha.month()+' ? ';
        String jobId = System.schedule('IMP_Documentos_Shedule',
                                       hora,
                                       new IMP_Documentos_Shedule());      
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        Assert.isTrue(ct.TimesTriggered==0);
        Test.stopTest();
    }
    
        /*******************************************************************
    Purpose: Covertura de la clase IMP_Documentos_Shedule 
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getSheduleDiscounts()
    {
        DateTime fecha=System.now();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',getBodyDiscount(),null)); 
        String hora = '0 0 0 '+fecha.day()+' '+ fecha.month()+' ? ';
        String jobId = System.schedule('IMP_Descuentos_Shedule',
                                       hora,
                                       new IMP_Descuentos_Shedule());      
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        Assert.isTrue(ct.TimesTriggered==0);
        Test.stopTest();
    }
    
    public static String getBodyDocs(){
        IMP_FlujoDocumentos respuesta = new IMP_FlujoDocumentos();
        List<IMP_FlujoDocumentos.T_FAC_PED> listFactsResponse = new  List<IMP_FlujoDocumentos.T_FAC_PED>();
        for(Integer i=0;i < 10; i++){
            IMP_FlujoDocumentos.T_FAC_PED factura = new IMP_FlujoDocumentos.T_FAC_PED();
            factura.AUBEL='0001036225';
            factura.FKDAT='2021-01-02';
            factura.FKART = 'F2';
            factura.VBELN = '0090472129'+i;
            factura.NETWR = 0.0;
            factura.ERNAM = 'CUERNAVACAF1';
            factura.VTWEG_AUFT='04';
            factura.KUNAG = '0001000193';
            factura.NAME1='NAYELI LUCIANA ORTIZ LOPEZ';
            factura.NAME2= '';
            factura.NAME3= '';
            factura.NAME4= '';
            factura.VKGRP='001';
            factura.ZTERM='NT00';
            factura.PRCTR='AV5501301';
            factura.SPART='10';
            factura.BEZEI='ADN ZONA 6';
            factura.LTEXT= 'ADN ZONA 6';        
            factura.VKORG_AUFT='IMPQ';
            factura.POSNR='10';
            factura.MATNR='000000000010000321';
            factura.GBSTK='C';
            listFactsResponse.add(factura);
        }
        
        respuesta.T_FAC_PED=listFactsResponse;
        return JSON.serialize(respuesta); 
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