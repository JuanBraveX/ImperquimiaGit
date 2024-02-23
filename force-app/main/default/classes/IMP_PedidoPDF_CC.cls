/************************************************************************
Name: IMP_PedidoPDF_CC
Copyright © 2023 Salesforce
========================================================================
Purpose:
Class to get information related to the order and show it in the PDF.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rortega@ts4.mx    28/03/2023     INITIAL        DEV CSR:
************************************************************************/
public class IMP_PedidoPDF_CC {

    public String getOrder() {
        return null;
    }


    public String pedido { get; set; }
    /******************************************************************* 
    Purpose: Declaration of variables to get the information.
    ********************************************************************/
    @auraEnabled public String orderId {get;set;}
    @auraEnabled public Order datosOrder {get;set;}
    @auraEnabled public Account cuenta {get; set;}
    @auraEnabled public Date fechaDocumento {get; set;}
    @auraEnabled public String direccionCompleta {get; set;}
    @auraEnabled public Decimal resultadoPesos {get; set;}
    @auraEnabled public Decimal IVA {get; set;}
    @auraEnabled public Decimal subtotal {get; set;}
    @auraEnabled public Decimal impuestos {get; set;}
    @auraEnabled public Decimal totalFinal {get; set;}
    @auraEnabled public AggregateResult pesosProductos {get; set;}
    @auraEnabled public List<OrderItemCalc> productsOrder {get; set;}
    /******************************************************************* 
    Purpose: Get the information.
    ********************************************************************/
    public IMP_PedidoPDF_CC() {   
        orderId= ApexPages.currentPage().getParameters().get('id');
        try{
            
            datosOrder = [SELECT Id, AccountId, OrderNumber,pedido__c
                            , createdDate, Precio_Total__c
                            , TotalAmount, TotalPartidas__c
                            , TotalPedido__c, Pricebook2.Sucursal__c
                            , condiciones_de_pago__c, CurrencyIsoCode
                        FROM Order WHERE Id =: orderId];

                        
           subtotal = datosOrder.TotalPedido__c.setScale(2);
           
          

            if(datosOrder.Pricebook2.Sucursal__c == 'TJ01'){
                IVA = 8.00;
            }else{
                IVA =16.00;
                
            }

            impuestos =  (datosOrder.TotalPedido__c * IVA / 100);
            totalFinal = (datosOrder.TotalPedido__c + impuestos).setScale(2);

            fechaDocumento = Date.valueOf(datosOrder.CreatedDate.addDays(2));

            cuenta = [SELECT Id, Name, AccountNumber, Phone, Fax
                      , CorreoElectronico__c , SHIPPINGCITY, id_de_sap__c
                      , Intercoms_1__c, Intercoms_2__c , IMP_Calle__c
                      , Numero_Interior__c, Numero_Exterior__c, Colonia__c
                      , Delegacion__c , IMP_CodigoPostal__c, ShippingStreet, ShippingPostalCode
                      , billing_address_state__c, IMP_PaisFacturacion__c, ShippingCountry
                      FROM Account
                      Where Id =: datosOrder.AccountId];

            direccionCompleta = '';
            if(String.isNotBlank(cuenta.IMP_Calle__c)){
                direccionCompleta += 'CALLE ' + cuenta.IMP_Calle__c;
            }
            else {
                direccionCompleta += (String.isNotBlank(cuenta.ShippingStreet ) ? (' ' + cuenta.ShippingStreet) : '');
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
            
            List<OrderItemCalc> ListProductsOrder = new List<OrderItemCalc>();

            for(OrderItem pOrder : [SELECT Id, IMP_Posicion__c, Product2.Name, Product2.ProductCode
            ,  Quantity, Product2.Description, ListPrice
            , UnitPrice,TotalPrice, DescuentoSAP__c, DescuentoManual__c, IMP_DescuentoPromo__c, QuoteLineItem.Peso_bruto__c
            , Product2.Peso__c
            , PrecioTotal__c
            , ServiceDate, EndDate
           
            FROM OrderItem  WHERE OrderId =: orderId]){
                OrderItemCalc orderItemElement = new OrderItemCalc();

                //orderItemElement.Posicion = pOrder.IMP_Posicion__c;
                orderItemElement.Name = pOrder.Product2.Name;
                orderItemElement.ProductoCode = pOrder.Product2.ProductCode;
                orderItemElement.Quantity = pOrder.Quantity;
                orderItemElement.Description = pOrder.Product2.Description;
                orderItemElement.ListPricee = pOrder.ListPrice;
                orderItemElement.PrecioUnit = pOrder.UnitPrice;

                orderItemElement.TotalPrecio = pOrder.UnitPrice * pOrder.Quantity;
                orderItemElement.DescuentoSAP = pOrder.DescuentoSAP__c != null ? pOrder.DescuentoSAP__c: 0.00; 
                orderItemElement.DescuentoManual = pOrder.DescuentoManual__c != null ? pOrder.DescuentoManual__c: 0.00;
                orderItemElement.DescuentoPromo = pOrder.IMP_DescuentoPromo__c != null ? pOrder.IMP_DescuentoPromo__c: 0.00;
               orderItemElement.Peso = pOrder.Product2.Peso__c ;
               orderItemElement.Peso = pOrder.QuoteLineItem.Peso_bruto__c; 
                orderItemElement.PrecioTotal= pOrder.PrecioTotal__c;
                orderItemElement.ServiceDate = pOrder.ServiceDate;
                orderItemElement.EndDate = pOrder.EndDate;
                
                orderItemElement.promoDescManual = 0;   
                orderItemElement.promoDescAuto = 0;
                orderItemElement.valorNetoItem = 0;
                
                if(pOrder.DescuentoManual__c != NULL && pOrder.DescuentoManual__c != 0){
                    orderItemElement.promoDescManual = ((pOrder.UnitPrice / 100 ) * pOrder.DescuentoManual__c)* pOrder.Quantity;
                }
                else 
                {
                    orderItemElement.promoDescManual = 0.00;
                }
                

                if(pOrder.DescuentoSAP__c != NULL && pOrder.DescuentoSAP__c != 0){
                    orderItemElement.promoDescAuto = ((pOrder.UnitPrice * pOrder.DescuentoSAP__c) / 100)* pOrder.Quantity;    
                }
                else 
                {
                    orderItemElement.promoDescAuto = 0.00;
                }

                if(pOrder.IMP_DescuentoPromo__c != NULL && pOrder.IMP_DescuentoPromo__c != 0){
                    orderItemElement.promoDesc = ((pOrder.UnitPrice * pOrder.IMP_DescuentoPromo__c) / 100)* pOrder.Quantity;    
                }
                else 
                {
                    orderItemElement.promoDesc = 0.00;
                }

                Decimal TotalDesct =  pOrder.UnitPrice;

                orderItemElement.valorNetoItem = TotalDesct;

                if(pOrder.DescuentoSAP__c != NULL && pOrder.DescuentoSAP__c != 0){
                    TotalDesct = TotalDesct -((TotalDesct / 100) * (pOrder.DescuentoSAP__c));
                    orderItemElement.valorNetoItem = TotalDesct;
                    
                    System.debug('Entra ambos descuentos ' + pOrder.Product2.ProductCode + ' valorNetoItem: ' + orderItemElement.valorNetoItem);
                } 
                
                if( pOrder.DescuentoManual__c != NULL && pOrder.DescuentoManual__c != 0){
                    TotalDesct = TotalDesct -((TotalDesct / 100) * (pOrder.DescuentoManual__c));
                    orderItemElement.valorNetoItem = TotalDesct;
                }

                if( pOrder.IMP_DescuentoPromo__c != NULL && pOrder.IMP_DescuentoPromo__c != 0){
                    TotalDesct = TotalDesct -((TotalDesct / 100) * (pOrder.IMP_DescuentoPromo__c));
                    orderItemElement.valorNetoItem = TotalDesct;
                }
                //TotalDesct

                ListProductsOrder.add(orderItemElement);

            }

            productsOrder = ListProductsOrder;

            pesosProductos = [SELECT SUM(Peso_bruto__c)totalPesos FROM OrderItem WHERE OrderId =: orderId];
            resultadoPesos = (decimal)pesosProductos.get('totalPesos');
            
        }catch(Exception exc){
            system.debug('Exception PDF '+exc.getMessage()+ exc.getCause()+exc.getLineNumber());
        }
    }

    public class OrderItemCalc
    {
        public Decimal Posicion {get; set;}
        public string Name {get; set;}
        public string ProductoCode {get; set;}
        public Decimal Quantity {get; set;}
        public string Description {get; set;}
        public Decimal ListPricee {get; set;}
        public Decimal PrecioUnit {get; set;}
        public Decimal TotalPrecio {get; set;}
        public Decimal DescuentoSAP {get; set;}
        public Decimal DescuentoManual {get; set;}
        public Decimal DescuentoPromo {get; set;}
        public Decimal Peso {get; set;}
        public Decimal PrecioTotal {get; set;}
        public date ServiceDate {get; set;}
        public date EndDate {get; set;}
        public Decimal promoDescManual {get; set;}
        public Decimal promoDescAuto {get; set;}//Descuento SAP
        public Decimal promoDesc {get; set;}//Descuento Promocion 
        public Decimal valorNetoItem {get; set;}
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