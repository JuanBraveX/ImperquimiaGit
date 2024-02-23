/******************************************************************* 
Name: SAP_OrderMock_tst
Copyright © 2021 Salesforce
======================================================
Purpose:
Class test to SAP_Order.
======================================================
History:
Creation
VERSION  AUTHOR           DATE          DETAIL     Description
1.0      rotrejo@ts4.mx   28/10/2021    INITIAL     DEV CSR: 
******************************************************************/

@isTest
global class IMP_Mock implements HttpCalloutMock{
    
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;
    
    /******************************************************************* 
Purpose:Create a object to type SAP_OrderMock_tst
Parameters: Integer code, String status, String body, Map<String, String> responseHeaders
Returns: 
Throws :
Information about changes (versions)
********************************************************************/
    public IMP_Mock(Integer code, String status, String body, Map<String, String> responseHeaders){
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.responseHeaders = responseHeaders;
    }
    
    /******************************************************************* 
Purpose:Mock to simulate the response of the service
Parameters: Integer code, String status, String body, Map<String, String> responseHeaders
Returns: 
Throws :
Information about changes (versions)
********************************************************************/
    public IMP_Mock(Integer code, String status, Blob body, Map<String, String> responseHeaders){
        this.code = code;
        this.status = status;
        this.bodyAsBlob = body;
        this.bodyAsString = null;
        this.responseHeaders = responseHeaders;
    }
    public HTTPResponse respond(HTTPRequest req){
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);
        resp.setHeader('Content-Type', 'application/xml');
        if (bodyAsBlob != null){
            resp.setBodyAsBlob(bodyAsBlob);
        } 
        else{
            resp.setBody(bodyAsString);
        }
        
        if (responseHeaders != null){
            for (String key : responseHeaders.keySet()){
                resp.setHeader(key, responseHeaders.get(key));
            }
        }
        if (req.getEndpoint().endsWith('CLtoXML2')) {
            String xmlProductos='';
            if(bodyAsString=='')
            {
                xmlProductos='<?xml version="1.0" encoding="utf-8"?><WS_CL_PRODUCTOS><datos><Clave_proyecto>OC294254</Clave_proyecto><Producto_Clave>T20-ACABADOS2_ESPACIO PRIMARIO ANTISALITRE</Producto_Clave><Categoria_de_producto>Top 20</Categoria_de_producto><Etapa>Acabados</Etapa><Valor_potencial>3.15427791751800</Valor_potencial></datos><datos><Clave_proyecto>OC294254</Clave_proyecto><Producto_Clave>T5-ACABADOS4_UNIPLAS AERO PLUS APP 4.5 PG</Producto_Clave><Categoria_de_producto>Productos estrella</Categoria_de_producto><Etapa>Acabados</Etapa><Valor_potencial>2.70245254380341</Valor_potencial></datos><datos><Clave_proyecto>OC294254</Clave_proyecto><Producto_Clave>T5-ACABADOS3_UNIPLAS AERO PLUS AUTOADHERIBLE SBS 4.5 PG</Producto_Clave><Categoria_de_producto>Productos estrella</Categoria_de_producto><Etapa>Acabados</Etapa><Valor_potencial>2.64946327823864</Valor_potencial></datos></WS_CL_PRODUCTOS>';
            }else{
                xmlProductos='<?xml version="1.0" encoding="utf-8"?><row datos="No se encontraron datos." />';
            }
            resp.setBody(xmlProductos);
        }
        if (req.getEndpoint().endsWith('CLtoXML')) {
            String xml='<?xml version="1.0" encoding="utf-8"?><WS_CL_OBRAS><datos><Clave_Proyecto>OC294254</Clave_Proyecto><Fecha_Publicacion>2022-04-26T00:00:00</Fecha_Publicacion><Proyecto>TORRE EN 52 NIVELES</Proyecto><Localizacion1>HIDALGO # 450, MONTERREY, NUEVO LEÓN</Localizacion1><Etapa>INICIO</Etapa><Tipo_Desarrollo>OBRA NUEVA</Tipo_Desarrollo><Clave_Estado_Proyecto>19</Clave_Estado_Proyecto><Estado_Proyecto>NUEVO LEON</Estado_Proyecto><Clave_Del_Cd_Mun_Proyecto>039</Clave_Del_Cd_Mun_Proyecto><Del_Cd_Mun_Proyecto>MONTERREY</Del_Cd_Mun_Proyecto><C.P.>64000</C.P.><Moneda>$</Moneda><Inversion>1141186030.0000</Inversion><Fecha_Inicio>2022-04-15T00:00:00</Fecha_Inicio><Fecha_Terminacion>2024-10-31T00:00:00</Fecha_Terminacion><Clave_Tipo_Obra>EHA</Clave_Tipo_Obra><Clase>VIVIENDA</Clase><SubClase>VIVIENDA</SubClase><Genero>VIVIENDA</Genero><Subgenero>LUJO</Subgenero><Tipo_Obra>CONDOMINIOS DE LUJO</Tipo_Obra><Sector>PRIVADO</Sector><Numero_Unidades>471</Numero_Unidades><Num_Niveles>52</Num_Niveles><Sup_Construida>62737.0000</Sup_Construida><Unidad>M²</Unidad><Sup_Urbanizada>0.0000</Sup_Urbanizada><Unidad_>M²</Unidad_><Descripcion>ETAPA: INICIO</Descripcion><Descripcion_Extra>CONTARA</Descripcion_Extra><Acabados>CIMENTACION: </Acabados><Observaciones>LA INVERSIÓN PUBLICADA REPRESENTA.</Observaciones><Rol_Compania>SUBCONTRATISTA DE OBRA CIVIL'+ 
            '</Rol_Compania><Clave_Compania>0000007053</Clave_Compania><Compania>GRUPO DAGS SA DE CV</Compania><Direccion_Compania>LAZARO GARZA AYALA # 110</Direccion_Compania><Colonia>TAMPIQUITO</Colonia><C.P.Compania>66240</C.P.Compania><Del_Cd_Mun_Compania>SAN PEDRO GARZA GARCIA</Del_Cd_Mun_Compania><Estado_Compania>NUEVO LEON</Estado_Compania><Telefono1>8336 5995 </Telefono1><Telefono2>8336 6002 </Telefono2><Lada>81</Lada><Internet>grupodags.com</Internet><Titulo_1>LIC.</Titulo_1><Nombre_1>MAYRA</Nombre_1><Paterno_1>CORONADO</Paterno_1><Puesto_1>ENCARGADO DE COMPRAS</Puesto_1><Email_1>mcoronado@grupodags.com</Email_1><Materno_1>SAENZ</Materno_1><Titulo_2>ING.</Titulo_2><Nombre_2>JOSE</Nombre_2><Paterno_2>CADENGO</Paterno_2><Materno_2>COLLADO</Materno_2><Puesto_2>ENCARGADO DE COSTOS</Puesto_2><Email_2>jcadengo@grupodags.com</Email_2><Titulo_3>ING.</Titulo_3><Nombre_3>GERARDO</Nombre_3><Paterno_3>SOLIS</Paterno_3><Puesto_3>ENCARGADO DE COSTOS</Puesto_3><Email_3>gsolis@grupodags.com</Email_3></datos></WS_CL_OBRAS>';
            resp.setBody(xml);
        }
        if (req.getEndpoint().endsWith('CLTKN')) {
            String xml='<?xml version="1.0" encoding="utf-8"?><string xmlns="http://www.construleads.com/cltoxml">TokenTest</string>';
            resp.setBody(xml);
        }

        return resp;
    }
    
    
}