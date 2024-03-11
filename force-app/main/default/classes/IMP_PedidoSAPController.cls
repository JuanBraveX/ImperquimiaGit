/************************************************************************
Name: IMP_PedidoSAPController
Copyright © 2022 Salesforce
========================================================================
Purpose:
Controller
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    22/03/2022     INITIAL        DEV CSR:
************************************************************************/

public without sharing class IMP_PedidoSAPController {
    
    /*******************************************************************
    Purpose: Obtiene los datos de los productos del pedido, incluyendo la disponbilidad
    Parameters: String pedidoId
    Returns: List<OrderItem>
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    @auraEnabled
    public static Wrapper getDatosPedido(String pedidoId){
        System.debug('Pedido ID: ' + pedidoId);
        List<OrderItem> listItems= [SELECT Id, Product2.ProductCode,DescuentoManual__c ,DescuentoSAP__c,IMP_DescuentoPromo__c, PrecioTotal__c , Product2.Name,TS4_SemaforoDisp__c , Quantity, CurrencyIsoCode, UnitPrice, ListPrice, TotalPrice, OrderItemNumber FROM OrderItem WHERE orderId=:pedidoId];
        System.debug('List de Pedidos: ' + listItems);
        List<String> listaCodigos = new List<String>();
        
        for(OrderItem item:listItems){
            listaCodigos.add(item.Product2.ProductCode);
        }        
        System.debug('List de Codigos: ' + listaCodigos);
        Wrapper newWrapper = new Wrapper();
        try{ 
            Order pedido=[SELECT Id,Ordernumber,Pricebook2Id,pedido__c,Account.clave_delcanal__c, EffectiveDate,TotalAmount,Account.Credito_Disponible__c,Account.Credito_Acumulado__c ,TotalPedido__c, Account.Name,Account.id_de_sap__c,ViaPago__c,Pricebook2.Sucursal__c,
                          Pricebook2.Lista_de_precios_SAP__c FROM Order WHERE Id=:pedidoId];
            Pricebook2 listaPrecios =[SELECT Id,Sucursal__c FROM Pricebook2 WHERE Id=:pedido.Pricebook2Id];
            Map<String,Decimal> mapResponse = new Map<String,Decimal>();
            List<IMP_InventarioManager.cls_ZINVENTARIOS> listProdsResponse =  IMP_InventarioManager.getInventario(listaCodigos,listaPrecios.Sucursal__c);
            newWrapper.pedido=pedido;
            if(listProdsResponse != null){
                for(IMP_InventarioManager.cls_ZINVENTARIOS product:listProdsResponse){
                    if(mapResponse.containsKey(product.MATNR.replaceFirst('^0+', ''))){
                        mapResponse.put(product.MATNR.replaceFirst('^0+', ''),mapResponse.get(product.MATNR.replaceFirst('^0+', ''))+product.CLABS); 
                    }else{
                        mapResponse.put(product.MATNR.replaceFirst('^0+', ''),product.CLABS);
                    }
                }
                for(OrderItem item:listItems){
                    if(mapResponse.containsKey(item.Product2.ProductCode)){
                        if(mapResponse.get(item.Product2.ProductCode) > item.Quantity){
                            item.TS4_SemaforoDisp__c='Success';
                        }else{
                            item.TS4_SemaforoDisp__c='Error';
                        }
                    }else{
                        item.TS4_SemaforoDisp__c='Error';
                    }
                }
                newWrapper.codigo='SUCCESS';
                
            }else{
                for(OrderItem item:listItems){
                    item.TS4_SemaforoDisp__c='Error';
                }
                newWrapper.codigo='ERROR';
            }
           // update listItems;
        }
        catch(Exception e)
        {
            System.debug('IMP_PedidoSAPController : '+ e.getMessage());
            newWrapper.codigo='ERROR';
        }
        newWrapper.listProds=listItems;
        return newWrapper;
    }
    
    /*******************************************************************
    Purpose: Elimina un producto de pedido
    Parameters: String orderItemId
    Returns:
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
     @auraEnabled
    public static void deleteOrderItem(String orderItemId){
        delete [SELECT Id FROM OrderItem WHERE Id=:orderItemId]; 
    }
    
    /*******************************************************************
    Purpose: Obtiene los datos del pedido
    Parameters: String pedidoId
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    /*@auraEnabled
    public static Order getPedido(String pedidoId){
        return [SELECT Id,Ordernumber,Pricebook2Id,pedido__c,Account.clave_delcanal__c, EffectiveDate,TotalAmount,Account.Credito_Disponible__c,Account.Credito_Acumulado__c ,TotalPedido__c, Account.Name,Account.id_de_sap__c,ViaPago__c,Pricebook2.Sucursal__c,
                Pricebook2.Lista_de_precios_SAP__c FROM Order WHERE Id=:pedidoId];
    }*/
    
    
    /*******************************************************************
    Purpose: Envia el pedido a SAP
    Parameters: Order pedido
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
     @auraEnabled
    public static IMP_EnvioPedidoSAP.Wrapper enviarPedioSAP(Order pedido){
        return IMP_EnvioPedidoSAP.getOrder(pedido);
    }
    
    public class Wrapper{
        @AuraEnabled public List<OrderItem> listProds;
        @AuraEnabled public Order pedido;
        @AuraEnabled public String codigo;
        
    }
}