/************************************************************************
Name: IMP_CotizadorProductosController
Copyright © 2022 Salesforce
========================================================================
Purpose:
Class to get information related to the Quote, QuoteLineItems,Products,PricebookEntry,Pricebook2 and show it in the quoter.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      dmarcos@ts4.mx    12/01/2021     INITIAL        DEV CSR:
************************************************************************/
public without sharing class IMP_CotizadorProductosController {
    /******************************************************************* 
    Purpose: Obtains the information of items of the quote.
    Parameters: Quote cotizacionId.
    Returns: DataQuoteWrapper.
    Throws :
    Information about changes (versions)
    ********************************************************************/
    @auraEnabled
    public static DataQuoteWrapper getInitialData(String cotizacionId){
        DataQuoteWrapper returnData = new dataQuoteWrapper();
        returnData=getAllData(cotizacionId,true);
        return returnData;
    }
    
    /******************************************************************* 
    Purpose: The products that match the search code or description are obtained.
    Parameters: String nombre,Id listaPrecios, Integer pageSize, Integer pageNumber, String  recordId.
    Returns: DataReturnProducts.
    Throws :
    Information about changes (versions)
    ********************************************************************/
    @auraEnabled
    public static DataReturnProducts getProductos(String nombre,Id listaPrecios, Integer pageSize, Integer pageNumber, String  recordId){
        
        String whereArgs;      
        String searchProductBy;
        String searchProductByCode;
        String nombreProducto;
        nombreProducto = nombre;
        
        Quote cot = [SELECT id,Pricebook2Id from Quote WHERE id=:recordId];
        if(cot.Pricebook2Id != listaPrecios){
            cot.Pricebook2Id = listaPrecios;
            update cot; 
        }
               
        if(nombreProducto != null){
            if(nombreProducto.contains(' ')){
                nombreProducto = nombre.replace(' ', '');
            } else{
                nombreProducto = nombre;
            }
            if(nombreProducto.contains(',')){
                searchProductBy='(Product2.ProductCode IN '+ nombreProducto + ' OR Product2.Name IN '+ nombreProducto +')';
            }else{
                searchProductBy='(Product2.Name LIKE \'%' + nombreProducto + '%\' OR Product2.ProductCode LIKE \'%' + nombreProducto + '%\')';
            }
            
            whereArgs = ' IsActive = true AND Product2.IsActive = true AND Pricebook2Id = \'' + cot.Pricebook2Id + '\' AND ' + searchProductBy;
            
        }
        
        Integer resultSize= Database.countQuery('SELECT count() FROM PricebookEntry WHERE ' + whereArgs + ' Limit 2000');
        Integer totalPages = Math.mod(resultSize, pageSize) > 0 ? resultSize / pageSize + 1 : resultSize / pageSize;
        pageNumber = pageNumber > totalPages ? (totalPages == 0 ? 1 : totalPages) : pageNumber;
        Integer pageEnd = pageSize * pageNumber > resultSize ? resultSize : pageSize * pageNumber;
        Integer offset = Math.abs(pageSize * (pageNumber - 1));
        
        list<PricebookEntry> pricebookEntries = Database.query('SELECT Id, Name, UnitPrice,Product2.Grupo_de_art_culos__c, Product2.IsActive, Product2.Name, Product2.Description,Product2.Family, Product2.ProductCode,Product2.Grupo_de_Materiales__c FROM PricebookEntry WHERE ' + whereArgs + 'ORDER BY Product2.Name LIMIT ' + pageSize + ' OFFSET ' + offset);
        DataReturnProducts retornoDatos= new DataReturnProducts();
        
        retornoDatos.listProducts=pricebookEntries;
        retornoDatos.totalProducts=resultSize;
        retornoDatos.totalPages=totalPages;
        retornoDatos.pageEnd=pageEnd;
        retornoDatos.pageNumber=pageNumber;     
        return retornoDatos;
        
    }
    
    public static Map<String,Decimal> updateDisponibilidad(List<String> listaCodigos, String almacen){
        Map<String,Decimal> mapResponse = new Map<String,Decimal>();
        try{
        List<IMP_InventarioManager.cls_ZINVENTARIOS> listProdsResponse =  IMP_InventarioManager.getInventario(listaCodigos,almacen);
        if(listProdsResponse != null){
            for(IMP_InventarioManager.cls_ZINVENTARIOS product:listProdsResponse){
                if(mapResponse.containsKey(product.MATNR.replaceFirst('^0+', ''))){
                    mapResponse.put(product.MATNR.replaceFirst('^0+', ''),mapResponse.get(product.MATNR.replaceFirst('^0+', ''))+product.CLABS); 
                }else{
                    mapResponse.put(product.MATNR.replaceFirst('^0+', ''),product.CLABS);
                }
            }
        }
        }catch(Exception ex){
        }
        return mapResponse;
    }
    
    /******************************************************************* 
    Purpose: Obtains all the information of the quotation , quotation items
    and validates that no inactive products are found in the quote.
    Parameters: Id cotizacionId.
    Returns: DataQuoteWrapper.
    Throws :
    Information about changes (versions)
    ********************************************************************/
    private static DataQuoteWrapper getAllData(Id cotizacionId,boolean flag){
        
        DataQuoteWrapper returnData = new DataQuoteWrapper();
        
        list<Pricebook2> listaPrecios = [SELECT Id, Name, Description FROM Pricebook2 ORDER BY Name ASC]; 
        Double impuestoCotizacion = 0;
        
        Quote cotizacion=[SELECT Id ,Name, Pricebook2Id,Pricebook2.Sucursal__c, CurrencyIsoCode, Opportunity.Id, Opportunity.Name,
                          Status, IsSyncing,TotalPrice,Tax,GrandTotal,Requiereaprobacion__c,Account.Name, Account.ListaPrecios__c,
                          TotalPartidas__c,PrecioTotal__c
                          FROM Quote WHERE Id =: cotizacionId];
        
        if(cotizacion.Pricebook2.Sucursal__c == 'TJ01'){
            impuestoCotizacion = cotizacion.TotalPartidas__c * 0.08;
        }else{
            impuestoCotizacion = cotizacion.TotalPartidas__c * 0.16;
            
        }
        cotizacion.Tax = impuestoCotizacion;
        cotizacion.PrecioTotal__c  = cotizacion.Tax + cotizacion.TotalPartidas__c;
        update cotizacion;
        
        Quote cotizacionUpdate=[SELECT Id ,Name, Pricebook2Id,Pricebook2.Sucursal__c, CurrencyIsoCode, Opportunity.Id, Opportunity.Name,
                                Status, IsSyncing,TotalPrice,Tax,GrandTotal,Requiereaprobacion__c,Account.Name, Account.ListaPrecios__c, 
                                TotalPartidas__c,PrecioTotal__c
                                FROM Quote WHERE Id =: cotizacionId];
        
        list<QuoteLineItem> listQuoteslines=[SELECT Id,Discount, Quantity, TotalPrice,PoliticaDescuento__c,DescuentoSAP__c,IMP_OmitirDescuentoSAP__c,
                                             UnitPrice,PricebookEntryId, PricebookEntry.Id, PricebookEntry.Name, PricebookEntry.UnitPrice,
                                             PricebookEntry.Product2.Id,PricebookEntry.Product2.IsActive,Product2.Name, PricebookEntry.Product2.Description, Product2.Family,
                                             Product2.ProductCode,Product2.Grupo_de_Materiales__c,IMP_Disponibilidad__c,
                                             Product2.IsActive,QuoteId,Descuento_adicional__c,IMP_DescuentoPromo__c, PrecioTotalConDescuentos__c
                                             FROM QuoteLineItem WHERE QuoteId = :cotizacionUpdate.Id ORDER BY CreatedDate];
        
        
        String inactiveProducts=''; 
        List<String> listCodigos = new List<String>();
        for (QuoteLineItem quotedProduct : listQuoteslines) {
            listCodigos.add(quotedProduct.Product2.ProductCode);
            if(quotedProduct.product2.IsActive==false){
                
                inactiveProducts+=quotedProduct.product2.ProductCode+',\n';
                returnData.status='WARNING';
                returnData.mensaje = 'Se encontraron productos inactivos en la cotización : '+inactiveProducts+' .'; 
                
            }
        }
        if(listCodigos.size()>0 && flag){
            Map<String,Decimal> mapResponse = updateDisponibilidad(listCodigos,cotizacion.Pricebook2.Sucursal__c);
            for(QuoteLineItem item:listQuoteslines){
                item.IMP_Disponibilidad__c  = mapResponse.containsKey(item.Product2.ProductCode) ? mapResponse.get(item.Product2.ProductCode):  item.IMP_Disponibilidad__c  != null ? item.IMP_Disponibilidad__c  : 0 ;
            }
            update listQuoteslines;
        }

        returnData.status='SUCCESS';
        returnData.cotizacion=cotizacionUpdate;
        returnData.listQuoteLineItems=listQuoteslines;      
        returnData.listPrecios=listaPrecios;
        
        return returnData;
        
    }
    /******************************************************************* 
    Purpose: When a new product is added to the quote, a quote item is created.
    Parameters: PricebookEntry pbe, Quote cotizacion.
    Returns: DataQuoteWrapper.
    Throws :
    Information about changes (versions)
    ********************************************************************/    
    @auraEnabled
    public static DataQuoteWrapper crearQuoteLineItem(PricebookEntry pbe, String cotizacion){ 
        Integer orden = 0;
        Decimal PrecioTotalDescuentos = 0;
        String grupoClientePromo = '';
        DataQuoteWrapper returnData = new DataQuoteWrapper(); 
        
        list<QuoteLineItem> listQuoteslines=[SELECT Id,Product2.ProductCode,Descuento_adicional__c, DescuentoSAP__c,IMP_OmitirDescuentoSAP__c, PrecioTotalConDescuentos__c 
                                             FROM QuoteLineItem WHERE QuoteId = :cotizacion ORDER BY CreatedDate];
        orden = listQuoteslines.size() + 1;
        Quote cot = [SELECT Id,Account.grupo__c, Account.clave_delcanal__c
                    , Account.OrganizacionVentas__c
                    , Account.id_de_sap__c
                    , Account.centro_suministrador__c
                    , Pricebook2.Lista_de_precios_SAP__c
                    ,Requiereaprobacion__c,Pricebook2.Sucursal__c 
                    FROM Quote WHERE Id =:cotizacion];
        Map<String,Decimal> mapResponse = updateDisponibilidad(new List<String>{pbe.Product2.ProductCode},cot.Pricebook2.Sucursal__c);
        
        try{
            QuoteLineItem quoteLineItem = new QuoteLineItem(
                QuoteId=cotizacion,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                Discount = 0,
                IMP_OmitirDescuentoSAP__c = false,
                UnitPrice = pbe.UnitPrice);

            quoteLineItem.IMP_Disponibilidad__c = mapResponse.containsKey(pbe.Product2.ProductCode)? mapResponse.get(pbe.Product2.ProductCode):0;


            insert quoteLineItem;
            returnData=getAllData(cotizacion,false);
            returnData.status='SUCCESS';
            returnData.mensaje= 'Guardado Exitoso.';  


        }
        catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            returnData.status='ERROR';
            returnData.mensaje = 'ERROR--'+e.getMessage()+e.getLineNumber();
        }
        
        return returnData;
    }
    @auraEnabled  
    public static DataQuoteWrapper deleteQuoteLineItem(QuoteLineItem qli){
        DataQuoteWrapper returnData = new DataQuoteWrapper();
        delete qli;
        returnData=getAllData(qli.QuoteId, false);
        returnData.status='SUCCESS';
        return returnData;
    }

    /******************************************************************* 
    Purpose: Quote items are updated.
    Parameters: QuoteLineItem productEdit, String tipoACampo.
    Returns: DataQuoteWrapper.
    Throws :
    Information about changes (versions)
    ********************************************************************/    
    @auraEnabled
    public static DataQuoteWrapper updateQuoteLineItem(QuoteLineItem productEdit, String tipoACampo){
        DataQuoteWrapper returnData = new DataQuoteWrapper();
        update productEdit;
        System.debug('Id: '+productEdit.Id);
        try{
             
            QuoteLineItem quoteLine=[SELECT Id,Discount,IMP_Disponibilidad__c ,Quantity, TotalPrice,Descuento_adicional__c,
                                         UnitPrice, PricebookEntry.Id, PricebookEntry.Name, PricebookEntry.UnitPrice,
                                         PricebookEntry.Product2.Id,PricebookEntry.Product2.IsActive,Product2.Name, PricebookEntry.Product2.Description, Product2.Family,
                                         Product2.ProductCode,QuoteId,DescuentoSAP__c,IMP_DescuentoPromo__c, IMP_OmitirDescuentoSAP__c, PrecioTotalConDescuentos__c
                                         FROM QuoteLineItem WHERE Id = :productEdit.Id];
            quoteLine.Quantity = productEdit.Quantity;  
            quoteLine.PrecioTotalConDescuentos__c = quoteLine.TotalPrice;
            if(quoteLine.Descuento_adicional__c !=null){
                   quoteLine.PrecioTotalConDescuentos__c = quoteLine.TotalPrice - (quoteLine.TotalPrice * (quoteLine.Descuento_adicional__c / 100));
            }

            if(quoteLine.IMP_DescuentoPromo__c !=null){
                
                quoteLine.PrecioTotalConDescuentos__c = quoteLine.PrecioTotalConDescuentos__c - (quoteLine.PrecioTotalConDescuentos__c * (quoteLine.IMP_DescuentoPromo__c / 100));
            }
            
            update quoteLine;
            Quote cotizacionUpdate=[SELECT Id ,Name, Pricebook2Id,Pricebook2.Sucursal__c, CurrencyIsoCode, Opportunity.Id, Opportunity.Name,PrecioTotal__c, 
                                Status, IsSyncing,TotalPrice,Tax,GrandTotal,Requiereaprobacion__c,Account.Name, Account.ListaPrecios__c, TotalPartidas__c
                                FROM Quote WHERE Id =: productEdit.QuoteId LIMIT 1];
            Double impuestoCotizacion = 0;
            if(cotizacionUpdate.Pricebook2.Sucursal__c == 'TJ01'){
                impuestoCotizacion = cotizacionUpdate.TotalPartidas__c * 0.08;
            }else{
                impuestoCotizacion = cotizacionUpdate.TotalPartidas__c * 0.16;
                
            }
            cotizacionUpdate.Tax = impuestoCotizacion;
            cotizacionUpdate.PrecioTotal__c  = cotizacionUpdate.Tax + cotizacionUpdate.TotalPartidas__c;
            update cotizacionUpdate;
            returnData.cotizacion = cotizacionUpdate;
            returnData.quoteLineProduct = quoteLine;
            returnData.status='SUCCESS';
            returnData.mensaje= 'Se ha actualizado correctamente.';

        }
        catch(Exception e){
            returnData.status='ERROR';
            returnData.mensaje=e.getMessage();
            System.debug(e.getLineNumber()+' - '+ e.getMessage());
            
        }
        
        return returnData;
    }
