/************************************************************************
Name: IMP_CalloutUtils
Copyright © 2022 Salesforce
========================================================================
Purpose:
Genera un callout dinámico para cualquier tipo de petición rest.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  2.0      mvilchis@ts4.mx    11/04/2022     SECOND       
************************************************************************/
public without sharing class IMP_CalloutUtils {
	public static final String CLASS_NAME = IMP_CalloutUtils.class.getName();
    
    /*
     * nombre: generateRequest
     * descripcion: usado para generar HttpRequest
     * parametros:
     * method                 -> GET | POST | DELETE | PUT
     * endpoint               -> url
     * (opcional) mParams     -> mapa de parametros para endpoint url (valor de parametro opcional)
     * (opcional) mHeaders    -> mapa de valores de header (valor de header opcional)
     * (opcional) timeout     -> milliseconds 1 a 120000
     * (opcional) body        -> texto
    */
    public static HttpRequest generateRequest(String method, String endpoint, Map<String, String> mParams, Map<String, String> mHeaders, Integer timeout, String body)
    {
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        if(timeout != null && timeout >= 1 && timeout <= 120000)
            req.setTimeout(timeout);
        if(String.isNotBlank(body)) 
            req.setBody(body);
        system.debug('URL : '+endPoint);
        String endPointFinal = 'callout:' + endPoint;
        if(mParams != null && !mParams.isEmpty())
        {
            boolean isFirst = true;
            for(String param: mParams.keySet())
            {
                String paramValue =  String.isBlank(mParams.get(param)) ? '' : EncodingUtil.urlEncode(mParams.get(param), 'UTF-8');
                endPointFinal += (isFirst ? + param + paramValue : + param + '=' + paramValue);
                isFirst = false;
            }
        }
        req.setEndpoint(endPointFinal);
        if(mHeaders != null && !mHeaders.isEmpty())
        {
            for(String header: mHeaders.keySet())
            {
                req.setHeader(header, String.isBlank(mHeaders.get(header)) ? '' : mHeaders.get(header));
            }
        }
        if(String.isBlank(body) && !mHeaders.containsKey(IMP_CalloutConstants.HEADER_CONTENT_LENGTH))
            req.setHeader(IMP_CalloutConstants.HEADER_CONTENT_LENGTH, '0');
        return req;
    }
    
    /*
     * nombre: doRequest
     * descripcion: usado para obtener HttpResponse
     * parametros:
     * req         -> HttpRequest
     * retryOnFail -> boolean
    */
    public static HttpResponse doRequest(HttpRequest req, Boolean retryOnFail)
    {
        if(Limits.getDmlStatements() > 0)
        {
            String errorMsg = 'No se permiten callouts luego de operaciones DML';
            throw new CalloutException(errorMsg);
        }
        HttpResponse res = new Http().send(req);
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201)
        {
            return res;
        }
        else
        {
            // volver a intentar
            if(retryOnFail)
            {
                return doRequest(req, false);
            }
            
            // manejar error
            System.debug( LoggingLevel.ERROR,
                          '*** ' + CLASS_NAME +'.doRequest() fallo: ' + res +
                          '\nresBody: ' + res.getBody() +
                          '\nreqEndpoint: ' + req.getEndpoint() +
                          (String.isNotBlank(req.getBody()) ? '\nreqBody: ' + req.getBody() : '') );
                          
            throw new CalloutException(res.getStatusCode() + ',' + res.getStatus());
        }
    }

    
    public static String retriveToken() {
        String token ='';
        String apiUrl = IMP_ServiceConstants.AUTHORIZE_API_URL;
        String urlFinal = 'Imperquimia'+apiUrl;
        Map<String, String> params = new Map<String, String>();
        Map<String,String> headers = new Map<String,String>{'Content-Type' => 'application/json'};
            try{
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
                token = response.getBody().replace('"','');
                
            }
        catch(Exception exc){
            System.debug('ERROR');
            System.debug(exc.getMessage());
            System.debug(exc.getLineNumber());
            Integration_Logs__c systemLog = new Integration_Logs__c(Linea__c=String.valueOf(exc.getLineNumber()),
                                                                    // Clase__c=exc.getTypeName().substring(0, exc.getTypeName().length()>255?200:exc.getTypeName().length())+' '+exc.getCause()+' '+exc.getStackTraceString(),
                                                                    Mensaje_SFDC__c=exc.getMessage(),Tipo__c='TOKEN_IIS');
            insert systemLog;
        }
        return token;
    }
    
    
    /*******************************************************************
    Purpose: Realiza la peticion al WS 
    Parameters: String recordId
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static HttpResponse getResponse(String body,String url){
        HttpResponse response;
        String token = retriveToken();
        if(token != ''){
            Final Integer TIMEOUT_SERV = 120000;
            String API_URL = url;
            String URL_FINAL = 'Imperquimia'+API_URL;
            Map<String, String> params = new Map<String, String>();
            Map<String,String> headers = new Map<String,String>{'Content-Type' => 'application/json', 'Authorization' => 'Bearer '+token};
                try {
                    HttpRequest req =generateRequest(
                        IMP_CalloutConstants.METHOD_POST, 
                        URL_FINAL,
                        params, 
                        headers, 
                        TIMEOUT_SERV, 
                        body
                    );
                    response = doRequest(req, false);                
                }
            catch(Exception exc){ 
                System.debug(exc.getMessage()+ exc.getLineNumber());
            }
        }
        return response;
    }
    
    public class CalloutException extends Exception {}
}