/************************************************************************
Name: IMP_BRAnalyticsIntegration
Copyright © 2022 Salesforce
========================================================================
Purpose:
Servicio web para la creación de prospectos desde BR Analytics
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
2.0      dmarcos@ts4.mx     06/04/2022     
************************************************************************/
public without sharing class IMP_BRAnalyticsIntegration {
    
    /*******************************************************************
    Purpose: Obtener la respuesta del token.
    Parameters: 
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    @auraEnabled
    public static String retriveToken(){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint(System.label.IMP_LinkToken);
        String user = System.label.IMP_UserBimsa;
        String password = System.label.IMP_PasswordBimsa;
        req.setBody('TUsr='+user + '&TWSPss='+password);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        string[] listToken = String.valueOf(response.getBody()).split('>');
        string[] listTokenFinal = String.valueOf(listToken[2]).split('<');
        String token = listTokenFinal[0];
        return token;
    }
    
    /*******************************************************************
Purpose: Obtener xml de los proyectos publicados e insertar los prospectos.
Parameters: 
Returns: String
Throws [Exceptions]:
Information about changes (versions) []:
********************************************************************/
    @future(callout=true)
    public static void getDataAnalytics(String fechaConsulta){
        Map<String,List<String>> mapProductos = getProducts(fechaConsulta);
        List<Lead> listLeads = new List<Lead>();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint(System.label.IMP_LinkProyectos);
        String user = System.label.IMP_UserBimsa;
        String password = System.label.IMP_PasswordBimsa;
        String fecha = fechaConsulta;
        String token = IMP_BRAnalyticsIntegration.retriveToken();
        req.setBody('Usr='+user + '&WSPss='+password +  '&Fecha='+fecha + '&TKN='+token);
        Http http = new Http();
        HTTPResponse response = http.send(req);
        
        Dom.Document doc = response.getBodyDocument();
        Dom.XMLNode datos = doc.getRootElement();
        List<Lead> listaLeads =[SELECT Id, Clave_Proyecto__c FROM Lead];
        map<String,Id> mappLe = new map<String,Id>();
        for(Lead l : listaLeads){
            mappLe.put(l.Clave_Proyecto__c,l.Id);
        }
        
        for(Dom.XMLNode child2 : datos.getChildElements()) {
            system.debug( child2.getChildElement('Clave_Proyecto',null).getText());   
            String tipoProyecto = child2.getChildElement('Clave_Proyecto',null).getText().substring(0,2);
            String productosDesc ='';
            if(mapProductos.containsKey(child2.getChildElement('Clave_Proyecto',null).getText())){
                for(String producto : mapProductos.get(child2.getChildElement('Clave_Proyecto',null).getText())){
                    productosDesc += producto+ ',';
                }
                
            }
            if(!mappLe.containsKey(child2.getChildElement('Clave_Proyecto',null).getText())){
                Lead lead = new Lead(
                    Description = child2.getChildElement('Proyecto ',null) != null ? child2.getChildElement('Proyecto',null).getText():'',
                    Clave_Proyecto__c = child2.getChildElement('Clave_Proyecto',null) != null ? child2.getChildElement('Clave_Proyecto',null).getText():'',
                    Company = child2.getChildElement('Compania',null) != null ? child2.getChildElement('Compania',null).getText():'',
                    EtapaBIMSA__c = child2.getChildElement('Etapa',null) != null ? child2.getChildElement('Etapa',null).getText():'',
                    Fecha_de_inicio_del_proyecto__c = date.valueOf(child2.getChildElement('Fecha_Inicio',null) != null ? child2.getChildElement('Fecha_Inicio',null).getText():''),
                    fecha_publicacion__c = date.valueOf(child2.getChildElement('Fecha_Publicacion',null) != null ? child2.getChildElement('Fecha_Publicacion',null).getText():''),
                    fecha_de_termino_proyecto__c = date.valueOf(child2.getChildElement('Fecha_Terminacion',null) != null ? child2.getChildElement('Fecha_Terminacion',null).getText():''),
                    InversionBimsa__c = Decimal.valueOf(child2.getChildElement('Inversion',null) != null ? child2.getChildElement('Inversion',null).getText():''),
                    Street = child2.getChildElement('Localizacion1',null) != null ? child2.getChildElement('Localizacion1',null).getText():'',
                    Postalcode = child2.getChildElement('C.P.',null) != null ? child2.getChildElement('C.P.',null).getText():'',
                    City = child2.getChildElement('Del_Cd_Mun_Proyecto',null) != null ? child2.getChildElement('Del_Cd_Mun_Proyecto',null).getText():'',
                    State = child2.getChildElement('Estado_Proyecto',null) != null ? child2.getChildElement('Estado_Proyecto',null).getText():'',
                    CurrencyIsoCode = child2.getChildElement('Moneda',null) != null ? 'MXN':'',
                    Title = child2.getChildElement('Titulo_1',null) != null ? child2.getChildElement('Titulo_1',null).getText():'',
                    FirstName = child2.getChildElement('Nombre_1',null) != null ? child2.getChildElement('Nombre_1',null).getText():'',
                    LastName = child2.getChildElement('Paterno_1',null) != null ? child2.getChildElement('Paterno_1',null).getText() +' '+child2.getChildElement('Materno_1',null).getText():'',
                    Email = child2.getChildElement('Email_1',null) != null ? child2.getChildElement('Email_1',null).getText():'',
                    numero_de_niveles__c = Decimal.valueOf(child2.getChildElement('Num_Niveles',null).getText().trim() != '' ? child2.getChildElement('Num_Niveles',null).getText():'0'),
                    numero_de_unidades__c = Integer.valueOf(child2.getChildElement('Numero_Unidades',null).getText().trim() != '' ? child2.getChildElement('Numero_Unidades',null).getText():'0'),
                    Sector__c = child2.getChildElement('Sector',null) != null ? child2.getChildElement('Sector',null).getText():'',
                    superficieonstruida__c = Decimal.valueOf(child2.getChildElement('Sup_Construida',null) != null ? child2.getChildElement('Sup_Construida',null).getText():''),
                    superficie_urbanizada__c = Decimal.valueOf(child2.getChildElement('Sup_Urbanizada',null) != null ? child2.getChildElement('Sup_Urbanizada',null).getText():''),
                    Phone = child2.getChildElement('Telefono1',null) != null ? child2.getChildElement('Telefono1',null).getText() + child2.getChildElement('Lada',null).getText():'',
                    tipo_de_desarrollo__c = child2.getChildElement('Tipo_Desarrollo',null) != null ? child2.getChildElement('Tipo_Desarrollo',null).getText():'',
                    unidad_superficieonstruida__c = child2.getChildElement('Unidad',null) != null ? child2.getChildElement('Unidad',null).getText():'',
                    unidad_superficie_urbanizada__c = child2.getChildElement('Unidad_',null) != null ? child2.getChildElement('Unidad_',null).getText():'',
                    Productos__c = productosDesc =='' ?  'No se encontraron productos':productosDesc,
                    LeadSource = 'BIMSA',
                    Clase__c = child2.getChildElement('Clase',null) != null ? child2.getChildElement('Clase',null).getText():'',
                    tipo_de_proyecto__c = tipoProyecto =='OC' ? 'Proyectos Contratados' : 'Proyectos de Inversión',
                    RecordTypeId =System.label.RecordTypeIdProspecto,
                    Descripcion_de_Proyecto__c = child2.getChildElement('Descripcion',null).getText()+' '+child2.getChildElement('Descripcion_Extra',null).getText()+' '+
                    child2.getChildElement('Observaciones',null).getText()+' '+child2.getChildElement('Acabados',null).getText(),
                    DireccionCompania__c = child2.getChildElement('Direccion_Compania',null).getText()+' '+child2.getChildElement('Del_Cd_Mun_Compania',null).getText()+' '+
                    child2.getChildElement('Estado_Compania',null).getText()+' '+child2.getChildElement('C.P.Compania',null).getText()+' '+child2.getChildElement('Colonia',null).getText()
                    
                );
                listLeads.add(lead);
            }
            
        }
        Database.SaveResult[] saveResultList = Database.insert(listLeads, false);        
        for (Database.SaveResult sr : saveResultList) {
            if (sr.isSuccess()) { 
                System.debug('Successfully inserted lead. Lead ID: ' + sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred. '+err.getMessage());                    
                    
                }
            }
        }
        
    }
    
    /*******************************************************************
Purpose: Obtener xml de los productos publicados.
Parameters: 
Returns: String
Throws [Exceptions]:
Information about changes (versions) []:
********************************************************************/
    public static Map<String,List<String>> getProducts(String fechaConsulta){
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setMethod('GET');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint(System.label.IMP_LinkProductos);
        String user = System.label.IMP_UserBimsa;
        String password = System.label.IMP_PasswordBimsa;
        String fecha = fechaConsulta;
        String token = IMP_BRAnalyticsIntegration.retriveToken();
        req.setBody('Usr='+user + '&WSPss='+password +  '&Fecha='+fecha + '&TKN='+token );
        Http http = new Http();
        HTTPResponse response = http.send(req);
        Map<String,List<String>> mapProductos = new Map<String,List<String>>();
        
        
        Dom.Document doc = response.getBodyDocument();  
        Dom.XMLNode datos = doc.getRootElement();
        for(Dom.XMLNode child : datos.getChildElements()) {
            if(!mapProductos.containskey(child.getChildElement('Clave_proyecto',null).getText())){
                mapProductos.put(child.getChildElement('Clave_proyecto',null).getText(),new List<String>());
            }
            mapProductos.get(child.getChildElement('Clave_proyecto',null).getText()).add(child.getChildElement('Producto_Clave',null).getText());       
        }        
        
        return mapProductos;     
    }
}