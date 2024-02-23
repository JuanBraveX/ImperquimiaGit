/************************************************************************
Name: IMP_FlujoDocumentosMock
Copyright © 2022 Salesforce
========================================================================
Purpose:
Clase Mock para realizar la simulación de respuesta del servicio de Flujo de documentos
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
2.0      dmarcos@ts4.mx        01/04/2022   
************************************************************************/
@isTest
global class IMP_FlujoDocumentosMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest request){
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"VBELV": "528022"}');
        response.setStatus('OK');
        response.setStatusCode(200);
        return response;
    }

}