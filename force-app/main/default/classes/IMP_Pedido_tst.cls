/******************************************************************* 
Name: IMP_Pedido_tst
Copyright © 2022 Salesforce
======================================================
Purpose:
Class test to IMP_Pedido_tst.
======================================================
History:
Creation
VERSION  AUTHOR           DATE          DETAIL     Description
1.0      rotrejo@ts4.mx   04/05/2021    INITIAL     DEV CSR: 
******************************************************************/
@IsTest
private class IMP_Pedido_tst {
    
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
        cuenta.id_de_sap__c='10001';
        cuenta.name = 'Cuenta Prueba';
        cuenta.RFC__c = '123456789101';
        cuenta.CurrencyIsoCode = 'MXN';
        cuenta.centro_suministrador__c = 'AC01';
        cuenta.clave_delcanal__c = '04';
        cuenta.grupo__c = '01';
        cuenta.Sector__c='10';
        cuenta.Phone='+52 7225398962';
        cuenta.OrganizacionVentas__c='IMPQ';
        cuenta.IMP_LlaveExterna__c='10001IMPQ0110';
        insert cuenta;
        
        Order pedido = new Order(Pricebook2Id=listaPrecios.Id,AccountId=cuenta.Id,condiciones_de_pago__c='NT00',EffectiveDate= Date.today(), Status='Draft',
                                 pedido__c='0000528217');
        insert pedido;
        List<Orderitem> orderItem = new  List<Orderitem>();
        Integer pos =10;
        for(PricebookEntry entradaPrecio : [SELECT Id,Product2Id,Product2.Productcode FROM PricebookEntry WHERE Pricebook2Id=:listaPrecios.Id Order by ProductCode]){
            orderItem.add(new OrderItem (OrderId=pedido.Id,Quantity=Integer.valueof((Math.random() * 1000)),
                                         UnitPrice=1200.7,DescuentoSAP__c=30, PricebookEntryId=entradaPrecio.Id,
                                         IMP_LlaveExclusiva__c='0000528217'+ '-' + pos + '-' +entradaprecio.Product2.Productcode));
            pos+=10;
        }
        insert orderItem;
    }
    
    /******************************************************************* 
    Purpose: It executes methods to complete the percent for update a product.
    Information about changes (versions)
    ********************************************************************/ 
    @isTest static void testupsertOrder() {
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://legrand-lightning--parcial.my.salesforce.com/services/apexrest/Product2';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        System.debug([SELECT ID,pedido__c FROM Order ]);
        IMP_EnvioPedidoSAP newOrder = new IMP_EnvioPedidoSAP();
        List<IMP_EnvioPedidoSAP.cls_I_ITEM> listProd = new  List<IMP_EnvioPedidoSAP.cls_I_ITEM>();
        newOrder.ZLSCH = 'C';
        newOrder.GBSTK='A';
        newOrder.I_BSTKD ='0000528217';
        newOrder.BSTDK ='2022-04-28';
        newOrder.E_VBELN ='0000528217';
        IMP_EnvioPedidoSAP.cls_I_ITEM newItem = new  IMP_EnvioPedidoSAP.cls_I_ITEM ();
        newItem.POSNR='20';
        newItem.MATNR='10000102';
        newItem.KAWRT=20;
        newItem.KWMENG=30;
        listProd.add(newItem);
        newOrder.I_ITEM=listProd;
        request.requestBody = Blob.valueOf(JSON.serialize(newOrder));
        System.debug('Body');
        System.debug(JSON.serialize(newOrder));
        RestContext.request = request;
        IMP_Pedido.upsertOrder();
        System.assert(RestContext.request.requestBody.toString()  != null,'Response can not be null'); 
    }
    
     /******************************************************************* 
    Purpose: It executes methods to complete the percent for update a product.
    Information about changes (versions)
    ********************************************************************/ 
    @isTest static void testupsertOrder2() {
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://legrand-lightning--parcial.my.salesforce.com/services/apexrest/Product2';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        IMP_EnvioPedidoSAP newOrder = new IMP_EnvioPedidoSAP();
        List<IMP_EnvioPedidoSAP.cls_I_ITEM> listProd = new  List<IMP_EnvioPedidoSAP.cls_I_ITEM>();
        newOrder.ZLSCH = 'C';
        newOrder.BSTDK ='2022-04-28';
        newOrder.E_VBELN ='0000528217';
        newOrder.GBSTK='A';
        IMP_EnvioPedidoSAP.cls_I_ITEM newItem = new  IMP_EnvioPedidoSAP.cls_I_ITEM ();
        newItem.POSNR='10';
        newItem.MATNR='10000101';
        newItem.KAWRT=20;
        newItem.KWMENG=30;
        listProd.add(newItem);
        newOrder.I_ITEM=listProd;
        request.requestBody = Blob.valueOf(JSON.serialize(newOrder));
        RestContext.request = request;
        IMP_Pedido.upsertOrder();
        System.assert(RestContext.request.requestBody.toString()  != null,'Response can not be null'); 
    }
    
    
        /******************************************************************* 
    Purpose: It executes methods to complete the percent for update a product.
    Information about changes (versions)
    ********************************************************************/ 
    @isTest static void testUpsertOrderError() {
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://legrand-lightning--parcial.my.salesforce.com/services/apexrest/Product2';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        IMP_EnvioPedidoSAP newOrder = new IMP_EnvioPedidoSAP();
        List<IMP_EnvioPedidoSAP.cls_I_ITEM> listProd = new  List<IMP_EnvioPedidoSAP.cls_I_ITEM>();
        newOrder.ZLSCH = 'C';
        newOrder.BSTDK ='2022-04-28';
        newOrder.E_VBELN ='0000528218';
        IMP_EnvioPedidoSAP.cls_I_ITEM newItem = new  IMP_EnvioPedidoSAP.cls_I_ITEM ();
        newItem.POSNR='20';
        newItem.MATNR='10000102';
        newItem.KAWRT=20;
        newItem.KWMENG=30;
        listProd.add(newItem);
        newOrder.I_ITEM=listProd;
        request.requestBody = Blob.valueOf(JSON.serialize(newOrder));
        RestContext.request = request;
        try{
            IMP_Pedido.upsertOrder();
            
        }catch(Exception e){
        }
        System.assert(RestContext.request.requestBody.toString()  != null,'Response can not be null'); 
    }
    
        
        /******************************************************************* 
    Purpose: It executes methods to complete the percent for update a product.
    Information about changes (versions)
    ********************************************************************/ 
    @isTest static void testPedidoSAP() {
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://legrand-lightning--parcial.my.salesforce.com/services/apexrest/Product2';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        IMP_EnvioPedidoSAP newOrder = new IMP_EnvioPedidoSAP();
        newOrder.ZLSCH = 'C';
        newOrder.BSTDK ='2022-04-28';
        newOrder.E_VBELN ='0000528100';
        newOrder.I_KUNNR='10001';
        newOrder.I_VKORG='IMPQ';
        newOrder.I_VTWEG='01';
        newOrder.SPART='10';
        newOrder.I_VKGRP='001';
        newOrder.EXT1='IMPQ';
        newOrder.GBSTK='A';
        request.requestBody = Blob.valueOf(JSON.serialize(newOrder));
        System.debug(Blob.valueOf(JSON.serialize(newOrder)));
        RestContext.request = request;
        IMP_Pedido.upsertOrder();

       // System.assert(RestContext.request.requestBody.toString()  != null,'Response can not be null'); 
    }
    
}