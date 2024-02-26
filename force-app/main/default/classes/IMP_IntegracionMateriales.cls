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

            list<Database.upsertResult> uResults = Database.upsert(lstUpsert,Product2.IMP_IdExterno__c,false);
            for (Database.upsertResult res : uResults) {
                if(res.isSuccess()){
                    System.debug('Producto creado : '+ res.getId());
                }
                for (Database.Error  err : res.getErrors()) {
                    System.debug('err: ' + err);
                }
                
            }
        }
        catch(Exception exc){
            Integration_Logs__c systemLog = new Integration_Logs__c(Linea__c=String.valueOf(exc.getLineNumber()),
                                            Clase__c=exc.getTypeName().substring(0, exc.getTypeName().length()>255?200:exc.getTypeName().length())+' '+exc.getCause()+' '+exc.getStackTraceString(),
                                            Mensaje_SFDC__c=exc.getMessage(),Body_JSON__c=body,Tipo__c='GET_MATERIALES_SFDC');
        
            insert systemLog;
        }
    }
    //Juan Pedraza
    public cls_IT_MATERIALES[] IT_MATERIALES;
	public class cls_IT_MATERIALES {
		public String MATNR;//MATERIAL
		public String WERKS;//CENTRO CONSUMIDOR
		public String MAKTX;//NOMBRE MATERIAL
		public String KONWA;
		public String MATKL;//GRUPO ARTICULOS
		public String KONDM;//GRUPO MATERIALES
		public String SKU;//SKU
		public String TAXKM;//TIPO IMPUESTO
		public String PLTYP;
		public String MEINS;//UNIDAD MEDIDA
		public String LVORM;//INDICADOR BORRADO
	}
}