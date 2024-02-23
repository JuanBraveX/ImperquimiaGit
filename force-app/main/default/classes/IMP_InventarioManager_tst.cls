/************************************************************************
Name: IMP_InventarioManager_tst
Copyright © 2022 Salesforce
========================================================================
Purpose:
Test del controlador IMP_InventarioManager
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    11/04/2022     INITIAL        DEV CSR:
************************************************************************/

@isTest
public class IMP_InventarioManager_tst {
    
    /*******************************************************************
    Purpose: Covertura de las clases getInventario/getProdInventario
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getInventarioTest()
    {
        IMP_InventarioManager respuesta = new IMP_InventarioManager();
        List<IMP_InventarioManager.cls_ZINVENTARIOS> listProd= new List<IMP_InventarioManager.cls_ZINVENTARIOS>();
        IMP_InventarioManager.cls_ZINVENTARIOS prod= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod.CHARG='0000092273';
        prod.CLABS=100;
        prod.HSDAT='2021-08-12';
        prod.MATNR='10000311';
        listProd.add(prod);
        IMP_InventarioManager.cls_ZINVENTARIOS prod2= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod2.CHARG='0000092273';
        prod2.CLABS=100;
        prod2.HSDAT='2021-08-12';
        prod2.MATNR='10000311';
        listProd.add(prod2);
        respuesta.ZINVENTARIOS=listProd;
        String body=JSON.serialize(respuesta);        

        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        List<IMP_InventarioManager.cls_ZINVENTARIOS> listProdResponse = IMP_InventarioManager.getInventario(new List<String>{'10000311'},'IMPQ');
        Assert.isTrue(listProdResponse.size()==2);
        Assert.isTrue(listProdResponse[0].MATNR=='10000311');
        Test.stopTest();
        
    }
    
    
    /*******************************************************************
    Purpose: Covertura de las clases getInventario
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getInventariov2Test()
    {
        insert new Product2(Name='GUARDQUIM POLI RA 28, 18LT z', ProductCode='10000311', Family='2200 - MATIX', 
                                       CurrencyIsoCode='USD', sku__c =10000686); 
        
        IMP_InventarioManager respuesta = new IMP_InventarioManager();
        List<IMP_InventarioManager.cls_ZINVENTARIOS> listProd= new List<IMP_InventarioManager.cls_ZINVENTARIOS>();
        IMP_InventarioManager.cls_ZINVENTARIOS prod= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod.CHARG='0000092273';
        prod.CLABS=100;
        prod.HSDAT='2021-08-12';
        prod.MATNR='10000311';
        listProd.add(prod);
        IMP_InventarioManager.cls_ZINVENTARIOS prod2= new IMP_InventarioManager.cls_ZINVENTARIOS();
        prod2.CHARG='0000092273';
        prod2.CLABS=100;
        prod2.HSDAT='2021-08-12';
        prod2.MATNR='10000311';
        listProd.add(prod2);
        respuesta.ZINVENTARIOS=listProd;
        String body=JSON.serialize(respuesta);        

        Test.setMock(HttpCalloutMock.class, new IMP_Mock(201,'Ok',body,null));
        Test.startTest();
        IMP_ConsultaInventarioController.Wrapper data = IMP_ConsultaInventarioController.getInicialData('centro_suministrador__c');
        list<IMP_ConsultaInventarioController.Wrapper> listInventario = new  list<IMP_ConsultaInventarioController.Wrapper> ();
        IMP_ConsultaInventarioController.Wrapper inventario =  IMP_ConsultaInventarioController.getInventario('10000311','Imperquimia');
        listInventario.add(inventario);
        System.assertEquals(false, listInventario.size()>1,'Ok');
        Test.stopTest();
        
    }
    
    /*******************************************************************
    Purpose: Covertura de las clases getCatalogo
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getCatalogoTest()
    {
        Test.startTest();
        List<String> catalogos= IMP_ConsultaInventarioController.getCatalogo('centro_suministrador__c');
        System.assertEquals(true, catalogos.size()>0,'ok');
        Test.stopTest(); 
    }
    
    /*******************************************************************
    Purpose: Covertura de las clases getInventario
    Information about changes (versions) []:
    ********************************************************************/
    @isTest
    public static void getInventarioError()
    {
        Test.startTest();
        list<IMP_ConsultaInventarioController.Wrapper> listInventario = new  list<IMP_ConsultaInventarioController.Wrapper> ();
        IMP_ConsultaInventarioController.Wrapper inventario = IMP_ConsultaInventarioController.getInventario(null,'Imperquimia');
        listInventario.add(inventario);
        System.assertEquals(false, listInventario.size()>1,'Ok');
        Test.stopTest();  
    }
}