/************************************************************************
Name: IMP_FlujoDocumentos
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test de la clase controller IMP_FlujoDocumentos
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
2.0      dmarcos@ts4.mx        1/04/2022   
3.0      rotrejo@ts4.mx        13/04/2023   
************************************************************************/
@isTest
public class IMP_FujoDocumentos_Test {

    /*******************************************************************
    Purpose: Inserta información en los objetos correspondientes y realiza 
    la llamada al método getDocumentos y getIdPedidoSAP para consultar los 
    documentos disponibles desde SAP.
    Information about changes (versions) []:
********************************************************************/
    @testSetup static void inicializarDatos(){
        User administrador = [Select Id, UserRoleId From User Where Profile.Name='Administrador del sistema' AND isActive=true Limit 1];
        administrador.Grupo_de_Vendedor__c=1998;
        update administrador;
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
        
        Pricebook2 pricebook= new Pricebook2();
        pricebook.Id=Test.getStandardPricebookId();
        pricebook.Description='AC01';
        update pricebook;
        
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
    Purpose: Covertura de la clase IMP_FlujoDocumentos al metodo getFacturasPedido
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getFacturasPedido()
    {
        Test.startTest();
        Order pedido = [SELECT Id,pedido__c FROM Order Limit 1];
        IMP_FlujoDocumentos.getPedido(pedido.Id);
        IMP_FlujoDocumentos respuesta = new IMP_FlujoDocumentos();
        List<IMP_FlujoDocumentos.T_FAC_PED> listFactsResponse = new  List<IMP_FlujoDocumentos.T_FAC_PED>();
        for(Integer i=0;i < 10; i++){
            IMP_FlujoDocumentos.T_FAC_PED factura = new IMP_FlujoDocumentos.T_FAC_PED();
            factura.AUBEL='0001036225';
            factura.FKDAT='2021-01-02';
            factura.FKART = 'F2';
            factura.VBELN = '0090472129'+i;
            factura.NETWR = 100;
            factura.ERNAM = 'CUERNAVACAF1';
            factura.VTWEG_AUFT='04';
            factura.KUNAG = '0001000193';
            factura.NAME1='NAYELI LUCIANA ORTIZ LOPEZ';
            factura.NAME2= '';
            factura.NAME3= '';
            factura.NAME4= '';
            factura.VKGRP='1998';
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
        String body=JSON.serialize(respuesta);        
        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        IMP_FlujoDocumentos.getFacturasPedido(pedido.pedido__c);
        Assert.isTrue([SELECT Id,IMP_MontoFactura__c FROM Factura__c].size() ==10);
        System.debug([SELECT Id,IMP_CanalVentas__c,IMP_Vendedor__r.Name,IMP_Fecha__c, IMP_FacturadoMes__c  FROM Presupuesto__c]);
        Assert.isTrue([SELECT Id,IMP_CanalVentas__c,IMP_Vendedor__c,IMP_Fecha__c, IMP_FacturadoMes__c  FROM Presupuesto__c].IMP_FacturadoMes__c==1000);
        Factura__c factura = [SELECT Id,IMP_MontoFactura__c FROM Factura__c Limit 1];
        factura.IMP_MontoFactura__c=200;
        update factura;
        Assert.isTrue([SELECT Id,IMP_CanalVentas__c,IMP_Vendedor__c,IMP_Fecha__c, IMP_FacturadoMes__c  FROM Presupuesto__c].IMP_FacturadoMes__c==1100);
        System.debug([SELECT Id,IMP_CanalVentas__c,IMP_Vendedor__r.Name,IMP_Vendedor__c,IMP_Fecha__c, IMP_FacturadoMes__c  FROM Presupuesto__c]);

        Test.stopTest(); 
    }
    
    
       
   /*******************************************************************
    Purpose: Covertura de la clase IMP_FlujoDocumentos al metodo getFacturasPedido with error
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getFacturasPedidoError()
    {
        Test.startTest();
        Order pedido = [SELECT Id,pedido__c FROM Order Limit 1];
        try{
            String body='Unable to connect to the remote server';        
            Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
            IMP_FlujoDocumentos.getFacturasPedido(pedido.pedido__c);
        }catch(Exception ex){
            
        }
        Test.stopTest();
    }
}