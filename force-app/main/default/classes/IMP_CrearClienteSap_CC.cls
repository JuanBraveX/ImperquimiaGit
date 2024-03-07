/************************************************************************
Name: IMP_CrearClienteSap_CC
Copyright © 2024 Salesforce
========================================================================
Purpose:
Genera cuentas de salesforce hacia SAP
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
3.0      jpedraza@ts4.mx    01/29/2024     3 Version.
************************************************************************/
public without sharing class IMP_CrearClienteSap_CC {
  @AuraEnabled
  public Account cuenta;
  @AuraEnabled
  public String status;
  @AuraEnabled
  public String mensaje;
  @AuraEnabled
  public Boolean enviadoSap;
  @AuraEnabled
  public String token;
  @AuraEnabled
  public Boolean validToken;

  /*******************************************************************
Purpose: Regresa la cuenta que se recibe como parámetro.
Parameters: String accountId
Returns: Account
Throws [Exceptions]:
Information about changes (versions) []:
********************************************************************/
  @AuraEnabled
  public static IMP_CrearClienteSap_CC sapValidated(String accountId) {
    IMP_CrearClienteSap_CC dataReturn = new IMP_CrearClienteSap_CC();
    Id userId = UserInfo.getUserId();
    String missingFields = '';
    String status = '';
    User currentUser = [
      SELECT CurrencyIsoCode, Grupo_de_Vendedor__c
      FROM User
      WHERE Id = :userId
    ];
    Account acc = [
      SELECT
        Id,
        SAP_Validated__c,
        Estatus__c,
        id_de_sap__c,
        IMP_PaisFacturacion__c,
        Name,
        Phone,
        Colonia__c,
        Delegacion__c,
        IMP_CodigoPostal__c,
        billing_address_state__c,
        RFC__c,
        Grupo_de_Cuentas__c,
        condiciones_de_pago__c,
        grupo_de_tesoreria__c,
        OrganizacionVentas__c,
        clave_delcanal__c,
        Sector__c,
        grupo__c,
        zona_de_ventas__c,
        Grupo_de_precios__c,
        ListaPrecios__c,
        centro_suministrador__c,
        CurrencyIsoCode,
        RegimenFiscal__c,
        Numero_Exterior__c
      FROM Account
      WHERE Id = :accountId
    ];
    dataReturn.cuenta = acc;
    dataReturn.enviadoSap = acc.id_de_sap__c == null ? false : true;
    missingFields += acc.IMP_PaisFacturacion__c == '' ||
      acc.IMP_PaisFacturacion__c == null
      ? ' * País Facturación \n'
      : '';
    missingFields += acc.Name == '' ||
      acc.Name == null
      ? ' * Nombre de la Cuenta \n'
      : '';
    missingFields += acc.Phone == '' ||
      acc.Phone == null
      ? ' * Teléfono \n'
      : '';
    missingFields += acc.Colonia__c == '' ||
      acc.Colonia__c == null
      ? ' * Colonia \n'
      : '';
    missingFields += acc.Delegacion__c == '' ||
      acc.Delegacion__c == null
      ? '* Delegación \n'
      : '';
    missingFields += acc.IMP_CodigoPostal__c == '' ||
      acc.IMP_CodigoPostal__c == null
      ? ' * Codigo Postal \n'
      : '';
    missingFields += acc.billing_address_state__c == '' ||
      acc.billing_address_state__c == null
      ? ' * Estado de facturación \n'
      : '';
    missingFields += acc.RFC__c == '' || acc.RFC__c == null ? '* RFC \n' : '';
    missingFields += acc.Grupo_de_Cuentas__c == '' ||
      acc.Grupo_de_Cuentas__c == null
      ? ' * Grupo de Cuentas \n'
      : '';
    missingFields += acc.condiciones_de_pago__c == '' ||
      acc.condiciones_de_pago__c == null
      ? ' * Condiciones de Pago \n'
      : '';
    missingFields += acc.grupo_de_tesoreria__c == '' ||
      acc.grupo_de_tesoreria__c == null
      ? ' * Grupo de Tesoreria \n'
      : '';
    missingFields += acc.OrganizacionVentas__c == ''
      ? ' * Organización de Ventas \n'
      : '';
    missingFields += acc.clave_delcanal__c == '' ||
      acc.clave_delcanal__c == null
      ? ' * Clave de Canal \n'
      : '';
    missingFields += acc.Sector__c == '' ||
      acc.Sector__c == null
      ? ' * Sector \n'
      : '';
    missingFields += acc.grupo__c == '' ||
      acc.grupo__c == null
      ? ' * Grupo \n'
      : '';
    missingFields += acc.zona_de_ventas__c == '' ||
      acc.zona_de_ventas__c == null
      ? ' * Zona de Ventas \n'
      : '';
    missingFields += acc.Grupo_de_precios__c == '' ||
      acc.Grupo_de_precios__c == null
      ? ' * Grupo de Precios \n'
      : '';
    missingFields += acc.ListaPrecios__c == '' ||
      acc.ListaPrecios__c == null
      ? ' * Lista de Precios \n'
      : '';
    missingFields += acc.centro_suministrador__c == '' ||
      acc.centro_suministrador__c == null
      ? ' * Centro Suministrador \n'
      : '';
    missingFields += currentUser.Grupo_de_Vendedor__c == null
      ? ' * Usuario --> Grupo de Vendedor \n'
      : '';
    missingFields += acc.CurrencyIsoCode == '' ||
      acc.CurrencyIsoCode == null
      ? ' * Divisa \n'
      : '';
    missingFields += acc.RegimenFiscal__c == '' ||
      acc.RegimenFiscal__c == null
      ? ' * Regimen Fiscal \n'
      : '';
    missingFields += acc.Numero_Exterior__c == '' ||
      acc.Numero_Exterior__c == null
      ? ' * Número Exterior \n'
      : '';
    missingFields += acc.Estatus__c == '' ||
      acc.Estatus__c == null
      ? ' * La Cuenta no ha sido aprobada \n'
      : '';
    status = missingFields != '' ||
      !acc.SAP_Validated__c ||
      dataReturn.enviadoSap
      ? 'ERROR'
      : 'SUCCESS';
    dataReturn.token = '101210'; //IMP_CalloutUtils.retriveToken();
    dataReturn.mensaje = missingFields;
    dataReturn.status = status;
    dataReturn.validToken = dataReturn.token != '' ? true : false;
    return dataReturn;
  }

  /*******************************************************************
Purpose: Realiza el post de las cuentas
Parameters: String token, List<String> lstAccount
Returns: Wrapper
Throws [Exceptions]:
Information about changes (versions) []:
********************************************************************/
  @AuraEnabled
  public static Wrapper postAccount(String token, List<String> lstAccount) {
    Wrapper returnData = new Wrapper();
    String apiUrl = IMP_ServiceConstants.CLIENTES_API_URL;
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
    Map<String, String> headers = new Map<String, String>{
      'Content-Type' => 'application/json',
      'Authorization' => authHeader
    };
    try {
      String body = IMP_CreateJson.createJsonAccount(lstAccount);
      /*Messaging.SingleEmailMessage mymail = new Messaging.SingleEmailMessage();
String[] toaddresses = new String[] {'jpedraza@ts4.mx'}; 
mymail.setToAddresses(toAddresses);
mymail.setSenderDisplayName('Salesforce Support');
mymail.setSubject('An email from Salesforce');
mymail.setPlainTextBody('This email has been sent through Apex');
mymail.setHtmlBody('<p>'+ body +'</p>');

Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mymail });*/
      System.debug('CUERPO DE LA SOLICITUD');
      System.debug(body);
      HttpRequest req = IMP_CalloutUtils.generateRequest(
        IMP_CalloutConstants.METHOD_POST,
        urlFinal,
        params,
        headers,
        120000,
        body
      );
      HttpResponse response = IMP_CalloutUtils.doRequest(req, true);
      System.debug(response.getStatusCode());
      System.debug(response.getBody());
      Map<String, Object> values = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      if (values.get('V_MSG') != '') {
        returnData.status = 'ERROR';
        Blob source = EncodingUtil.base64Decode(String.valueOf(values.get('V_MSG'))); 
        String hexSource = EncodingUtil.convertToHex(source);
        String urlEncoded = hexSource.replaceAll('(.{2})','%$1');
        String recoveredText = EncodingUtil.urlDecode(urlEncoded,'iso-8859-1');
        returnData.mensaje = '' + recoveredText;
        returnData.responseAccount = response.getBody();
      } else {
        Account acc = [
          SELECT
            Id,
            id_de_sap__c,
            centro_suministrador__c,
            IMP_IndicadorImpuesto__c,
            OrganizacionVentas__c,
            clave_delcanal__c,
            Sector__c
          FROM Account
          WHERE Id = :lstAccount
        ];
        Blob idsap = EncodingUtil.base64Decode('' + values.get('E_CLIENTE'));
        acc.id_de_sap__c = '' + idsap.toString();
        acc.IMP_IndicadorImpuesto__c = IMP_CreateJson.getImpuesto(
          acc.clave_delcanal__c,
          acc.centro_suministrador__c
        );
        acc.IMP_LlaveExterna__c =
          acc.id_de_sap__c +
          acc.OrganizacionVentas__c +
          acc.clave_delcanal__c +
          acc.Sector__c;
        upsert acc;
        returnData.responseAccount = response.getBody();
        returnData.status = 'SUCCESS';
      }
    } catch (Exception exc) {
      System.debug(exc.getMessage());
      returnData.status = 'ERROR';
      returnData.mensaje = exc.getMessage();
      Integration_Logs__c systemLog = new Integration_Logs__c(
        Linea__c = String.valueOf(exc.getLineNumber()),
        Clase__c = exc.getTypeName() +
          ' ' +
          exc.getCause() +
          ' ' +
          exc.getStackTraceString(),
         Body_JSON__c = returnData.responseAccount,
        Tipo__c = 'CREACION_CLIENTES_SFDC'
      );
      insert systemLog;
    }
    return returnData;
  }

  @AuraEnabled
  public static Wrapper retriveToken() {
    Wrapper returnData = new Wrapper();
    String apiUrl = IMP_ServiceConstants.AUTHORIZE_API_URL;
    String urlFinal = 'Imperquimia' + apiUrl;
    Map<String, String> params = new Map<String, String>();
    Map<String, String> headers = new Map<String, String>{
      'Content-Type' => 'application/json'
    };
    try {
      String body = IMP_CreateJson.getToken();
      HttpRequest req = IMP_CalloutUtils.generateRequest(
        IMP_CalloutConstants.METHOD_POST,
        urlFinal,
        params,
        headers,
        120000,
        body
      );
      HttpResponse response = IMP_CalloutUtils.doRequest(req, true);

      returnData.token = response.getBody().replace('"', '');
      returnData.status = 'SUCCESS';
    } catch (Exception exc) {
      returnData.status = 'ERROR';
      returnData.mensaje = exc.getMessage();
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
        Body_JSON__c = returnData.responseAccount,
        Tipo__c = 'TOKEN_IIS'
      );
      insert systemLog;
    }
    return returnData;
  }

  public class Wrapper {
    @AuraEnabled
    public String mensaje { get; set; }
    @auraEnabled
    public String status { get; set; }
    @auraEnabled
    public String token { get; set; }
    @auraEnabled
    public String responseAccount { get; set; }
  }
}
