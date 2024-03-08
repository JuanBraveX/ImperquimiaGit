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
public class IMP_InventarioManager {
  public String I_LVORM; //
  public String I_VFDAT; //20220322
  public String I_WERKS; //IMPQ
  public cls_ZINVENTARIOS[] ZINVENTARIOS;
  public cls_I_MATNR[] I_MATNR;
  public class cls_ZINVENTARIOS {
    public String CHARG; //
    public Decimal CLABS; //0
    public String HSDAT; //
    public String LGORT; //
    public String MAKTX; //
    public String MATNR; //
    public String MEINS; //
    public String NAME; //
    public String VFDAT; //
    public String WERKS; //
  }
  public class cls_I_MATNR {
    public String MATNR; //10000311
  }

  /*******************************************************************
    Purpose: Genera el cuerpo de la solicitud a enviar.
    Parameters: List<String> listaCodigos,String almacen
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/

  public static String generateJSON(List<String> listaCodigos, String almacen) {
    List<cls_I_MATNR> listaMateriales = new List<cls_I_MATNR>();
    for (String item : listaCodigos) {
      cls_I_MATNR newProd = new cls_I_MATNR();
      newProd.MATNR = item;
      listaMateriales.add(newProd);
    }
    List<cls_ZINVENTARIOS> listInventarios = new List<cls_ZINVENTARIOS>();
    String fechaFinal = System.Now().format('YYYY/MM/dd');

    IMP_InventarioManager nuevaConsulta = new IMP_InventarioManager();
    nuevaConsulta.I_LVORM = '';
    nuevaConsulta.I_VFDAT = fechaFinal.replace('/', '');
    nuevaConsulta.I_WERKS = almacen;
    nuevaConsulta.I_MATNR = listaMateriales;
    nuevaConsulta.ZINVENTARIOS = listInventarios;
    //String body = JSON.serialize(nuevaConsulta);
    // Crear JSON manualmente
    String jsonBody =
      '{"ZINVENTARIOS":{},"I_WERKS":"' +
      nuevaConsulta.I_WERKS +
      '","I_VFDAT":"' +
      nuevaConsulta.I_VFDAT +
      '","I_MATNR":{';
    jsonBody += '"item":[';

    for (Integer i = 0; i < listaCodigos.size(); i++) {
      if (i > 0) {
        jsonBody += ',';
      }
      jsonBody += '{"MATNR":"' + listaCodigos[i] + '"}';
    }
    jsonBody += ']},"I_LVORM":"' + nuevaConsulta.I_LVORM + '"}';

    return jsonBody;
    //return body;
  }

  /*******************************************************************
    Purpose: Obtiene el inventario de los productos.
    Parameters: List<String> listaCodigos,String almacen
    Returns: cls_ZINVENTARIOS[]
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  public static cls_ZINVENTARIOS[] getInventario(
    List<String> listaCodigos,
    String almacen
  ) {
    IMP_InventarioManager inventario = new IMP_InventarioManager();
    try {
      //inicio mi documentacion 02232024
      String body = generateJSON(listaCodigos, almacen);
      System.debug(body);
      HttpResponse response = IMP_CalloutUtils.getResponse(
        body,
        IMP_ServiceConstants.INVENTARIO_API_URL
      );

      Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      System.debug(String.valueOf(jsonData.get('ZINVENTARIOS')));
      // Verificar si ZINVENTARIOS es un objeto o un arreglo
      Object zinventariosObject = jsonData.get('ZINVENTARIOS');
      if (String.valueOf(jsonData.get('ZINVENTARIOS')).contains('{item={')) {
        // ZINVENTARIOS es un objeto, convertirlo a un arreglo
        Map<String, Object> zinventariosMap = (Map<String, Object>) zinventariosObject;
        List<Object> itemList = new List<Object>();
        itemList.add(zinventariosMap.get('item'));
        zinventariosMap.put('item', itemList);
      }

      // Serializar el mapa de datos de nuevo a JSON
      String modifiedJson = JSON.serialize(jsonData);

      System.debug(response.getBody());
      System.debug(modifiedJson);
      Map<String, Object> responseInventario = (Map<String, Object>) JSON.deserializeUntyped(
        modifiedJson
      );

      List<cls_I_MATNR> responseIs_MATNRs = new List<cls_I_MATNR>();
      Map<String, Object> Is_MATNR = (Map<String, Object>) responseInventario.get(
        'I_MATNR'
      );

      if (Is_MATNR != null && Is_MATNR.containsKey('item')) {
        Map<String, Object> itemMap = (Map<String, Object>) Is_MATNR.get(
          'item'
        );
        if (itemMap != null && itemMap.containsKey('MATNR')) {
          IMP_InventarioManager.cls_I_MATNR item = new IMP_InventarioManager.cls_I_MATNR();
          item.MATNR = (String) itemMap.get('MATNR');
          responseIs_MATNRs.add(item);
        }
      }
      System.debug('S');
      List<cls_ZINVENTARIOS> resposeZINVENTARIOSs = new List<cls_ZINVENTARIOS>();
      Map<String, Object> ZINVENTARIOS = new Map<String, Object>();
      
      if (String.valueOf(responseInventario.get('ZINVENTARIOS')) != '') {
        ZINVENTARIOS = (Map<String, Object>) responseInventario.get(
          'ZINVENTARIOS'
        );
      }
      System.debug('2');
      List<Object> itemObjectsZINV = (List<Object>) ZINVENTARIOS.get('item');
      if (itemObjectsZINV != null) {
        List<cls_ZINVENTARIOS> ZINVENTARIOSs = new List<cls_ZINVENTARIOS>();
        for (Object itemObject : itemObjectsZINV) {
          Map<String, Object> itemMap = (Map<String, Object>) itemObject;
          IMP_InventarioManager.cls_ZINVENTARIOS item = new IMP_InventarioManager.cls_ZINVENTARIOS();
          item.CHARG = (String) itemMap.get('CHARG'); //
          item.CLABS = Decimal.valueOf((String) itemMap.get('CLABS')); //0
          item.HSDAT = (String) itemMap.get('HSDAT'); //
          item.LGORT = (String) itemMap.get('LGORT'); //
          item.MAKTX = (String) itemMap.get('MAKTX'); //
          item.MATNR = (String) itemMap.get('MATNR'); //
          item.MEINS = (String) itemMap.get('MEINS'); //
          item.NAME = (String) itemMap.get('NAME'); //
          item.VFDAT = (String) itemMap.get('VFDAT'); //
          item.WERKS = (String) itemMap.get('WERKS'); //
          ZINVENTARIOSs.add(item);
        }
        // Asigna la lista de objetos a tu objeto principal
        resposeZINVENTARIOSs = ZINVENTARIOSs;
      }
      System.debug(resposeZINVENTARIOSs);
      inventario.ZINVENTARIOS = resposeZINVENTARIOSs;
      //inventario = (IMP_InventarioManager)JSON.deserialize(response.getBody(), IMP_InventarioManager.class);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
    }
    return inventario.ZINVENTARIOS;
  }
}
