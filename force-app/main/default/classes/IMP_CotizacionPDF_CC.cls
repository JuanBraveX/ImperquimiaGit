/************************************************************************
Name: IMP_CotizacionPDF_CC
Copyright © 2022 Salesforce
========================================================================
Purpose:
Class to get information related to the quote and show it in the PDF.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      mmauro@ts4.mx    17/01/2021     INITIAL        DEV CSR:
************************************************************************/
public with sharing class IMP_CotizacionPDF_CC {

    public String partidadepresupuesto { get; set; }
    /******************************************************************* 
    Purpose: Declaration of variables to get the information.
    ********************************************************************/
    @auraEnabled public String cotizacionId {get;set;}
    @auraEnabled public Quote datosCotizacion {get;set;}
    @auraEnabled public Account cuenta {get; set;}
    @auraEnabled public Date fechaFinValidez {get; set;}
    @auraEnabled public Date fechaEntrega {get; set;}
    @auraEnabled public String direccionCompleta {get; set;}
    @auraEnabled public Decimal resultadoPesos {get; set;}
    @auraEnabled public Decimal IVA {get; set;}
    @auraEnabled public Decimal subtotal {get; set;}
    @auraEnabled public Decimal impuestos {get; set;}
    @auraEnabled public Decimal totalFinal {get; set;}
    @auraEnabled public AggregateResult pesosProductos {get; set;}
    @auraEnabled public List<QuoteLineItem> productsQuote {get; set;}
    /******************************************************************* 
    Purpose: Get the information.
    ********************************************************************/
    public IMP_CotizacionPDF_CC() {   
        cotizacionId= ApexPages.currentPage().getParameters().get('id');
        try{
            datosCotizacion = [SELECT Id, AccountId, QuoteNumber, createdDate, Subtotal,Tax, condiciones_de_pago__c,
                               CurrencyIsoCode,TotalPrice,TotalPartidas__c,PrecioTotal__c,Pricebook2.Sucursal__c, ExpirationDate, Fecha_de_entrega__c
                               FROM Quote 
                               WHERE Id =: cotizacionId];
            subtotal = datosCotizacion.TotalPartidas__c.setScale(2);
            impuestos = datosCotizacion.Tax.setScale(2);
            totalFinal = datosCotizacion.PrecioTotal__c.setScale(2);
            if(datosCotizacion.Pricebook2.Sucursal__c == 'TJ01'){
                IVA = 8.00;
            }else{
                IVA =16.00;
                
            }

            fechaFinValidez = Date.valueOf(datosCotizacion.CreatedDate.addMonths(1));
            fechaEntrega = Date.valueOf(datosCotizacion.CreatedDate.addDays(2));
            cuenta = [SELECT Id, Name, AccountNumber, Phone, Fax, CorreoElectronico__c, SHIPPINGCITY, id_de_sap__c,
                      SHIPPINGCOUNTRY, SHIPPINGPOSTALCODE, billing_address_state__c, SHIPPINGSTREET,Intercoms_1__c, Intercoms_2__c 
                      , IMP_Calle__c, IMP_CodigoPostal__c, Numero_Exterior__c, Numero_Interior__c, COLONIA__C, Delegacion__c, IMP_PaisFacturacion__c
                      FROM Account
                      Where Id =: datosCotizacion.AccountId];
            
            direccionCompleta = '';
            if(String.isNotBlank(cuenta.IMP_Calle__c)){
                direccionCompleta = 'CALLE ' + cuenta.IMP_Calle__c;
            }
            else {
                direccionCompleta = (String.isNotBlank(cuenta.ShippingStreet ) ? (' ' + cuenta.ShippingStreet) : '');
            }
            
            direccionCompleta += (String.isNotBlank(cuenta.Numero_Exterior__c ) ? (' Núm. ext. ' + cuenta.Numero_Exterior__c) : '');
            direccionCompleta += (String.isNotBlank(cuenta.Numero_Interior__c ) ? (' Núm. int. ' + cuenta.Numero_Interior__c) : '');
            direccionCompleta += (String.isNotBlank(cuenta.Colonia__c ) ? (' COL. ' + cuenta.Colonia__c) : '');
            direccionCompleta += (String.isNotBlank(cuenta.Delegacion__c ) ? (' DEL. ' + cuenta.Delegacion__c) : '');

            if(String.isNotBlank(cuenta.IMP_CodigoPostal__c)){
                direccionCompleta += ' CP. ' + cuenta.IMP_CodigoPostal__c;
            }
            else {
                direccionCompleta += (String.isNotBlank(cuenta.ShippingPostalCode ) ? (' CP. ' + cuenta.ShippingPostalCode) : '');
            }

            if(String.isNotBlank(getPLVLabel(Account.billing_address_state__c, cuenta.billing_address_state__c))){
                direccionCompleta += ' ' + getPLVLabel(Account.billing_address_state__c, cuenta.billing_address_state__c); //picklist
            }
            else {
                direccionCompleta += (String.isNotBlank(cuenta.ShippingCity ) ? (' ' + cuenta.ShippingCity) : '');
            }

            if(String.isNotBlank(cuenta.ShippingCountry)){
                direccionCompleta += ' ' + cuenta.ShippingCountry;
            }
            else {
                direccionCompleta += (String.isNotBlank(getPLVLabel(Account.IMP_PaisFacturacion__c, cuenta.IMP_PaisFacturacion__c)) ? (' ' + cuenta.IMP_PaisFacturacion__c) : '' );  //picklist
            }

            direccionCompleta = direccionCompleta.toUpperCase();
            
            
            productsQuote = [SELECT Id, Product2.Name, Product2.ProductCode,  Quantity, Product2.Description, ListPrice, UnitPrice, TotalPrice, Peso_bruto__c,
                             IMP_DescuentoPromo__c, Descuento_adicional__c, DescuentoSAP__c, Product2.Peso__c,PrecioTotalConDescuentos__c
                             FROM QuoteLineItem 
                             WHERE QuoteId =: cotizacionId];


            pesosProductos = [SELECT SUM(Peso_bruto__c)totalPesos FROM QuoteLineItem WHERE QuoteId =: cotizacionId];
            resultadoPesos = (decimal)pesosProductos.get('totalPesos');
            
        }catch(Exception exc){
            system.debug('Exception PDF '+exc.getMessage()+ exc.getCause()+exc.getLineNumber());
        }
    }

    public String getPLVLabel(SObjectField fld, String val) {

        Schema.DescribeFieldResult dfr = fld.getDescribe();
        List<Schema.PicklistEntry> plvs = dfr.getPicklistValues();
        
        for (PicklistEntry ple: plvs) {
            if (ple.getValue() == val) {return ple.getLabel();}
        }
        return null;
    }
}