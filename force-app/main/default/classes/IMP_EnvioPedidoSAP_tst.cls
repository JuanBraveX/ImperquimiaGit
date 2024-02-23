/************************************************************************
Name: IMP_EnvioPedidoSAP_tst
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test del controlador IMP_EnvioPedidoSAP
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    11/04/2022     INITIAL        DEV CSR:
************************************************************************/
@isTest
public without sharing class IMP_EnvioPedidoSAP_tst {
    
    /*******************************************************************
    Purpose: Inserta datos de prueba
    Information about changes (versions) []:
    ********************************************************************/
    @testSetup static void inicializarDatos()
    {
        List<PricebookEntry> entradasPrecios = new  List<PricebookEntry>();
        List<PricebookEntry> entradasPreciosEstandar = new  List<PricebookEntry>();
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
        
        for(Product2 prod : [SELECT Id FROM Product2]){
            entradasPreciosEstandar.add(new PricebookEntry(Product2Id=prod.Id,Pricebook2Id=pricebook.Id,UnitPrice=0));
        }
        insert entradasPreciosEstandar;
        for(Product2 prod : [SELECT Id FROM Product2]){
            entradasPrecios.add(new PricebookEntry(Pricebook2Id=listaPrecios.Id,Product2Id=prod.Id,
                                                   CurrencyIsoCode='MXN',IsActive=true,
                                                   UnitPrice = Integer.valueof((Math.random() * 1000))));
        }
        insert entradasPrecios;
        
        
        Account cuenta = new Account();
        cuenta.name = 'Cuenta Prueba';
        cuenta.RFC__c = '123456789101';
        cuenta.CurrencyIsoCode = 'MXN';
        cuenta.Phone='+52 7225398962';
        cuenta.centro_suministrador__c = 'AC01';
        cuenta.clave_delcanal__c = '04';
        cuenta.grupo__c = '01';
        insert cuenta;
        
        Order pedido = new Order(Pricebook2Id=listaPrecios.Id,AccountId=cuenta.Id,condiciones_de_pago__c='NT00',EffectiveDate= Date.today(), Status='Draft');
        insert pedido;
        List<Orderitem> orderItem = new  List<Orderitem>();
        for(PricebookEntry entradaPrecio : [SELECT Id,Product2Id FROM PricebookEntry WHERE Pricebook2Id=:listaPrecios.Id]){
            orderItem.add(new OrderItem (OrderId=pedido.Id,Quantity=100,UnitPrice=1200.7,DescuentoSAP__c=30,IMP_DescuentoPromo__c= 50, PricebookEntryId=entradaPrecio.Id));
        }
        insert orderItem;
    }
    
    /*******************************************************************
    Purpose: Covertura de la clase IMP_PedidoSAPController al metodo enviarPedioSAP
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void enviarPedioSAPTest()
    {
        Order pedido=[SELECT Id,Ordernumber,Pricebook2Id,Account.clave_delcanal__c, EffectiveDate,TotalAmount,Account.Credito_Disponible__c,Account.Credito_Acumulado__c ,TotalPedido__c, Account.Name,Account.id_de_sap__c,ViaPago__c,Pricebook2.Sucursal__c,
                      Pricebook2.Lista_de_precios_SAP__c FROM Order];
        IMP_EnvioPedidoSAP respuesta = new  IMP_EnvioPedidoSAP();
        respuesta.E_VBELN='100001';
        String body=JSON.serialize(respuesta);        
        
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_EnvioPedidoSAP.Wrapper respuestaEnvio =  IMP_PedidoSAPController.enviarPedioSAP(pedido);
        System.assertEquals('SUCCESS', respuestaEnvio.status,'ok');
        Test.stopTest();
    }
    
    /*******************************************************************
    Purpose: Covertura de la clase IMP_PedidoSAPController al metodo enviarPedioSAP
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void enviarPedioSAPError()
    {
        Order pedido=[SELECT Id,Ordernumber,Pricebook2Id,Account.clave_delcanal__c ,EffectiveDate,TotalAmount,Account.Credito_Disponible__c,Account.Credito_Acumulado__c ,TotalPedido__c, Account.Name,Account.id_de_sap__c,ViaPago__c,Pricebook2.Sucursal__c,
                      Pricebook2.Lista_de_precios_SAP__c FROM Order];
        IMP_EnvioPedidoSAP respuesta = new  IMP_EnvioPedidoSAP();
        respuesta.E_VBELN='';
        respuesta.E_TEXT='Error en el pedido';
        String body=JSON.serialize(respuesta);        
        
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_EnvioPedidoSAP.Wrapper respuestaEnvio = IMP_PedidoSAPController.enviarPedioSAP(pedido);
        System.assertEquals('Error en el pedido', respuestaEnvio.mensaje,'ok');
        Test.stopTest();
    }
    
    /*******************************************************************
    Purpose: Covertura de la clase IMP_PedidoSAPController al metodo getPedido
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getOrderTest()
    {
        Order pedido=[SELECT Id,Ordernumber,Pricebook2Id, EffectiveDate,TotalAmount,Account.Credito_Disponible__c,Account.Credito_Acumulado__c ,TotalPedido__c, Account.Name,Account.id_de_sap__c,ViaPago__c,Pricebook2.Sucursal__c,
                      Pricebook2.Lista_de_precios_SAP__c FROM Order];
        IMP_EnvioPedidoSAP respuesta = new  IMP_EnvioPedidoSAP();
        respuesta.E_VBELN='';
        respuesta.E_TEXT='Error en el pedido';
        String body=JSON.serialize(respuesta);        
        
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        System.assertEquals('CUENTA PRUEBA', pedido.Account.Name,'ok');
        Test.stopTest();
    }
    
    /*******************************************************************
    Purpose: Covertura de la clase IMP_PedidoSAPController al metodo deleteOrderItem
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void deleteOrderItemTest()
    {
        Order pedido=[SELECT Id,Ordernumber,Pricebook2Id, EffectiveDate,TotalAmount,Account.Credito_Disponible__c,Account.Credito_Acumulado__c ,TotalPedido__c, Account.Name,Account.id_de_sap__c,ViaPago__c,Pricebook2.Sucursal__c,
                      Pricebook2.Lista_de_precios_SAP__c FROM Order];
        OrderItem prodPedido=[SELECT Id FROM OrderItem WHERE Orderid=:pedido.Id Limit 1];
        IMP_EnvioPedidoSAP respuesta = new  IMP_EnvioPedidoSAP();
        respuesta.E_VBELN='';
        respuesta.E_TEXT='Error en el pedido';
        String body=JSON.serialize(respuesta);        
        
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_PedidoSAPController.deleteOrderItem(prodPedido.Id);
        System.assertEquals(19, [SELECT id FROM OrderItem].Size(),'ok');
        Test.stopTest();
    }
    
    /*******************************************************************
    Purpose: Covertura de la clase IMP_PedidoSAPController al metodo getDatosPedido
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getDatosPedidoTest()
    {
        List<IMP_InventarioManager.cls_ZINVENTARIOS> listProd= new List<IMP_InventarioManager.cls_ZINVENTARIOS>();
        IMP_InventarioManager respuesta = new IMP_InventarioManager();
        Order pedido=[SELECT Id,Ordernumber,Pricebook2Id, EffectiveDate,TotalAmount,Account.Credito_Disponible__c,Account.Credito_Acumulado__c ,TotalPedido__c, Account.Name,Account.id_de_sap__c,ViaPago__c,Pricebook2.Sucursal__c,
                      Pricebook2.Lista_de_precios_SAP__c FROM Order];
        
        IMP_PedidoSAPController.Wrapper newWrapperError = IMP_PedidoSAPController.getDatosPedido(pedido.Id);
        for(Product2 prod : [SELECT Id, productCode FROM Product2]){
            IMP_InventarioManager.cls_ZINVENTARIOS material= new IMP_InventarioManager.cls_ZINVENTARIOS();
            material.CHARG='0000092273';
            material.CLABS=Integer.valueof((Math.random() * 1000));
            material.HSDAT='2021-08-12';
            material.MATNR=prod.ProductCode; 
            listProd.add(material);
        }
      
        respuesta.ZINVENTARIOS=listProd;
        String body=JSON.serialize(respuesta);    
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_PedidoSAPController.Wrapper newWrapper = IMP_PedidoSAPController.getDatosPedido(pedido.Id);
        System.assertEquals(true, newWrapper.codigo == 'SUCCESS','ok');
        Test.stopTest();
    }
}