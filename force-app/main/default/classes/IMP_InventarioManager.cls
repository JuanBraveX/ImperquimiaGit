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
      String body = generateJSON(listaCodigos, almacen);
      HttpResponse response = IMP_CalloutUtils.getResponse(
        body,
        IMP_ServiceConstants.INVENTARIO_API_URL
      );
      Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      convertirAListaSiNecesario(jsonData, 'I_MATNR');
      convertirAListaSiNecesario(jsonData, 'ZINVENTARIOS');
      String modifiedJson = JSON.serialize(jsonData);
      System.debug('Response body Moficado 1: ' + modifiedJson);
      String newJsonString = convertObjectToArray(modifiedJson, 'I_MATNR');
      newJsonString = convertObjectToArray(newJsonString, 'ZINVENTARIOS');
      System.debug('Response body Moficado 2: ' + newJsonString);
      inventario = new IMP_InventarioManager();
      inventario = (IMP_InventarioManager) JSON.deserialize(
        newJsonString,
        IMP_InventarioManager.class
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
    }
    return inventario.ZINVENTARIOS;
  }

  public static void convertirAListaSiNecesario(
    Map<String, Object> jsonData,
    String clave
  ) {
    Object objeto = jsonData.get(clave);
    if (String.valueOf(objeto).contains('{item={')) {
      Map<String, Object> mapa = (Map<String, Object>) objeto;
      List<Object> lista = new List<Object>();
      lista.add(mapa.get('item'));
      mapa.put('item', lista);
    }
  }

  public static String convertObjectToArray(
    String jsonString,
    String objectKey
  ) {
    // Convertir el JSON original a un mapa de objetos sin tipo
    Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(
      jsonString
    );
    if (jsonData.containsKey(objectKey)) {
      Object ObjectJson = jsonData.get(objectKey);
      if (ObjectJson instanceof Map<String, Object>) {
        Map<String, Object> MapObject = (Map<String, Object>) ObjectJson;
        if (
          MapObject.containsKey('item') &&
          MapObject.get('item') instanceof List<Object>
        ) {
          List<Object> itemList = (List<Object>) MapObject.get('item');
          jsonData.put(objectKey, itemList);
          jsonData.remove('item');
        }
      }
    }
    String updatedJsonDataString = JSON.serialize(jsonData);

    // Paso 4: Convertir el mapa en formato JSON
    return JSON.serialize(jsonData);
  }
}
