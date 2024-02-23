/************************************************************************
Name: IMP_ServiceConstants
Copyright © 2022 Salesforce
========================================================================
Purpose:
Class used to set type of callout, content type and different types of headers
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      lmagana@ts4.mx     20/01/2021     INITIAL        DEV CSR:
************************************************************************/
public without sharing class IMP_ServiceConstants {
	public static final String AUTHORIZE_API_URL  = '/login/Tauthorize';
    public static final String CLIENTES_API_URL  = '/CrearCliente';//'/CrearClientes';1
    public static final String MATERIALES_API_URL  = '/Materiales';//'/Materiales';5
    public static final String INVENTARIO_API_URL  = '/Inventarios';//'/Inventarios';6
    public static final String CREDITO_API_URL  = '/Credito';//'/ConsultaCredito';2
    public static final String SALDOS_API_URL  = '/CreditoAntSaldos';//'/Credito_AntSaldos';3
    public static final String PEDIDO_API_URL  = '/CreaOrdenVenta';//'/CreaOrdenventa';9
    public static final String PRECIO_API_URL  = '/MatPrecio';//'/MatPrecio';
    public static final String ACTUALIZACION_CREDITO_API_URL  = '/ActLimiteCred';//'/ActualizacionCredito';4
    public static final String DOCUMENTOS_API_URL  = '/FlujoDocumento';//'/FlujoDocumento';7
    public static final String CASES_DATE_API_URL  = '?creationDate';
    public static final String FILES_NAME_API_URL  = '&name';
    public static final String FACTURA_API_URL  = '/ConsultaFactPedidos';//'/ConsultaFac_Ped';8
    public static final String DESCUENTOS_API_URL  = '/TablasDescuentos';//'/Descuentos';
    public static final String PEDIDOS_API_URL  = '/ConsultaPedidos';
                
    public static final Map<String,String> AUTHORIZE_HEADERS = new Map<String,String>{
        IMP_CalloutConstants.HEADER_CLIENT_ID => '{!$Credential.Username}',
        IMP_CalloutConstants.HEADER_CLIENT_SECRET => '{!$Credential.Password}'
    };
}