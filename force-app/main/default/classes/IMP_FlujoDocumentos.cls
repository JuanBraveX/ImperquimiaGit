/************************************************************************
Name: IMP_FlujoDocumentos
Copyright © 2023 Salesforce
========================================================================
Purpose:
Servicio web para la consulta de documentos de un pedido desde SAP 
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
2.0      dmarcos@ts4.mx     01/04/2022     
3.0      rotrejo@ts4.mx     01/04/2022     
************************************************************************/
public without sharing class IMP_FlujoDocumentos {
  //Header del WS
  public String PI_FINI;
  public String PI_FFIN;
  public String PI_AUBEL;
  public List<T_FAC_PED> T_FAC_PED;
  // Objeto
  public class T_FAC_PED {
    public String AUBEL; //Número del Pedido
    public String FKDAT;
    public String FKART;
    public String VBELN; //Número de la Factura
    public String POSNR;
    public String MATNR;
    public String ARKTX;
    public Decimal NETWR;
    public String GBSTK;
    public String ERNAM;
    public String VTWEG_AUFT;
    public String KUNAG;
    public String NAME1;
    public String NAME2;
    public String NAME3;
    public String NAME4;
    public String VKGRP;
    public String ZTERM;
    public String PRCTR;
    public String VKORG_AUFT;
    public String SPART;
    public String BEZEI;
    public String LTEXT;
    public String STATUSG;
    public String VWERK;
  }

  public class Wrapper {
    public List<Factura__c> listFacturas;
    public List<OrderItem> items;
    @AuraEnabled
    public String estatus;
    @AuraEnabled
    public Integer noFacturas;
    @AuraEnabled
    public Integer noFacturasError;
    @AuraEnabled
    public Integer noItems;
    @AuraEnabled
    public Integer noItemsError;
  }

  /*******************************************************************
    Purpose: Obtener el Id del pedido actual.
    Parameters: String recordId
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  @auraEnabled
  public static Order getPedido(String recordId) {
    return [SELECT Id, Ordernumber, pedido__c FROM Order WHERE Id = :recordId];
  }

  /*******************************************************************
    Purpose: Obtener las facturas por pedido.
    Parameters: String recordId
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  @AuraEnabled
  public static Wrapper getFacturasPedido(String pedidoId) {
    Wrapper newWrapper;
    try {
      newWrapper = getFacturasWrapper(pedidoId, null, null);
      newWrapper.noFacturas = 0;
      newWrapper.noFacturasError = 0;
      newWrapper.noItems = 0;
      newWrapper.noItemsError = 0;

      if (newWrapper.listFacturas != null) {
        List<Database.UpsertResult> results = Database.upsert(
          newWrapper.listFacturas,
          Factura__c.IMP_LlaveExclusiva__c,
          false
        );
        for (Database.UpsertResult itemResult : results) {
          if (itemResult.isSuccess()) {
            newWrapper.noFacturas = newWrapper.noFacturas + 1;
          } else {
            system.debug(itemResult.getErrors());
            newWrapper.noFacturasError = newWrapper.noFacturasError + 1;
          }
        }
      }
      if (newWrapper.items != null) {
        List<Database.UpsertResult> results = Database.upsert(
          newWrapper.items,
          OrderItem.IMP_LlaveExclusiva__c,
          false
        );
      }
    } catch (Exception ex) {
      throw new AuraHandledException(ex.getMessage());
    }

    return newWrapper;
  }

  /*******************************************************************
    Purpose: Obtener un Wrapper con el listado de Facturas y Partidas de Pedido.
    Parameters: String recordId
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  public static Wrapper getFacturasWrapper(
    String pedidoId,
    String fechaInicial,
    String fechaFinal
  ) {
    IMP_FlujoDocumentos params = new IMP_FlujoDocumentos();
    params.PI_AUBEL = pedidoId != null ? pedidoId : '';
    params.PI_FINI = fechaInicial != null ? fechaInicial : '';
    params.PI_FFIN = fechaFinal != null ? fechaFinal : '';
    List<T_FAC_PED> listFacts = new List<T_FAC_PED>();
    params.T_FAC_PED = listFacts;
    String body = JSON.serialize(params);
    System.debug('CUERPO DE LA SOLICITUD');
    System.debug(body);
    HttpResponse response = IMP_CalloutUtils.getResponse(
      body,
      IMP_ServiceConstants.FACTURA_API_URL
    );
    System.debug(response.getBody());
    Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );
    convertirAListaSiNecesario(jsonData, 'T_FAC_PED');
    String modifiedJson = JSON.serialize(jsonData);
    String newJsonString = convertObjectToArray(modifiedJson, 'T_FAC_PED');
    Map<String, Object> responseFlujoDocumentos = (Map<String, Object>) JSON.deserializeUntyped(
      newJsonString
    );
    System.debug('el JSON ' + newJsonString);

    Wrapper newWrapper = new Wrapper();
    set<String> setOrderIds = new Set<String>();
    set<String> setAccIds = new Set<String>();
    Set<Decimal> grupoVendedor = new Set<Decimal>();

    if (response.getBody() == 'Unable to connect to the remote server') {
      AuraHandledException e = new AuraHandledException('');
      e.setMessage(
        'Servicio Inactivo, contacte a su Administrador de Salesforce para mas información.'
      );
      throw e;
    }
    IMP_FlujoDocumentos facturasResponse = (IMP_FlujoDocumentos) JSON.deserialize(
      newJsonString,
      IMP_FlujoDocumentos.class
    );
    List<Factura__c> listFacturas = new List<Factura__c>();
    List<OrderItem> listItems = new List<OrderItem>();
    Map<String, List<IMP_FlujoDocumentos.T_FAC_PED>> mapFacturas = new Map<String, List<IMP_FlujoDocumentos.T_FAC_PED>>();

    Map<String, String> mapCentroSuministrador = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = Account.centro_suministrador__c.getDescribe();
    for (Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
      mapCentroSuministrador.put(f.getValue(), f.getLabel());
    }
    for (IMP_FlujoDocumentos.T_FAC_PED factura : facturasResponse.T_FAC_PED) {
      if (!mapFacturas.containsKey(factura.VBELN)) {
        mapFacturas.put(
          factura.VBELN,
          new List<IMP_FlujoDocumentos.T_FAC_PED>()
        );
      }
      mapFacturas.get(factura.VBELN).add(factura);
      setOrderIds.add(factura.AUBEL);
      setAccIds.add(factura.KUNAG);
      if (factura.VKGRP != '' && factura.VKGRP != null) {
        grupoVendedor.add(Decimal.valueOf(factura.VKGRP));
      }
      //setAccIds.add(factura.KUNAG+factura.VKORG_AUFT+factura.VTWEG_AUFT+factura.SPART);
    }

    Map<String, Account> mapCuentas = getCuentas(setAccIds);
    Map<String, Order> mapPedidos = getPedidos(setOrderIds);
    Map<String, User> mapUsers = getUsers(grupoVendedor);

    for (String key : mapFacturas.keySet()) {
      Factura__c newFactura = new Factura__c();
      newFactura.IMP_LlaveExclusiva__c = key;
      newFactura.Name = key;
      Decimal montoFactura = 0;
      for (IMP_FlujoDocumentos.T_FAC_PED factura : mapFacturas.get(key)) {
        montoFactura += factura.NETWR;
        if (mapPedidos.containsKey(factura.AUBEL)) {
          listItems.add(
            new OrderItem(
              IMP_LlaveExclusiva__c = factura.AUBEL +
                '-' +
                factura.POSNR.replaceFirst('^0+', '') +
                '-' +
                factura.MATNR.replaceFirst('^0+', ''),
              IMP_Estatus__c = factura.STATUSG == '' ||
                factura.STATUSG == null
                ? 'No relevante'
                : factura.STATUSG
            )
          );
        }
      }

      String sucursal =
        'Sucursal ' +
        mapCentroSuministrador.get(mapFacturas.get(key).get(0).VWERK);
      String sucursalSinAcento = sucursal.replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replace('ó', 'o')
        .replaceAll('ú', 'u');
      newFactura.IMP_MontoFactura__c = montoFactura;
      newFactura.IMP_Pedido__c = mapPedidos.ContainsKey(
          mapFacturas.get(key).get(0).AUBEL
        )
        ? mapPedidos.get(mapFacturas.get(key).get(0).AUBEL).Id
        : null;
      newFactura.IMP_FechaFactura__c = Date.valueOf(
        mapFacturas.get(key).get(0).FKDAT
      );
      newFactura.IMP_ClaseFactura__c = mapFacturas.get(key).get(0).FKART;
      newFactura.IMP_CanalVentas__c = mapFacturas.get(key).get(0).VTWEG_AUFT;
      newFactura.IMP_Usuario__c = mapFacturas.get(key).get(0).ERNAM;
      newFactura.IMP_Cliente__c = mapCuentas.containsKey(
          mapFacturas.get(key).get(0).KUNAG +
            mapFacturas.get(key).get(0).VKORG_AUFT +
            mapFacturas.get(key).get(0).VTWEG_AUFT +
            mapFacturas.get(key).get(0).SPART
        )
        ? mapCuentas.get(
              mapFacturas.get(key).get(0).KUNAG +
                mapFacturas.get(key).get(0).VKORG_AUFT +
                mapFacturas.get(key).get(0).VTWEG_AUFT +
                mapFacturas.get(key).get(0).SPART
            )
            .Id
        : System.label.IMP_Cuenta;
      newFactura.IMP_NombreCliente__c =
        mapFacturas.get(key).get(0).NAME1 +
        ' ' +
        mapFacturas.get(key).get(0).NAME2 +
        ' ' +
        mapFacturas.get(key).get(0).NAME3 +
        ' ' +
        mapFacturas.get(key).get(0).NAME4;
      newFactura.IMP_NumeroCliente__c = mapFacturas.get(key).get(0).KUNAG;
      newFactura.IMP_CondicionesPago__c = mapFacturas.get(key).get(0).ZTERM;
      newFactura.IMP_CentroBeneficio__c = mapFacturas.get(key).get(0).PRCTR;
      newFactura.IMP_DescGrupoVendedor__c = mapFacturas.get(key).get(0).BEZEI;
      newFactura.IMP_DescCeBe__c = mapFacturas.get(key).get(0).LTEXT;
      newFactura.IMP_GrupoVendedor__c = mapFacturas.get(key).get(0).VKGRP;
      newFactura.IMP_Vendedor__c = (mapFacturas.get(key).get(0).VKGRP == '001')
        ? mapUsers.containsKey(sucursal)
            ? mapUsers.get(sucursal).id
            : mapUsers.containsKey(sucursalSinAcento)
                ? mapUsers.get(sucursalSinAcento).id
                : UserInfo.getUserId()
        : mapUsers.containsKey(mapFacturas.get(key).get(0).VKGRP)
            ? mapUsers.get(mapFacturas.get(key).get(0).VKGRP).id
            : UserInfo.getUserId();
      newFactura.OwnerId = newFactura.IMP_Vendedor__c;
      listFacturas.add(newFactura);
    }
    newWrapper.estatus = 'SUCCESS';
    newWrapper.listFacturas = listFacturas;
    newWrapper.noFacturas = listFacturas.size();
    newWrapper.items = listItems;
    newWrapper.noItems = listItems.size();
    System.debug('NO DE FACTURAS');
    System.debug(newWrapper.noFacturas);
    return newWrapper;
  }

  /*******************************************************************
    Purpose: Obtiene un Map con pedidos, la llave es el Id Externo
    Parameters: String recordId
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  public static Map<String, Order> getPedidos(set<String> orderIds) {
    Map<String, Order> mapPedidos = new Map<String, Order>();
    try {
      for (Order pedido : [
        SELECT ID, pedido__c
        FROM Order
        WHERE pedido__c != NULL AND pedido__c IN :orderIds
      ]) {
        mapPedidos.put(pedido.pedido__c, pedido);
      }
    } catch (Exception exc) {
    }

    return mapPedidos;
  }

  /*******************************************************************
    Purpose: Obtiene un Map con las Cuentas, la llave es el Id Externo
    Parameters: String recordId
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  public static Map<String, Account> getCuentas(set<String> accIds) {
    Map<String, Account> mapAccounts = new Map<String, Account>();
    try {
      for (Account cuenta : [
        SELECT
          ID,
          IMP_LlaveExterna__c,
          Name,
          id_de_sap__c,
          OrganizacionVentas__c,
          clave_delcanal__c,
          Sector__c
        FROM Account
        WHERE id_de_sap__c != NULL AND id_de_sap__c IN :accIds
      ]) {
        mapAccounts.put(cuenta.IMP_LlaveExterna__c, cuenta);
      }
    } catch (Exception exc) {
    }

    return mapAccounts;
  }

  /*******************************************************************
    Purpose: Obtiene un Map con los Usuarios, la llave es el Grupo de Vendedor
    Parameters: String recordId
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  public static Map<String, User> getUsers(Set<Decimal> grupoVendedor) {
    Map<String, User> mapUsers = new Map<String, User>();

    try {
      for (User usuario : [
        SELECT Id, Grupo_de_Vendedor__c, Name
        FROM User
        WHERE
          (Grupo_de_Vendedor__c IN :grupoVendedor
          OR Name LIKE 'Sucursal%')
          AND IsActive = TRUE
          AND Name != 'SAP Integrator'
      ]) {
        mapUsers.put(String.valueOf(usuario.Grupo_de_Vendedor__c), usuario);
        mapUsers.put(String.valueOf(usuario.Name), usuario);
      }
    } catch (Exception exc) {
    }

    return mapUsers;
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
      Object tA305Object = jsonData.get(objectKey);
      if (tA305Object instanceof Map<String, Object>) {
        Map<String, Object> tA305Map = (Map<String, Object>) tA305Object;
        if (
          tA305Map.containsKey('item') &&
          tA305Map.get('item') instanceof List<Object>
        ) {
          List<Object> itemList = (List<Object>) tA305Map.get('item');
          jsonData.put(objectKey, itemList);
          jsonData.remove('item');
        }
      }
    }

    String updatedJsonDataString = JSON.serialize(jsonData);

    // Paso 4: Convertir el mapa en formato JSON
    return JSON.serialize(jsonData);
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
}
