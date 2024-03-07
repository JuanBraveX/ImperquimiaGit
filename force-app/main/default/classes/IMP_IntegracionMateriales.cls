/************************************************************************
Name: IMP_IntegracionMateriales
Copyright © 2022 Salesforce
========================================================================
Purpose:
Clase que realiza la consulta de productos en SAP y actualiza los registros
en salesforce
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
 2.0      mvilchis@ts4.mx    01/04/2022     
************************************************************************/
public without sharing class IMP_IntegracionMateriales {
  /*******************************************************************
    Purpose: Consulta una lista de materiales en SAP de acuerdo a una
    fecha de inicio y fin.
    Parameters: String fechaInicio, String fechaFinal
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
<<<<<<< .merge_file_KJq9f2
  @future(callout=true)
  public static void getMateriales(String fechaInicio, String fechaFinal) {
    List<Product2> lstUpsert = new List<Product2>();
    Set<String> lstProdCode = new Set<String>();
    String body;
    String apiUrl = IMP_ServiceConstants.MATERIALES_API_URL;
    String urlFinal = 'imperquiaSAP' + apiUrl;
    String authHeader =
      'BASIC ' +
      EncodingUtil.base64Encode(
        Blob.valueOf(
          System.Label.User_Integration +
            ':' +
            System.Label.Password_Integration
        )
      );
    Map<String, String> params = new Map<String, String>();
    //String token = IMP_CrearClienteSap_CC.retriveToken().token;
    Map<String, String> headers = new Map<String, String>{
      'Content-Type' => 'application/json',
      'Authorization' => authHeader
    };
    try {
      body = IMP_CreateJson.createMateriales(fechaInicio, fechaFinal);
      System.debug('Body de crear materiales' + body);
      HttpRequest req = IMP_CalloutUtils.generateRequest(
        IMP_CalloutConstants.METHOD_POST,
        urlFinal,
        params,
        headers,
        120000,
        body
      );
      HttpResponse response = IMP_CalloutUtils.doRequest(req, true);
      /*
      IMP_IntegracionMateriales responseProducto = (IMP_IntegracionMateriales) JSON.deserialize(
        response.getBody(),
        IMP_IntegracionMateriales.class
      );*/
      Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      System.debug(String.valueOf(jsonData.get('ET_MATERIALES')));
      // Verificar si ET_MATERIALES es un objeto o un arreglo
      Object ET_MATERIALESObject = jsonData.get('ET_MATERIALES');
      if (String.valueOf(jsonData.get('ET_MATERIALES')).contains('{item={')) {
        // ET_MATERIALES es un objeto, convertirlo a un arreglo
        Map<String, Object> ET_MATERIALESMap = (Map<String, Object>) ET_MATERIALESObject;
        List<Object> itemList = new List<Object>();
        itemList.add(ET_MATERIALESMap.get('item'));
        ET_MATERIALESMap.put('item', itemList);
      }

      // Serializar el mapa de datos de nuevo a JSON
      String modifiedJson = JSON.serialize(jsonData);

      System.debug(response.getBody());
      System.debug(modifiedJson);
      Map<String, Object> responseMateriales = (Map<String, Object>) JSON.deserializeUntyped(
        modifiedJson
      );

      List<cls_IT_MATERIALES> resposeIT_MATERIALES = new List<cls_IT_MATERIALES>();

      Map<String, Object> itMateriales = new Map<String, Object>();

      if (String.valueOf(responseMateriales.get('ET_MATERIALES')) != '') {
        itMateriales = (Map<String, Object>) responseMateriales.get(
          'ET_MATERIALES'
        );
      }
=======
    @future(callout=true)
    public static void getMateriales(String fechaInicio, String fechaFinal) {
        List<Product2> lstUpsert = new List<Product2>();
        Set<String> lstProdCode = new Set<String>();
        String body;
        String apiUrl = IMP_ServiceConstants.MATERIALES_API_URL;
        String urlFinal = 'imperquiaSAP'+apiUrl;
        String authHeader = 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(System.Label.User_Integration + ':' + System.Label.Password_Integration));
        Map<String, String> params = new Map<String, String>();
        //String token = IMP_CrearClienteSap_CC.retriveToken().token;
        Map<String,String> headers = new Map<String,String>{'Content-Type' => 'application/json', 'Authorization' => authHeader};
        try {
            body = IMP_CreateJson.createMateriales(fechaInicio,fechaFinal);
            System.debug('Body de crearMateriales' + body);
            HttpRequest req = IMP_CalloutUtils.generateRequest(
                IMP_CalloutConstants.METHOD_POST, 
                urlFinal,
                params, 
                headers, 
                120000, 
                body
            );
            HttpResponse response = IMP_CalloutUtils.doRequest(req, true);
            IMP_IntegracionMateriales responseProducto = (IMP_IntegracionMateriales)JSON.deserialize(response.getBody(), IMP_IntegracionMateriales.class);
            for(IMP_IntegracionMateriales.cls_IT_MATERIALES prod : responseProducto.IT_MATERIALES) {
                if(prod.LVORM == 'X') {
                    lstProdCode.add(prod.MATNR.replaceFirst('^0+', ''));
                }
                else if(prod.MAKTX != '') {
                    Product2 prodNew = new Product2(Name=prod.MAKTX,centro_suministrador__c=prod.WERKS,ProductCode=prod.MATNR.replaceFirst('^0+', ''),IMP_IdExterno__c=prod.MATNR.replaceFirst('^0+', ''),
                                                Grupo_de_art_culos__c=prod.MATKL,/*Grupo_de_Materiales_c=prod.KONDM,*/sku__c=Decimal.valueOf(prod.MATNR.replaceFirst('^0+', '')),
                                                tipo_impuesto__c=prod.TAXKM,QuantityUnitOfMeasure=prod.MEINS,IsActive=true);
                    lstUpsert.add(prodNew);
                }
            }
            for(Product2 prod : [SELECT Id,ProductCode,IMP_IdExterno__c,IsActive FROM Product2 WHERE ProductCode IN : lstProdCode]) {
                prod.IsActive=false;
                lstUpsert.add(prod);
            }
>>>>>>> .merge_file_gEpjcU

      List<Object> itemObjectsMATE = (List<Object>) itMateriales.get('item');
      if (itemObjectsMATE != null) {
        List<cls_IT_MATERIALES> IT_MaterialesLst = new List<cls_IT_MATERIALES>();
        for (Object itemObject : itemObjectsMATE) {
          Map<String, Object> itemMap = (Map<String, Object>) itemObject;
          IMP_IntegracionMateriales.cls_IT_MATERIALES item = new IMP_IntegracionMateriales.cls_IT_MATERIALES();
          item.MATNR = (String) itemMap.get('MATNR');
          item.WERKS = (String) itemMap.get('WERKS');
          item.MAKTX = (String) itemMap.get('MAKTX');
          item.KONWA = (String) itemMap.get('KONWA');
          item.MATKL = (String) itemMap.get('MATKL');
          item.KONDM = (String) itemMap.get('KONDM');
          item.SKU = (String) itemMap.get('SKU');
          item.TAXKM = (String) itemMap.get('TAXKM');
          item.PLTYP = (String) itemMap.get('PLTYP');
          item.MEINS = (String) itemMap.get('MEINS');
          item.LVORM = (String) itemMap.get('LVORM');
          IT_MaterialesLst.add(item);
        }
        // Asigna la lista de objetos a tu objeto principal
        resposeIT_MATERIALES = IT_MaterialesLst;
      }
      System.debug(resposeIT_MATERIALES);
      

      for (
        IMP_IntegracionMateriales.cls_IT_MATERIALES prod : resposeIT_MATERIALES
      ) {
        if (prod.LVORM == 'X') {
          lstProdCode.add(prod.MATNR.replaceFirst('^0+', ''));
        } else if (prod.MAKTX != '') {
          Product2 prodNew = new Product2(
            Name = prod.MAKTX,
            centro_suministrador__c = prod.WERKS,
            ProductCode = prod.MATNR.replaceFirst('^0+', ''),
            IMP_IdExterno__c = prod.MATNR.replaceFirst('^0+', ''),
            Grupo_de_art_culos__c = prod.MATKL,
            Grupo_de_Materiales__c=prod.KONDM,
            sku__c = Decimal.valueOf(
              prod.MATNR.replaceFirst('^0+', '')
            ),
            tipo_impuesto__c = prod.TAXKM,
            QuantityUnitOfMeasure = prod.MEINS,
            IsActive = true
          );
          lstUpsert.add(prodNew);
        }
      }
      for (Product2 prod : [
        SELECT Id, ProductCode, IMP_IdExterno__c, IsActive
        FROM Product2
        WHERE ProductCode IN :lstProdCode
      ]) {
        prod.IsActive = false;
        lstUpsert.add(prod);
      }

      list<Database.upsertResult> uResults = Database.upsert(
        lstUpsert,
        Product2.IMP_IdExterno__c,
        false
      );
      for (Database.upsertResult res : uResults) {
        if (res.isSuccess()) {
          System.debug('Producto creado : ' + res.getId());
        }
        for (Database.Error err : res.getErrors()) {
          System.debug('err: ' + err);
        }
      }
    } catch (Exception exc) {
      system.debug(exc.getMessage());
      Integration_Logs__c systemLog = new Integration_Logs__c(
        Linea__c = String.valueOf(exc.getLineNumber()),
        Clase__c = exc.getTypeName()
            .substring(
              0,
              exc.getTypeName().length() > 255
                ? 200
                : exc.getTypeName().length()
            ) +
          ' ' +
          exc.getCause() +
          ' ' +
          exc.getStackTraceString(),
        Mensaje_SFDC__c = exc.getMessage(),
        Body_JSON__c = body,
        Tipo__c = 'GET_MATERIALES_SFDC'
      );

      insert systemLog;
    }
  }
  //Juan Pedraza
  public cls_IT_MATERIALES[] IT_MATERIALES;
  public class cls_IT_MATERIALES {
    public String MATNR; //MATERIAL
    public String WERKS; //CENTRO CONSUMIDOR
    public String MAKTX; //NOMBRE MATERIAL
    public String KONWA;
    public String MATKL; //GRUPO ARTICULOS
    public String KONDM; //GRUPO MATERIALES
    public String SKU; //SKU
    public String TAXKM; //TIPO IMPUESTO
    public String PLTYP;
    public String MEINS; //UNIDAD MEDIDA
    public String LVORM; //INDICADOR BORRADO
  }
}