/******************************************************************* 
Purpose: Update the QuoteLineItem with the added discount
Parameters: QuoteLineItem productEdit, Double valueDesc.
Returns: DataQuoteWrapper.
Throws :
Information about changes (versions)
********************************************************************/     
    @auraEnabled
    public static DataQuoteWrapper procesoDescuento(QuoteLineItem productEdit, Double valueDesc){
        DataQuoteWrapper returnData = new DataQuoteWrapper();
        update productEdit;
        
        Double descuentoAdicional  = 0;
        Double descuentoPromo = 0;
        
        try{            
            
            QuoteLineItem quotesLines=[SELECT Id,Discount,Quantity, TotalPrice,Descuento_adicional__c,
                                       UnitPrice, PricebookEntry.Id, PricebookEntry.Name, PricebookEntry.UnitPrice,
                                       PricebookEntry.Product2.Id,PricebookEntry.Product2.IsActive,Product2.Name, PricebookEntry.Product2.Description, Product2.Family,
                                       Product2.ProductCode,QuoteId,DescuentoSAP__c, IMP_OmitirDescuentoSAP__c, IMP_DescuentoPromo__c, PrecioTotalConDescuentos__c 
                                       FROM QuoteLineItem WHERE Id = :productEdit.Id];
            quotesLines.Descuento_adicional__c = valueDesc;
            descuentoAdicional = valueDesc / 100;
            
            quotesLines.PrecioTotalConDescuentos__c = quotesLines.TotalPrice - (quotesLines.TotalPrice * descuentoAdicional);
            if(quotesLines.IMP_DescuentoPromo__c != null){
                descuentoPromo = quotesLines.IMP_DescuentoPromo__c / 100;
                quotesLines.PrecioTotalConDescuentos__c = quotesLines.PrecioTotalConDescuentos__c  - (quotesLines.PrecioTotalConDescuentos__c * descuentoPromo);
            }
            update quotesLines;

            Quote cotizacion=[SELECT Id ,Name, Pricebook2Id,Pricebook2.Sucursal__c, CurrencyIsoCode, Opportunity.Id, Opportunity.Name,PrecioTotal__c, 
                                Status, IsSyncing,TotalPrice,Tax,GrandTotal,Requiereaprobacion__c,Account.Name, Account.ListaPrecios__c, TotalPartidas__c 
                                FROM Quote WHERE Id =: productEdit.QuoteId LIMIT 1];
            Double impuestoCotizacion = 0;
            if(cotizacion.Pricebook2.Sucursal__c == 'TJ01'){
                impuestoCotizacion = cotizacion.TotalPartidas__c * 0.08;
            }else{
                impuestoCotizacion = cotizacion.TotalPartidas__c * 0.16;
                
            }
            cotizacion.Tax = impuestoCotizacion;
            cotizacion.PrecioTotal__c  = cotizacion.Tax + cotizacion.TotalPartidas__c;
            update cotizacion;
            list<QuoteLineItem> listAllQuoteslines=[SELECT Id,IMP_Disponibilidad__c,Product2.ProductCode,Descuento_adicional__c, DescuentoSAP__c,IMP_DescuentoPromo__c, IMP_OmitirDescuentoSAP__c, QuoteId,PrecioTotalConDescuentos__c
                                                    FROM QuoteLineItem WHERE QuoteId = :productEdit.QuoteId];
            
            
            returnData.cotizacion=[SELECT Id ,Name, Pricebook2Id, Pricebook2.Sucursal__c,CurrencyIsoCode, Opportunity.Id, Opportunity.Name,TotalPrice,Tax,
                                   GrandTotal, Requiereaprobacion__c, TotalPartidas__c,PrecioTotal__c
                                   FROM Quote WHERE Id =: productEdit.QuoteId];
            returnData.quoteLineProduct=[SELECT Id,IMP_Disponibilidad__c,Discount,Quantity, TotalPrice,Descuento_adicional__c,
                                         UnitPrice, PricebookEntry.Id, PricebookEntry.Name, PricebookEntry.UnitPrice,
                                         PricebookEntry.Product2.Id,PricebookEntry.Product2.IsActive,Product2.Name, PricebookEntry.Product2.Description, Product2.Family,
                                         Product2.ProductCode,QuoteId, DescuentoSAP__c,IMP_OmitirDescuentoSAP__c, IMP_DescuentoPromo__c, PrecioTotalConDescuentos__c
                                         FROM QuoteLineItem WHERE Id = :productEdit.Id];

            for(Integer i=0; i<listAllQuoteslines.size();i++){
                if(listAllQuoteslines[i].Descuento_adicional__c !=0){
                    returnData.cotizacion.Requiereaprobacion__c = true;	
                    
                }
            }
            update returnData.cotizacion;
            update returnData.quoteLineProduct;

            returnData.status='SUCCESS';
            returnData.mensaje= 'Se ha actualizado correctamente.';
            
        }catch(DmlException ex){
            System.debug('procesoDescuento');
            System.debug(ex.getMessage() + ', ' + ex.getCause() + ', ' + ex.getLineNumber());
            returnData.mensaje = 'No se pudo actualizar  :' + ex.getMessage();
            returnData.status = 'Error';
        }
        return returnData;
        
    }
   /******************************************************************* 
    Purpose: Inner class for Declaration of variables to get the information.
    ********************************************************************/ 
    public class DataReturnProducts{
        @auraEnabled public list<PricebookEntry> listProducts {get;set;}
        @auraEnabled public Integer totalProducts;
        @auraEnabled public Integer totalPages;
        @auraEnabled public Integer pageEnd;
        @auraEnabled public Integer pageNumber; 
    }
    /******************************************************************* 
    Purpose: Inner class for Declaration of variables to get the information.
    ********************************************************************/    
    public class DataQuoteWrapper{
        @auraEnabled public Quote cotizacion {get; set;}
        @auraEnabled public list<QuoteLineItem> listQuoteLineItems {get; set;}
        @auraEnabled public QuoteLineItem quoteLineProduct {get; set;}
        @AuraEnabled public  string mensaje {get; set;}
        @auraEnabled public String status {get;set;}
        @auraEnabled public list<Pricebook2> listPrecios {get;set;}
    }
    
}