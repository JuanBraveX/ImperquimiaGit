/************************************************************************
Name: IMP_EnvioPedidoSAP
Copyright © 2022 Salesforce
========================================================================
Purpose:Enviar un pedido a SAP.
Controller
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    22/03/2022     INITIAL        DEV CSR:
************************************************************************/
public without sharing class IMP_EnvioPedidoSAP {
    public String I_BSTKD;	//Test3
    public cls_I_ITEM[] I_ITEM;
    public String I_KUNNR;	//0001036070
    public String I_PURCHDATE;	//
    public String I_VKBUR;	//MIXC
    public String I_VKGRP;	//001
    public String I_VKORG;	//IMPQ
    public String I_VTWEG;	//02
    public String I_ZWELS;	//
    public String E_VBELN;
    public String E_TEXT;
    public String ZLSCH;
    public String BSTDK;
    
    ///////SAP v2///////
    public String AUART;
    public String SPART;
    public String PRCTR;
    public String NETWR;
    public String ERNAM;
    public String GBSTK;
    public String ZTERM;
    public String EXT1;
    public String EXT2;
    public Decimal EXT3;
    public String BEZEI;
    public String LTEXT;
    
    public class cls_I_ITEM {
        public String POSNR;	//10
        public String MATNR;	//000000000010001377
        public String ARKTX;	//
        public Decimal KWMENG;	//1
        public String ZLSCH;	//T
        public String KSCHL;	//
        public Decimal KAWRT;	//0
        public String CHARG; //Lote
    }
    
    /*******************************************************************
    Purpose: Genera el cuerpo de la solicitud a enviar.
    Parameters: Order pedido
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static String generateJSON(Order pedido){
        User usuario = [SELECT Id,Username,Grupo_de_Vendedor__c FROM User WHERE Id =: UserInfo.getUserId()];
        String fechaFinal=System.Now().format('YYYY/MM/dd');
        IMP_EnvioPedidoSAP newPedido = new IMP_EnvioPedidoSAP();
        newPedido.I_BSTKD='SFDC'+pedido.Ordernumber;
        newPedido.ZLSCH='';
        newPedido.I_KUNNR= pedido.Account.id_de_sap__c;//Numero Cliente Id_sap__c/cuenta
        newPedido.I_PURCHDATE=fechaFinal.replace('/',''); //Fecha de confirmacion del pedido
        newPedido.I_VKBUR=pedido.Pricebook2.Sucursal__c; //Centro subministrador  Pricebook2/Sucursal__c
        newPedido.I_VKGRP=String.valueOf(usuario.Grupo_de_Vendedor__c)==null ? '':String.valueOf(usuario.Grupo_de_Vendedor__c) ;  //Grupo vendedor / Grupo_de_Vendedor__c/User
        newPedido.I_VKORG='IMPQ'; //Valor campturado por SAP
        newPedido.I_VTWEG=pedido.Account.clave_delcanal__c;   //Lista de Precios SAP / Pricebook2
        newPedido.I_ZWELS=pedido.ViaPago__c;//no se envia
        newPedido.BSTDK='';
        List<cls_I_ITEM> listProducts = new List<cls_I_ITEM>();

        set<Id> IdDiscounts = new set<Id>();
        List<OrderItem> ListItem = [SELECT Id,Product2.ProductCode,Quantity,DescuentoManual__c, IMP_Descuento__c FROM OrderItem WHERE OrderId=:pedido.Id ORDER BY CreatedDate];
        for(OrderItem oItem : ListItem) {
            IdDiscounts.add(oItem.IMP_Descuento__c);
        }
        Map<Id,Descuento__c > MapLote = new Map<Id,Descuento__c >([SELECT Id, IMP_Lote__c FROM Descuento__c  WHERE ID IN: IdDiscounts and IMP_Lote__c != null]);

        Integer counter=10;
        for(OrderItem item : ListItem){
            cls_I_ITEM prod = new cls_I_ITEM();
            prod.POSNR=String.valueOf(counter);
            item.IMP_Posicion__c = counter;
            prod.MATNR=item.Product2.ProductCode; //Codigo del producto SF
            prod.ARKTX='';//Vacio
            prod.KWMENG=item.Quantity; //Cantidad /Quantity/ OrderItem
            prod.ZLSCH=pedido.ViaPago__c; //Via de pago //Pedido /ViaPago__c
            prod.KSCHL='';//vacio
            prod.KAWRT=item.DescuentoManual__c==null? 0 : item.DescuentoManual__c;//Descuento
            prod.CHARG =  MapLote.containsKey(item.IMP_Descuento__c) ? MapLote.get(item.IMP_Descuento__c).IMP_Lote__c: ''; 
            listProducts.add(prod); 
            counter+=10;
            System.debug('Prueba lote');
            System.debug(prod.MATNR);
            System.debug(prod.CHARG);
        }
        //update listItems;
        newPedido.I_ITEM=listProducts;
        System.debug('BODY PEDIDO');
        System.debug(JSON.serialize(newPedido));
        return JSON.serialize(newPedido); 
        
    }
    
    
    /*******************************************************************
    Purpose: Envia el pedido a SAP
    Parameters: Order pedido
    Returns: Wrapper
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/  
    public static Wrapper getOrder(Order pedido){
        
        Wrapper salida = new Wrapper();
        String body = generateJSON(pedido); 
        System.debug(body);
        HttpResponse response = IMP_CalloutUtils.getResponse(body,IMP_ServiceConstants.PEDIDO_API_URL);
        System.debug(response.getBody());
        IMP_EnvioPedidoSAP reponseOrder = (IMP_EnvioPedidoSAP)JSON.deserialize(response.getBody(), IMP_EnvioPedidoSAP.class);
        if(reponseOrder.E_VBELN != ''){
            salida.mensaje=reponseOrder.E_VBELN;
            salida.status='SUCCESS';
            pedido.pedido__c=reponseOrder.E_VBELN;
            update pedido;
            salida.pedido=pedido;
            List<OrderItem> listItems =[SELECT Id,Product2.ProductCode,Quantity,DescuentoManual__c FROM OrderItem WHERE OrderId=:pedido.Id ORDER BY CreatedDate];
            Integer pos =10;
            for(OrderItem item :listItems){
                item.IMP_Posicion__c = pos;
                item.IMP_LlaveExclusiva__c = reponseOrder.E_VBELN+ '-' + pos + '-' + item.Product2.ProductCode;
                pos+=10;
            }
            System.debug('Pedido :'+pedido.pedido__c+'  Via de pago : '+ pedido.ViaPago__c);
            update listItems;
            
        }else{
            salida.mensaje=reponseOrder.E_TEXT;
            salida.status='ERROR';
        }
        return salida;
    }
    
    public class Wrapper{
        @AuraEnabled public String mensaje {get; set;}
        @auraEnabled public String status {get;set;}
        @auraEnabled public Order pedido {get;set;}

    }
}