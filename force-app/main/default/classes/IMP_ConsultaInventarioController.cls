/************************************************************************
Name: IMP_integrationServiceReg
Copyright © 2022 Salesforce
========================================================================
Purpose:
Obtener el inventario generado por SAP
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    11/04/2022     First Version.
************************************************************************/

public without sharing class IMP_ConsultaInventarioController {
  /*******************************************************************
    Purpose: Obtiene el inventario de los productos.
    Parameters: String codProd,String almacen
    Returns: List<Wrapper>
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  @AuraEnabled
  public static Wrapper getInventario(String productCode, String almacen) {
    almacen = almacen != 'Todos' ? getValue(almacen) : '';
    Wrapper salida = new Wrapper();
    try {
      List<String> listaCodigo = new List<String>{ productCode };
      List<Producto> listProds = new List<Producto>();
      System.debug('consultar antes el inventarios');
      List<IMP_InventarioManager.cls_ZINVENTARIOS> listProdsResponse = IMP_InventarioManager.getInventario(
        listaCodigo,
        almacen
      );
      System.debug(listProdsResponse);
      if (listProdsResponse != null) {
        for (IMP_InventarioManager.cls_ZINVENTARIOS prod : listProdsResponse) {
          Producto newProd = new Producto();
          newProd.codigo = prod.MATNR.replaceFirst('^0+', '');
          newProd.nombre = prod.MAKTX;
          newProd.disponibles = prod.CLABS;
          newProd.almacen = prod.Name;
          newProd.noLote = prod.CHARG.replaceFirst('^0+', '');
          newProd.fecha = prod.VFDAT;
          newProd.fechaFab = prod.HSDAT;
          listProds.add(newProd);
        }
        salida.listProds = listProds;
        salida.codigo = 'SUCCESS';
        System.debug(salida);
      } else {
        salida.codigo = 'ERROR';
      }
    } catch (Exception e) {
      System.debug(e);
    }
    return salida;
  }

  /*******************************************************************
    Purpose: Obtiene la etiqueta del campo almacen.
    Parameters: String fieldObject
    Returns: List<String>
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  @AuraEnabled
  public static List<String> getCatalogo(String fieldObject) {
    list<String> listCatalogo = new List<String>();
    DescribeSObjectResult objResult = Schema.getGlobalDescribe()
      .get('Product2')
      .getDescribe();
    DescribeFieldResult listFieldObject = objResult.fields.getMap()
      .get(fieldObject)
      .getDescribe();
    listCatalogo.add('Todos');
    list<Schema.PicklistEntry> listaCatalogo = listFieldObject.getPicklistValues();
    for (PicklistEntry name : listaCatalogo) {
      listCatalogo.add(name.getLabel());
    }
    System.debug(listCatalogo);
    return listCatalogo;
  }

  /*******************************************************************
    Purpose: Obtiene la etiqueta del campo almacen.
    Parameters: String fieldObject
    Returns: List<String>
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  @AuraEnabled
  public static Wrapper getInicialData(String fieldObject) {
    Wrapper salida = new Wrapper();
    List<Product2> listProduct = new List<Product2>();
    try {
      listProduct = [SELECT Id, Name, ProductCode FROM Product2 LIMIT 3000];
    } catch (Exception ex) {
    }
    salida.listCatalogo = getCatalogo(fieldObject);
    salida.listProd2 = listProduct;
    return salida;
  }

  /*******************************************************************
    Purpose: Obtiene el nombre api del campo almacen
    Parameters: String label
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  public static String getValue(String label) {
    String salida = '';
    DescribeSObjectResult objResult = Schema.getGlobalDescribe()
      .get('Product2')
      .getDescribe();
    DescribeFieldResult listFieldObject = objResult.fields.getMap()
      .get('centro_suministrador__c')
      .getDescribe();
    list<Schema.PicklistEntry> listaCatalogo = listFieldObject.getPicklistValues();
    for (PicklistEntry name : listaCatalogo) {
      if (name.getLabel() == label) {
        salida = name.getValue();
        break;
      }
    }
    return salida;
  }
  public class Wrapper {
    @AuraEnabled
    public List<Producto> listProds;
    @AuraEnabled
    public String codigo;
    @AuraEnabled
    public List<String> listCatalogo;
    @AuraEnabled
    public List<Product2> listProd2;
  }

  public class Producto {
    @AuraEnabled
    public String codigo;
    @AuraEnabled
    public String nombre;
    @AuraEnabled
    public String almacen;
    @AuraEnabled
    public Decimal disponibles;
    @auraEnabled
    public String noLote { get; set; }
    @auraEnabled
    public String fecha { get; set; }
    @auraEnabled
    public String fechaFab { get; set; }
  }
}
