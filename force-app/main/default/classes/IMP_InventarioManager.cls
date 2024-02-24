/************************************************************************
Name: IMP_integrationServiceReg
Copyright © 2022 Salesforce
========================================================================
Purpose:
Obtener el inventario generado por SAP
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    11/04/2022     First Version.
************************************************************************/
public class IMP_InventarioManager {
    
    public String I_LVORM;	//
    public String I_VFDAT;	//20220322
    public String I_WERKS;	//IMPQ
    public cls_ZINVENTARIOS[] ZINVENTARIOS;
    public cls_I_MATNR[] I_MATNR;
    public class cls_ZINVENTARIOS {
        public String CHARG;	//
        public Decimal CLABS;	//0
        public String HSDAT;	//
        public String LGORT;	//
        public String MAKTX;	//
        public String MATNR;	//
        public String MEINS;	//
        public String NAME;	//
        public String VFDAT;	//
        public String WERKS;	//
    }
    public class cls_I_MATNR {
		public String MATNR;	//10000311
	}
    
    /*******************************************************************
    Purpose: Genera el cuerpo de la solicitud a enviar.
    Parameters: List<String> listaCodigos,String almacen
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    
    Public static String generateJSON(List<String> listaCodigos,String almacen){
        List<cls_I_MATNR> listaMateriales = new List<cls_I_MATNR>();
        for(String item : listaCodigos){
            cls_I_MATNR newProd = new cls_I_MATNR();
            newProd.MATNR=item;
            listaMateriales.add(newProd);
        }
        List<cls_ZINVENTARIOS> listInventarios= new List<cls_ZINVENTARIOS>();
        String fechaFinal=System.Now().format('YYYY/MM/dd');

        IMP_InventarioManager nuevaConsulta = new IMP_InventarioManager();
        nuevaConsulta.I_LVORM='';
        nuevaConsulta.I_VFDAT=fechaFinal.replace('/','');
        nuevaConsulta.I_WERKS=almacen;
        nuevaConsulta.I_MATNR=listaMateriales;
        nuevaConsulta.ZINVENTARIOS=listInventarios;
        String body = JSON.serialize(nuevaConsulta);
        return body;
    }
   
    /*******************************************************************
    Purpose: Obtiene el inventario de los productos.
    Parameters: List<String> listaCodigos,String almacen
    Returns: cls_ZINVENTARIOS[]
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static cls_ZINVENTARIOS[] getInventario(List<String> listaCodigos,String almacen){
        IMP_InventarioManager inventario = new IMP_InventarioManager();
        try{
            //inicio mi documentacion 02232024
            String body = generateJSON(listaCodigos,almacen); 
            HttpResponse response = IMP_CalloutUtils.getResponse(body,IMP_ServiceConstants.INVENTARIO_API_URL);
            inventario = new IMP_InventarioManager();
            inventario = (IMP_InventarioManager)JSON.deserialize(response.getBody(), IMP_InventarioManager.class);                    
        }catch(Exception ex) {
        }
        return inventario.ZINVENTARIOS;
    }      
}