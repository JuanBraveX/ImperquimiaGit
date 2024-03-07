/************************************************************************
Name: IMP_ListPedido
Copyright © 2022 Salesforce
========================================================================
Purpose:
Servicio web para la consulta de pedidos desde SAP 
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
 1.0      rotrejo@ts4.mx      12/05/2023    
************************************************************************/
public class IMP_ListPedido {
  public String PI_FFIN;
  public String PI_FINI;
  public List<IMP_EnvioPedidoSAP> IT_PEDIDOS;

  /*******************************************************************
    Purpose: Actualiza los pedidos al dia de hoy.
    Parameters:
    Returns:
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  public static List<Order> getListPedido(
    String fechaInicial,
    String fechaFinal
  ) {
    IMP_ListPedido newConsulta = new IMP_ListPedido();
    List<IMP_EnvioPedidoSAP> listPedidos = new List<IMP_EnvioPedidoSAP>();
    IMP_EnvioPedidoSAP pedido = new IMP_EnvioPedidoSAP();
    listPedidos.add(pedido);
    System.debug(String.valueOf(fechaInicial));
    System.debug(String.valueOf(fechaFinal));
    newConsulta.PI_FFIN = fechaFinal; //'31-05-2023';
    newConsulta.PI_FINI = fechaInicial; //'01-05-2023';
    newConsulta.IT_PEDIDOS = listPedidos;
    String body = JSON.serialize(newConsulta);
    System.debug(body);
    HttpResponse response = IMP_CalloutUtils.getResponse(
      body,
      IMP_ServiceConstants.PEDIDOS_API_URL
    );
    System.debug(response.getBody());
    Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );
    convertirAListaSiNecesario(jsonData, 'IT_PEDIDOS');
    String modifiedJson = JSON.serialize(jsonData);
    String newJsonString = convertObjectToArray(modifiedJson, 'IT_PEDIDOS');
    Map<String, Object> responseFlujoDocumentos = (Map<String, Object>) JSON.deserializeUntyped(
      newJsonString
    );
    System.debug('el JSON ' + newJsonString);
    IMP_ListPedido discountResponse = (IMP_ListPedido) JSON.deserialize(
      newJsonString,
      IMP_ListPedido.class
    );
    List<Order> newListOrders = new List<Order>();
    set<String> setAccIds = new Set<String>();
    Set<Decimal> grupoVendedor = new Set<Decimal>();
    for (IMP_EnvioPedidoSAP nuevoPedido : discountResponse.IT_PEDIDOS) {
      setAccIds.add(nuevoPedido.I_KUNNR);
      if (nuevoPedido.I_VKGRP != '') {
        grupoVendedor.add(Decimal.valueOf(nuevoPedido.I_VKGRP));
      }
    }
    Map<String, Account> mapCuentas = IMP_FlujoDocumentos.getCuentas(setAccIds);
    Map<String, User> mapUsers = IMP_FlujoDocumentos.getUsers(grupoVendedor);
    Map<String, String> mapCentroSuministrador = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = Account.centro_suministrador__c.getDescribe();
    for (Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
      mapCentroSuministrador.put(f.getValue(), f.getLabel());
    }
    for (IMP_EnvioPedidoSAP nuevoPedido : discountResponse.IT_PEDIDOS) {
      String sucursal =
        'Sucursal ' + mapCentroSuministrador.get(nuevoPedido.EXT1);
      String sucursalSinAcento = sucursal.replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replace('ó', 'o')
        .replaceAll('ú', 'u');
      newListOrders.add(
        new Order(
          pedido__c = nuevoPedido.E_VBELN,
          ViaPago__c = nuevoPedido.ZLSCH,
          AccountId = mapCuentas.containsKey(
              nuevoPedido.I_KUNNR +
                nuevoPedido.I_VKORG +
                nuevoPedido.I_VTWEG +
                nuevoPedido.SPART
            )
            ? mapCuentas.get(
                  nuevoPedido.I_KUNNR +
                    nuevoPedido.I_VKORG +
                    nuevoPedido.I_VTWEG +
                    nuevoPedido.SPART
                )
                .Id
            : System.label.IMP_Cuenta,
          EffectiveDate = nuevoPedido.BSTDK.length() == 8 &&
            nuevoPedido.BSTDK != '00000000'
            ? Date.valueOf(
                nuevoPedido.BSTDK.substring(0, 4) +
                  '-' +
                  nuevoPedido.BSTDK.substring(4, 6) +
                  '-' +
                  nuevoPedido.BSTDK.substring(6, 8)
              )
            : nuevoPedido.BSTDK == '00000000'
                ? Date.today()
                : Date.valueOf(nuevoPedido.BSTDK),
          IMP_ClaseDocumento__c = nuevoPedido.AUART,
          IMP_OficinaVentas__c = nuevoPedido.I_VKBUR,
          IMP_CanalVentas__c = nuevoPedido.I_VKORG,
          IMP_SectorVentas__c = nuevoPedido.SPART,
          IMP_NumeroCliente__c = nuevoPedido.I_KUNNR,
          IMP_GrupoVendedor__c = nuevoPedido.I_VKGRP,
          IMP_DescripcionGrupoVendedor__c = nuevoPedido.BEZEI,
          IMP_DescripcionCeBe__c = nuevoPedido.LTEXT,
          IMP_CentroBeneficio__c = nuevoPedido.PRCTR,
          Precio_Total__c = nuevoPedido.NETWR != null &&
            nuevoPedido.NETWR != ''
            ? Decimal.valueOf(nuevoPedido.NETWR.replace(' ', ''))
            : 0,
          IMP_CreadoPor__c = nuevoPedido.ERNAM,
          Status = nuevoPedido.GBSTK != '' ? nuevoPedido.GBSTK : 'Draft',
          condiciones_de_pago__c = nuevoPedido.ZTERM,
          IMP_CanalDistribucion__c = nuevoPedido.I_VTWEG,
          OwnerId = (nuevoPedido.I_VKGRP == '001')
            ? mapUsers.containsKey(sucursal)
                ? mapUsers.get(sucursal).id
                : mapUsers.containsKey(sucursalSinAcento)
                    ? mapUsers.get(sucursalSinAcento).id
                    : UserInfo.getUserId()
            : mapUsers.containsKey(nuevoPedido.I_VKGRP)
                ? mapUsers.get(nuevoPedido.I_VKGRP).id
                : UserInfo.getUserId()
        )
      );
    }
    return newListOrders;
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
