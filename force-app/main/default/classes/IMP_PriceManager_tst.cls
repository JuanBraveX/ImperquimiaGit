/************************************************************************
Name: IMP_PriceManager_tst
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test del controlador IMP_PriceManager
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    11/04/2022     INITIAL        DEV CSR:
************************************************************************/
@isTest
public class IMP_PriceManager_tst {
    
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
        update pricebook;
        List<PricebookEntry> listPricebooks = new  List<PricebookEntry>();
        listPricebooks.add(new PricebookEntry(Product2Id=listProds[0].Id,Pricebook2Id=pricebook.Id,UnitPrice=0));
        listPricebooks.add(new PricebookEntry(Product2Id=listProds[1].Id,Pricebook2Id=pricebook.Id,UnitPrice=0));
        listPricebooks.add(new PricebookEntry(Product2Id=listProds[0].Id,Pricebook2Id=listaPrecios.Id,UnitPrice=1000,IdExterno__c=listProds[0].Id+'/'+listaPrecios.Name));
        insert listPricebooks;
    }
    
    /*******************************************************************
    Purpose: Covertura de la clase IMP_PriceManager al metodo getPrices
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
        IMP_PriceManager.getPrices();
        System.assertEquals(1, [SELECT id FROM PricebookEntry WHERE Pricebook2.Name='MIXC-Mostrador'].Size(),'ok');
        Test.stopTest();
    }
    
    
        /*******************************************************************
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
        IMP_PriceManager.getMateriales(fechaInicial,fechaFinal);
        System.assertEquals(true, [SELECT id FROM Product2 ].Size()>0,'ok');
        Test.stopTest();
    }
    
    /*******************************************************************
    Purpose: Se inserta información de un producto y se realiza la llamada
    al servicio para actualizar.
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void priceJOBTest() {
        
        DateTime fecha=System.now();
        String hora = '0 0 0 '+fecha.day()+' '+ fecha.month()+' ? ';
        Test.startTest();
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
        
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(200, 'OK', body, null));
        String jobId = System.schedule('SCHEDULER PRECIOS',hora,new IMP_PriceJOB());  
        System.assertEquals(1, [SELECT id FROM PricebookEntry WHERE Pricebook2.Name='MIXC-Mostrador'].Size(),'ok');
        Test.stopTest();
    }
}