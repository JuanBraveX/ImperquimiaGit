/************************************************************************
Name: IMP_ConsultaCredito
Copyright © 2022 Salesforce
========================================================================
Purpose: Consulta los datos crediticios de una cuenta.
Controller
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
1.0      rotrejo@ts4.mx    22/03/2022     INITIAL        DEV CSR:
************************************************************************/

public without sharing class IMP_ConsultaCredito {
  public String I_KUNNR; //0001000011
  public String KUNNR; //'
  public String BLDAT; //20220506
  public String BUKRS; //IMQ
  public Decimal SALDO_TOTAL;
  public Decimal SALDO_VENCIDO;
  public Decimal V_COMPROMETIDO;
  public Decimal V_LIMITE_CREDITO;
  public Decimal V_SALDO_30_DIAS;
  public Decimal V_SALDO_60_DIAS;
  public Decimal V_SALDO_90_DIAS;
  public Integer V_TOTAL_30_DIAS;
  public Integer V_TOTAL_60_DIAS;
  public Integer V_TOTAL_90_DIAS;
  public Integer V_TOTAL_ACTUAL_LINE;
  public Integer V_TOTAL_LINE;
  public Integer V_TOTAL_VENCID_LINE;

  public cls_IT_DOCUMENTOS[] IT_DOCUMENTOS;
  //public IT_DOCUMENTOS IT_DOCUMENTOS;
  /*
	public class IT_DOCUMENTOS {
        public List<cls_IT_DOCUMENTOS> item;
    }
*/

  public class cls_IT_DOCUMENTOS {
    public String DOC_TYPE;
    public String DOC_NO;
    public Date DATE_OFF;
    public Decimal LC_AMOUNT;
  }
  public cls_credito[] credito;
  public class cls_credito {
    public String KUNNR; //
    public String KKBER; //
    public Decimal KLIMK; //0
    public Decimal KLIME; //0
    public String WAERS; //
  }
  public class UpdateCredito {
    public String KUNNR; //1000011
    public String KKBER; //IMQ
    public Decimal KLIMK; //150000
    public String DBWAE; //MXN
    public Decimal KLIMG; //150000
    public Decimal KLIME; //150000
    public String WAERS; //MXN
  }

  public class MyException extends Exception {
  }

  public static Boolean hasError = false;

  /*******************************************************************
    Purpose: Modifica el credito de un Cliente
    Parameters: String idCliente,Decimal lineaCredito
    Returns: 
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  @future(callout=true)
  public static void updateCredito(String idCliente, Decimal lineaCredito) {
    System.debug('idCliente' + idCliente);
    System.debug('lineaCredito' + lineaCredito);
    UpdateCredito cred = new UpdateCredito();
    cred.KUNNR = idCliente;
    cred.KKBER = 'IMQ';
    cred.KLIMK = lineaCredito;
    cred.DBWAE = 'MXN';
    cred.KLIMG = lineaCredito;
    cred.KLIME = lineaCredito;
    cred.WAERS = 'MXN';
    String body = JSON.serialize(cred);
    HttpResponse response = getResponse(
      body,
      IMP_ServiceConstants.ACTUALIZACION_CREDITO_API_URL
    );
    Map<String, Object> values = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );

    System.debug(
      'response update cr ' +
        String.valueOf(values.get('E_MESSAGE')) +
        response.getBody()
    );
    //hasError = true;
  }

  /*******************************************************************
    Purpose: Obtiene la respuesta del servicio de consulta de Credito
    Parameters: String body
    Returns: HttpResponse
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  public static HttpResponse getResponse(String body, String apiUrl) {
    HttpResponse response;
    //String token = IMP_CrearClienteSap_CC.retriveToken().token;
    final Integer TIMEOUT_SERV = 120000;
    String API_URL = apiUrl;
    String URL_FINAL = 'imperquiaSAP' + API_URL;
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
    Map<String, String> headers = new Map<String, String>{
      'Content-Type' => 'application/json',
      'Authorization' => authHeader
    };
    try {
      HttpRequest req = IMP_CalloutUtils.generateRequest(
        IMP_CalloutConstants.METHOD_POST,
        URL_FINAL,
        params,
        headers,
        TIMEOUT_SERV,
        body
      );

      response = IMP_CalloutUtils.doRequest(req, true);
      system.debug('Response body1 : ' + response.getBody());
      System.debug(response.getStatusCode());
    } catch (Exception exc) {
      System.debug(exc.getMessage());
    }

    return response;
  }

  /*******************************************************************
    Purpose: Obtiene el credito de un cliente sintetizado en un Mapa
    Parameters: String clienteId
    Returns: Map
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/

  public static Map<String, Decimal> getCredito(String clienteId) {
    Map<String, Decimal> mapResponse = new Map<String, Decimal>();
    IMP_ConsultaCredito consultaCredito = new IMP_ConsultaCredito();
    List<cls_credito> creditos = new List<cls_credito>();
    cls_credito cred = new cls_credito();
    consultaCredito.I_KUNNR = clienteId;
    consultaCredito.credito = creditos;
    String body = JSON.serialize(consultaCredito);

    HttpResponse response = getResponse(
      body,
      IMP_ServiceConstants.CREDITO_API_URL
    );
    IMP_ConsultaCredito responseCredito = (IMP_ConsultaCredito) JSON.deserialize(
      response.getBody(),
      IMP_ConsultaCredito.class
    );
    for (IMP_ConsultaCredito.cls_credito credito : responseCredito.credito) {
      System.debug('credito.KLIME' + credito.KLIME);
      System.debug('credito.KLIMK' + credito.KLIMK);
      mapResponse.put(credito.KUNNR, credito.KLIMK - credito.KLIME);
    }
    return mapResponse;
  }

  /*******************************************************************
    Purpose: Obtiene el registro de una cuenta.
    Parameters: String accountId
    Returns: Account
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  @AuraEnabled
  public static Account consultaIdSAP(String accountId) {
    return [
      SELECT Id, SAP_Validated__c, Estatus__c, id_de_sap__c
      FROM Account
      WHERE Id = :accountId
    ];
  }

  /*******************************************************************
    Purpose: Modifica el credito de una cuenta.
    Parameters: String idCliente
    Returns: Wrapper
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  @auraEnabled
  public static Wrapper updateCreditoCuenta(String idCliente) {
    Wrapper returnData = new Wrapper();
    try {
      IMP_ConsultaCredito consultaCredito = new IMP_ConsultaCredito();
      List<cls_credito> creditos = new List<cls_credito>();
      cls_credito cred = new cls_credito();
      consultaCredito.I_KUNNR = idCliente;
      consultaCredito.credito = creditos;
      String body = JSON.serialize(consultaCredito);

      HttpResponse response = getResponse(
        body,
        IMP_ServiceConstants.CREDITO_API_URL
      );
      Account account = [
        SELECT Id, Credito_Acumulado__c, LineaCredito__c, id_de_sap__c
        FROM Account
        WHERE id_de_sap__c = :idCliente
      ];
      IMP_ConsultaCredito responseCredito = (IMP_ConsultaCredito) JSON.deserialize(
        response.getBody(),
        IMP_ConsultaCredito.class
      );

      for (IMP_ConsultaCredito.cls_credito credito : responseCredito.credito) {
        account.Credito_Acumulado__c = credito.KLIME;
        account.LineaCredito__c = credito.KLIMK;
        System.debug('credito.KLIME' + credito.KLIME);
        System.debug('credito.KLIMK' + credito.KLIMK);
        returnData.status = 'SUCCESS';
      }
      upsert account;
    } catch (Exception exc) {
      System.debug(exc.getMessage());
      returnData.status = 'ERROR';
      returnData.mensaje = exc.getMessage();
    }
    return returnData;
  }

  /*******************************************************************
    Purpose: Modifica el credito de una cuenta y crea estados de cuenta.
    Parameters: String idCliente
    Returns: Wrapper
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
  @auraEnabled
  public static Wrapper updateEdoCuenta(String clienteId, String idCuenta) {
    Wrapper returnData = new Wrapper();
    try {
      IMP_ConsultaCredito consultaCredito = new IMP_ConsultaCredito();
      List<cls_IT_DOCUMENTOS> documentos = new List<cls_IT_DOCUMENTOS>();
      consultaCredito.BLDAT = '';
      consultaCredito.BUKRS = 'IMQ';
      consultaCredito.KUNNR = clienteId;
      consultaCredito.IT_DOCUMENTOS = documentos;
      String body = JSON.serialize(consultaCredito);

      List<EstadoCuenta__c> listaEdoCuenta = new List<EstadoCuenta__c>();
      Map<String, String> mapDocs = new Map<String, String>();
      List<EstadoCuenta__c> listDocumentsDelete = new List<EstadoCuenta__c>();
      HttpResponse response = getResponse(
        body,
        IMP_ServiceConstants.SALDOS_API_URL
      );
      System.debug('Antes de deserialize');
      system.debug('show the ' + response.getBody());
      /*Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
      String[] toaddresses = new List<String>{ 'jpedraza@ts4.mx' };
      mymail.setToAddresses(toAddresses);
      mymail.setSenderDisplayName('Salesforce Support');
      mymail.setSubject('An email from Salesforce');
      mymail.setPlainTextBody('This email has been sent through Apex');
      mymail.setHtmlBody('<p>' + response.getBody() + '</p>');

      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mymail });*/
      //IMP_ConsultaCredito responseCredito = (IMP_ConsultaCredito)JSON.deserialize(response.getBody(), IMP_ConsultaCredito.class);
      Map<String, Object> responseCredito = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      Account account = [
        SELECT
          Id,
          Credito_Acumulado__c,
          LineaCredito__c,
          id_de_sap__c,
          IMP_TotalEstadosCuenta__c,
          IMP_SaldoVencido__c,
          IMP_SaldoComprometido__c,
          IMP_Saldo30__c,
          IMP_Saldo60__c,
          IMP_Saldo90__c,
          IMP_Documentos30dias__c,
          IMP_Documentos60dias__c,
          IMP_Documentos90dias__c,
          IMP_TotalFacturas__c,
          IMP_TotalFacturasVencidas__c
        FROM Account
        WHERE Id = :idCuenta
      ];

      //SALDO_ACTUAL --credito disponible
      account.Credito_Acumulado__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_COMPROMETIDO'))
      );
      account.IMP_TotalEstadosCuenta__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('SALDO_TOTAL'))
      );
      account.IMP_SaldoVencido__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('SALDO_VENCIDO'))
      );
      account.IMP_SaldoComprometido__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_COMPROMETIDO'))
      );
      account.LineaCredito__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_LIMITE_CREDITO'))
      );
      account.IMP_Saldo30__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_SALDO_30_DIAS'))
      );
      account.IMP_Saldo60__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_SALDO_60_DIAS'))
      );
      account.IMP_Saldo90__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_SALDO_90_DIAS'))
      );
      account.IMP_Documentos30dias__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_TOTAL_30_DIAS'))
      );
      account.IMP_Documentos60dias__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_TOTAL_60_DIAS'))
      );
      account.IMP_Documentos90dias__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_TOTAL_90_DIAS'))
      );
      //V_TOTAL_ACTUAL_LINE
      account.IMP_TotalFacturas__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_TOTAL_LINE'))
      );
      account.IMP_TotalFacturasVencidas__c = Decimal.valueOf(
        String.valueOf(responseCredito.get('V_TOTAL_VENCID_LINE'))
      );
      List<cls_IT_DOCUMENTOS> resposeIT_DOCUMENTOS = new List<cls_IT_DOCUMENTOS>();

      Map<String, Object> itDocumentos = new Map<String, Object>();

      if(String.valueOf(responseCredito.get('IT_DOCUMENTOS'))!=''){
        itDocumentos = (Map<String, Object>) responseCredito.get(
          'IT_DOCUMENTOS'
        );
      }

      List<Object> itemObjects = (List<Object>) itDocumentos.get('item');

      if (itemObjects != null) {
        List<cls_IT_DOCUMENTOS> IT_DOCUMENTOS = new List<cls_IT_DOCUMENTOS>();
        for (Object itemObject : itemObjects) {
          Map<String, Object> itemMap = (Map<String, Object>) itemObject;
          IMP_ConsultaCredito.cls_IT_DOCUMENTOS item = new IMP_ConsultaCredito.cls_IT_DOCUMENTOS();
          item.DOC_TYPE = (String) itemMap.get('DOC_TYPE');
          item.DOC_NO = (String) itemMap.get('DOC_NO');
          // Convierte la cadena de fecha a un valor de fecha
          String dateStr = (String) itemMap.get('DATE_OFF');
          item.DATE_OFF = Date.valueOf(dateStr);
          // Convierte la cadena numérica a decimal
          String lcAmountStr = (String) itemMap.get('LC_AMOUNT');
          item.LC_AMOUNT = Decimal.valueOf(lcAmountStr);
          IT_DOCUMENTOS.add(item);
        }
        // Asigna la lista de objetos IT_DOCUMENTOS a tu objeto principal
        resposeIT_DOCUMENTOS = IT_DOCUMENTOS;
      }

      try {
        upsert account;
        returnData.status = 'SUCCESS';
        returnData.mensaje = 'Crédito actualizado';
      } catch (Exception e) {
        System.debug(e.getMessage());
        returnData.mensaje =
          'Error al actualizar el crédito : ' + e.getMessage();
        returnData.status = 'ERROR';
      }

      List<EstadoCuenta__c> listaDocs = new List<EstadoCuenta__c>(
        [
          SELECT Id, Cuenta__c, IMP_LlaveExclusiva__c
          FROM EstadoCuenta__c
          WHERE Cuenta__c = :account.Id
        ]
      );
      for (
        IMP_ConsultaCredito.cls_IT_DOCUMENTOS documento : resposeIT_DOCUMENTOS
      ) {
        mapDocs.put(documento.DOC_NO, documento.DOC_TYPE);
        listaEdoCuenta.add(
          new EstadoCuenta__c(
            Cuenta__c = account.Id,
            Prefijo__c = documento.DOC_TYPE,
            Name = documento.DOC_NO,
            Vencimiento__c = documento.DATE_OFF,
            Valor__c = documento.LC_AMOUNT,
            IMP_LlaveExclusiva__c = documento.DOC_NO
          )
        );
      }

      for (EstadoCuenta__c edoC : listaDocs) {
        if (!mapDocs.containsKey(edoC.IMP_LlaveExclusiva__c)) {
          listDocumentsDelete.add(edoC);
        }
      }
      delete listDocumentsDelete;
      Database.UpsertResult[] results = Database.upsert(
        listaEdoCuenta,
        EstadoCuenta__c.IMP_LlaveExclusiva__c,
        false
      );
      for (Database.upsertResult res : results) {
        if (res.isSuccess()) {
          System.debug('Estado de cuenta creado : ' + res.getId());
        }
        for (Database.Error err : res.getErrors()) {
          System.debug('ERROR AL CREAR Estado cuenta: ' + err);
        }
      }
    } catch (Exception e) {
      returnData.mensaje = e.getMessage();
    }
    return returnData;
  }

  public class Wrapper {
    @AuraEnabled
    public String mensaje { get; set; }
    @auraEnabled
    public String status { get; set; }
  }
}
