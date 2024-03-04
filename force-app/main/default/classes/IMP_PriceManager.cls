/************************************************************************
Name: IMP_PriceManager
Copyright © 2022 Salesforce
========================================================================
Purpose:
Clase que realiza la creacion y actualización de precios.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    01/04/2022     INITIAL        DEV CSR:
************************************************************************/

public without sharing class IMP_PriceManager {
    
    public String I_FECHA;	//20220322
    public String I_VKBUR;	//AC01
    public cls_MATPRECIO[] MATPRECIO;
    public class cls_MATPRECIO {
        public String VKBUR;	//
        public String PLTYP;	//
        public String MATNR;	//
        public Decimal NETWR;	//0
        public String KONWA;	//
    }
    
    @AuraEnabled
    public static void getPrices() {
        List<Pricebook2> listPrecio = [SELECT Id, Name , IMP_update__c , Sucursal__c, Lista_de_precios_SAP__c FROM Pricebook2 WHERE IsStandard=false FOR UPDATE];
        for(Pricebook2 precio : listPrecio){
            precio.IMP_update__c= false;
        }
        update listPrecio;
        Database.executeBatch(new IMP_UpdateParentPrices());

        // Awesome processing logic here
        // Chain this job to next job by submitting the next job
        // UpdateParentPrices qb = new UpdateParentPrices(precio);
        //  ID jobID = System.enqueueJob(qb);
        // System.debug(jobID);
        
    }

    
    /*******************************************************************
    Purpose: Actualiza los materiales al dia de hoy.
    Parameters:
    Returns:
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
    @AuraEnabled
    public static void getMateriales(Date fechaInicio,Date fechaFin){
        String fechaInicial=Datetime.newInstance(fechaInicio, Time.newInstance(12, 0, 0, 0)).format('YYYY/MM/dd');
        String fechaFinal=Datetime.newInstance(fechaFin, Time.newInstance(12, 0, 0, 0)).format('YYYY/MM/dd');
        IMP_IntegracionMateriales.getMateriales(fechaFinal.replace('/',''),fechaFinal.replace('/',''));
    }
    
   /*******************************************************************
    Purpose: Actualiza los precios de los productos de determinada Lista de Precios.
    Parameters:String pricebook2Id
    Returns:
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
    public static void getPrice(String pricebook2Id){
        System.debug('Antrando a getPrice');
        String log='';
        String fechaFinal=System.Now().format('YYYY/MM/dd');
        Pricebook2 listaPrecios =[SELECT Id,Name,Sucursal__c, Lista_de_precios_SAP__c  FROM Pricebook2 WHERE Id=:pricebook2Id]; 

        try{
            
        IMP_PriceManager price = new IMP_PriceManager();
        List<cls_MATPRECIO> listPrice= new List<cls_MATPRECIO>();
        price.I_FECHA=fechaFinal.replace('/','');
        price.I_VKBUR=listaPrecios.Sucursal__c;
        price.MATPRECIO=listPrice;
        String body = JSON.serialize(price); 
        System.debug('Request body : '+body);       
        HttpResponse response = getResponse(body);
        Map<String,Decimal> mapPrices = new Map<String,Decimal>();
        Map<String,String > mapListas = new Map<String,String>();
        List<String> listCodigo = new List<String> ();
        IMP_PriceManager priceResponse = (IMP_PriceManager)JSON.deserialize(response.getBody(), IMP_PriceManager.class);
    
        for(IMP_PriceManager.cls_MATPRECIO newPrice: priceResponse.MATPRECIO){
          //  System.debug(newPrice.MATNR.replaceFirst('^0+', '')+ ' - '+newPrice.NETWR+' - '+newPrice.PLTYP);
            if(newPrice.PLTYP ==listaPrecios.Lista_de_precios_SAP__c){
                listCodigo.add(newPrice.MATNR.replaceFirst('^0+', ''));
                mapPrices.put(newPrice.MATNR.replaceFirst('^0+', ''),newPrice.NETWR);
                mapListas.put(newPrice.MATNR.replaceFirst('^0+', ''),newPrice.PLTYP);
            }
            
        } 
        log+='Cantidad de precios devueltos : '+priceResponse.MATPRECIO.size()+'\n';
       // log+='Ultima modificacion : '+Date.today()+'\n';      
        List<Product2> newProducts = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode IN : listCodigo]; 
        Pricebook2 pricebook=[SELECT  Id,IsActive,IsStandard, Name
                              FROM Pricebook2 WHERE IsStandard= true AND IsActive = true];
        List<PricebookEntry> newPrices = new List<PricebookEntry>();
        List<PricebookEntry> newPricesAux = new List<PricebookEntry>();
        List<PricebookEntry> standardPrices = new List<PricebookEntry>();
        List<PricebookEntry> newlistsPricesErrors = new List<PricebookEntry>();
        
        for(Product2 prod : newProducts){
                newPrices.add(new PricebookEntry (
                    Product2Id = prod.Id,
                    Pricebook2Id = listaPrecios.Id,
                    UnitPrice = mapPrices.get(prod.ProductCode),
                    CurrencyIsoCode = 'MXN',
                    UseStandardPrice = false,
                    IsActive=True,
                    IdExterno__c = prod.Id+'/'+listaPrecios.Name
                ));  
        }
        //log+='Cantidad de productos encontrados : '+newPrices.size()+'\n';
        Database.UpsertResult[] results =  Database.upsert(newPrices, PricebookEntry.IdExterno__c , false);
        Map<String,String> mapResponse = new Map<String,String> ();
        Integer size = results.size();
        for(Integer index = 0; index < size; index++) {
            if(results[index].isSuccess()) {
                if(results[index].isCreated()) {
                    mapResponse.put('Precio Creado: '+newProducts[index].ProductCode , results[index].getId()); 
                }
            }else if(String.valueOf(results[index].getErrors()).contains('Antes de crear un precio personalizado, cree un precio estándar.')){
                standardPrices.add(new PricebookEntry(Product2Id=newPrices[index].Product2Id,Pricebook2Id=pricebook.Id,UnitPrice=0,IsActive=true,CurrencyIsoCode='MXN'));
                newPricesAux.add(newPrices[index]);
 
            }else if(String.valueOf(results[index].getErrors()).contains('INVALID_FIELD_FOR_INSERT_UPDATE')){     
                newlistsPricesErrors.add(newPrices[index]); 
                
            }else{
                mapResponse.put('Error 1 - '+newProducts[index].ProductCode, String.valueOf(results[index].getErrors()));
            }
        }
        if(standardPrices.size()>0){
            insert standardPrices;
            mapResponse.putAll(upsertList(newPricesAux));
            
        }
        
        if(newlistsPricesErrors.size()>0){
            mapResponse.putAll(upsertList(getEntradasSinDivisa(newlistsPricesErrors)));
        }
        Integer counterRight=0;
        Integer counterError=0;
        for(String key: mapResponse.keySet()){
            if(key.contains('Precio Creado: ') || key.contains('Precio Modificado: ') ){
              counterRight++;  
            }
              if(key.contains('Error')){
              counterError++;  
            }
        }
        log+='Modificados/Creados correctamente '+ counterRight+'\n';
        log+='Modificados/Creados con error '+ counterError+'\n';
        }catch(Exception ex){
            System.debug(ex.getMessage());
        }
       
        listaPrecios.Log__c=log;
        listaPrecios.IMP_update__c=true;
        update listaPrecios;
    }
    
    /*******************************************************************
    Purpose: Obtiene una Lista de Entradas de precio y les elimina la divisa
    Parameters: List<PricebookEntry> listasPrecios
    Returns:List<PricebookEntry>
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
    public static  List<PricebookEntry> getEntradasSinDivisa(List<PricebookEntry> listasPrecios){
        List<PricebookEntry> newListPrices= new  List<PricebookEntry>();
        for(PricebookEntry price : listasPrecios){
            PricebookEntry newPricebookEntry = new PricebookEntry (
                Product2Id = price.Product2Id,
                Pricebook2Id = price.Pricebook2Id,
                UnitPrice=price.UnitPrice,
                IsActive=price.IsActive,
                UseStandardPrice=false,
                IdExterno__c=price.IdExterno__c
            );
            newListPrices.add(newPricebookEntry);  
        }
        return newListPrices;
    }
    
    /*******************************************************************
    Purpose: Inserta o modifica registros de entradas de listas de precios.
    Parameters: List<PricebookEntry> listasPrecios
    Returns: Map<String,String>
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
    public static Map<String,String> upsertList(List<PricebookEntry> newlistsPrices){
        Map<String,String> mapResponsePrice= new Map<String,String>();
        Database.UpsertResult[] results =  Database.upsert(newlistsPrices,PricebookEntry.IdExterno__c , false);
        Integer size = results.size();
        for(Integer index = 0; index < size; index++) {
            if(results[index].isSuccess()) {
                if(results[index].isCreated()) {
                    
                    mapResponsePrice.put('Precio Creado: '+newlistsPrices[index].Product2Id, results[index].getId()); 
                    
                } else {
                    mapResponsePrice.put('Precio Modificado: '+newlistsPrices[index].Product2Id, results[index].getId());
                }
            }else{
                mapResponsePrice.put('Error 2: '+newlistsPrices[index].Product2Id, String.valueOf(results[index].getErrors()));
            }
        }
        return mapResponsePrice;
    }
    
    /*******************************************************************
    Purpose: Obtiene respuesta del servicio de precios.
    Parameters: String body
    Returns:HttpResponse
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
    public static HttpResponse getResponse(String body){
        HttpResponse response;
        //String token = IMP_CrearClienteSap_CC.retriveToken().token;
        Final Integer TIMEOUT_SERV = 120000;
        String API_URL = IMP_ServiceConstants.PRECIO_API_URL;
        String URL_FINAL = 'imperquiaSAP'+API_URL;
        String authHeader = 'BASIC ' + EncodingUtil.base64Encode(Blob.valueOf(System.Label.User_Integration + ':' + System.Label.Password_Integration));
        Map<String, String> params = new Map<String, String>();
        Map<String,String> headers = new Map<String,String>{'Content-Type' => 'application/json', 'Authorization' => authHeader};
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
                System.debug('Response body : '+response.getBody());
            }
        catch(Exception exc){ 
            System.debug(exc.getMessage());
        }
        return response;
    } 
}