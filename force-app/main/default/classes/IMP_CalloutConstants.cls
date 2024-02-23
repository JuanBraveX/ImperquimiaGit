/************************************************************************
Name: IMP_CalloutConstants
Copyright © 2022 Salesforce
========================================================================
Purpose:
Class used to set type of callout, content type and different types of headers
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      lmagana@ts4.mx     20/01/2021     INITIAL        DEV CSR:
************************************************************************/
public without sharing class IMP_CalloutConstants {
	public static final String METHOD_GET  = 'GET';
    public static final String METHOD_POST = 'POST';
    public static final String METHOD_PUT  = 'PUT';
    public static final String METHOD_DELETE  = 'DELETE';
    
    public static final String CONTENT_TYPE_JSON = 'application/json';
    
    public static final String HEADER_AUTHORIZATION = 'Authorization';
    public static final String HEADER_CONTENT_LENGTH = 'Content-Length';
    public static final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HEADER_CLIENT_ID = 'client-id';
    public static final String HEADER_CLIENT_SECRET = 'client-secret';
    public static final String HEADER_SOURCE = 'source';
}