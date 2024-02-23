/****************************************************************************************************************
Name: IMP_Pedido.apxc
Copyright © 2023 Salesforce 
====================================================================================================================
Purpose: 

====================================================================================================================
History:
It is requested to migrate the quote's visual force page to a lightning component.
Creation
VERSION  AUTHOR               DATE          LINES     DETAIL           DESCRIPTION.
1.0      mvilchis@ts4.mx    15/04/2022      16-130    Order           
2.0.     rotrejo@ts4.mx     02/05/2023      16-169    Order               
********************************************************************************************************************/
@RestResource(urlMapping='/Order/*')
global class IMP_Pedido {
    /******************************************************************* 
    Purpose: Gets the answer if the order transactions was created or modified correctly.
    Parameters:
    Returns: SapResponse.
    Throws :
    Information about changes (versions)
    ********************************************************************/ 
    @HttpPost
    global static SapResponse upsertOrder() {
        
        SapResponse respuestaSap = new SapResponse();
        Map<String,String> mapResponseTransaccion= new Map<String,String>();
        List<OrderItem> listOrder = new  List<OrderItem>();
        List<Decimal> listPos= new  List<Decimal>();
        set<String> listCodigos= new  set<String>();
        set<String> setKeys = new set<String>();
        set<String> setPbes = new set<String>();
        Map<String, PricebookEntry> mapPricebookEntry = new Map<String, PricebookEntry>();
        Map<String, String> mapProducts = new Map<String, String>();
        String mensajePedido;
        System.debug('---BODY---');
        System.debug(RestContext.request.requestBody.toString());
        IMP_EnvioPedidoSAP nuevoPedido = (IMP_EnvioPedidoSAP) JSON.deserialize(RestContext.request.requestBody.toString(),IMP_EnvioPedidoSAP.class);
        Account cuenta = getAccount(nuevoPedido.I_KUNNR+nuevoPedido.I_VKORG+nuevoPedido.I_VTWEG+nuevoPedido.SPART);
        Order pedido;
        try{
            
            System.debug(nuevoPedido.I_KUNNR+nuevoPedido.I_VKORG+nuevoPedido.I_VTWEG+nuevoPedido.SPART);
            pedido = new Order(pedido__c =  nuevoPedido.E_VBELN,
                               ViaPago__c = nuevoPedido.ZLSCH,
                               EffectiveDate =nuevoPedido.BSTDK.length()==8 && nuevoPedido.BSTDK!= '00000000'? Date.valueOf(nuevoPedido.BSTDK.substring(0,4)+'-'+nuevoPedido.BSTDK.substring(4,6)+'-'+nuevoPedido.BSTDK.substring(6,8)):nuevoPedido.BSTDK =='00000000'? Date.today() : Date.valueOf(nuevoPedido.BSTDK),
                               IMP_ClaseDocumento__c  = nuevoPedido.AUART,
                               IMP_OficinaVentas__c = nuevoPedido.I_VKBUR,
                               IMP_CanalVentas__c = nuevoPedido.I_VKORG,
                               IMP_SectorVentas__c = nuevoPedido.SPART,
                               IMP_NumeroCliente__c = nuevoPedido.I_KUNNR,
                               IMP_GrupoVendedor__c = nuevoPedido.I_VKGRP,
                               IMP_DescripcionGrupoVendedor__c = nuevoPedido.BEZEI,
                               IMP_DescripcionCeBe__c  = nuevoPedido.LTEXT,
                               IMP_CentroBeneficio__c = nuevoPedido.PRCTR,
                               Precio_Total__c  = nuevoPedido.NETWR != null && nuevoPedido.NETWR!= ''?Decimal.valueOf(nuevoPedido.NETWR.replace(' ', '')):0,
                               IMP_CreadoPor__c  = nuevoPedido.ERNAM,
                               Status = nuevoPedido.GBSTK != null ? nuevoPedido.GBSTK :'Draft',
                               condiciones_de_pago__c = nuevoPedido.ZTERM,
                               IMP_CanalDistribucion__c = nuevoPedido.I_VTWEG,
                               IMP_ModificacionPedidos__c = RestContext.request.requestBody.toString());
            
            if(nuevoPedido.I_KUNNR != null && nuevoPedido.I_VKORG != null && nuevoPedido.I_VTWEG != null && nuevoPedido.SPART != null){
                pedido.AccountId=cuenta.Id!= null?pedido.AccountId=cuenta.Id: System.label.IMP_Cuenta ;
                pedido.OwnerId= getOwner(nuevoPedido.I_VKGRP,nuevoPedido.EXT1);
            }
            upsert pedido pedido__c;
            mensajePedido='Pedido Actualizado';
        }catch(Exception e){
            mensajePedido='Error en el pedido : '+ e.getMessage();
            System.debug(e.getMessage()+' - '+e.getLineNumber());
            insert new Integration_Logs__c(Tipo__c='CREAR_PEDIDO_SF',Body_JSON__c=RestContext.request.requestBody.toString().replace('"',''),Clase__c=e.getTypeName()+' '+e.getCause()+' '+e.getStackTraceString()+', Fecha : '+ DateTime.now().format('yyyy/MM/dd hh:mm:ss'), Linea__c= String.valueOf(e.getLineNumber()), Mensaje_SFDC__c=e.getMessage());
        }
        
        if(nuevoPedido.I_ITEM != null && nuevoPedido.I_ITEM.size()>0){
            for(IMP_EnvioPedidoSAP.cls_I_ITEM prodPedido : nuevoPedido.I_ITEM){
                listCodigos.add(prodPedido.MATNR.replaceFirst('^0+', ''));
            }
            for (OrderItem oi :[SELECT Id,IMP_LlaveExclusiva__c FROM Orderitem WHERE Order.pedido__c=:pedido.pedido__c])
            {
                setKeys.add(oi.IMP_LlaveExclusiva__c);
            }
            Order pedidoSf=[SELECT Id, Pricebook2id,pedido__c,Account.clave_delcanal__c,Account.grupo__c FROM Order WHERE pedido__c=:pedido.pedido__c];
            for(PricebookEntry pb:[SELECT Id,ProductCode,product2.Grupo_de_Materiales__c,UnitPrice FROM PricebookEntry WHERE ProductCode IN: listCodigos AND Pricebook2Id=:pedidoSf.Pricebook2Id AND UnitPrice>0])
            {
                mapPricebookEntry.put(pb.ProductCode, pb);
                setPbes.add(pb.product2.Grupo_de_Materiales__c);
            }
            Map<String,PoliticaDescuento__c> mapDescuentosSAP = new Map<String,PoliticaDescuento__c>();
            System.debug('Clave del canal : '+pedidoSf.Account.clave_delcanal__c);
            System.debug('Grupo del Producto : '+pedidoSf.Account.grupo__c);
            List<PoliticaDescuento__c> politicas =[SELECT Id, Activa__c, Canaldistribucion__c,GrupoProducto__c, Descuento__c,
                                                   Grupo_de_cliente_del__c, CreatedDate FROM PoliticaDescuento__c WHERE Activa__c = true
                                                   AND Canaldistribucion__c =:pedidoSf.Account.clave_delcanal__c
                                                   AND Grupo_de_cliente_del__c =:pedidoSf.Account.grupo__c
                                                   AND GrupoProducto__c IN:setPbes  ORDER BY CreatedDate ASC];
            for(PoliticaDescuento__c politica :politicas){
                mapDescuentosSAP.put(politica.GrupoProducto__c, politica);   
            }
            
            for(IMP_EnvioPedidoSAP.cls_I_ITEM prodPedido : nuevoPedido.I_ITEM){
                String llave=nuevoPedido.E_VBELN + '-' + prodPedido.POSNR.replaceFirst('^0+', '') + '-' + prodPedido.MATNR.replaceFirst('^0+', '');
                listPos.add(Decimal.valueOf(prodPedido.POSNR));
                if(setKeys.contains(llave))
                {
                    listOrder.add(new OrderItem (
                        Quantity = prodPedido.KWMENG,
                        DescuentoManual__c  = prodPedido.KAWRT/10,
                        IMP_LlaveExclusiva__c =llave,
                        IMP_Posicion__c=Decimal.valueOf(prodPedido.POSNR.replaceFirst('^0+', ''))
                    ));
                    mapProducts.put(llave,mapPricebookEntry.get(prodPedido.MATNR.replaceFirst('^0+', '')).product2.Grupo_de_Materiales__c);
                }else {
                    if(mapPricebookEntry.containsKey(prodPedido.MATNR.replaceFirst('^0+', '')))
                    {
                        listOrder.add(new OrderItem (
                            Quantity = prodPedido.KWMENG,
                            OrderId=pedidoSf.Id,
                            PricebookEntryId=mapPricebookEntry.get(prodPedido.MATNR.replaceFirst('^0+', '')).Id,
                            UnitPrice=mapPricebookEntry.get(prodPedido.MATNR.replaceFirst('^0+', '')).UnitPrice,
                            DescuentoManual__c  = prodPedido.KAWRT/10,
                            IMP_LlaveExclusiva__c =llave,
                            IMP_Posicion__c=Decimal.valueOf(prodPedido.POSNR.replaceFirst('^0+', ''))
                        ));
                        mapProducts.put(llave,mapPricebookEntry.get(prodPedido.MATNR.replaceFirst('^0+', '')).product2.Grupo_de_Materiales__c);
                    }
                }
            }
            delete [SELECT Id FROM OrderItem WHERE IMP_Posicion__c NOT IN : listPos  AND Order.pedido__c=:nuevoPedido.E_VBELN];
            List<OrderItem> newOrderItem = new  List<OrderItem>();
            Database.UpsertResult[] results =  Database.upsert(listOrder,OrderItem.IMP_LlaveExclusiva__c, false);
            Integer size = results.size();
            for(Integer index = 0; index < size; index++) {
                if(results[index].isSuccess()) {
                    if(results[index].isCreated()) {
                        if(mapProducts.get(listOrder[index].IMP_LlaveExclusiva__c) != null){
                            System.debug('Grupo Prod '+mapProducts.get(listOrder[index].IMP_LlaveExclusiva__c));
                           // System.debug('Descuento : ' + mapDescuentosSAP.get(mapProducts.get(listOrder[index].IMP_LlaveExclusiva__c)).Descuento__c);
                            listOrder[index].DescuentoSAP__c=mapDescuentosSAP.containsKey(mapProducts.get(listOrder[index].IMP_LlaveExclusiva__c))?mapDescuentosSAP.get(mapProducts.get(listOrder[index].IMP_LlaveExclusiva__c)).Descuento__c:0;
                            newOrderItem.add(listOrder[index]);
                        }
                        
                        mapResponseTransaccion.put(String.valueOf(listOrder[index].IMP_Posicion__c),'Partida Creada ' + nuevoPedido.I_ITEM[index].MATNR.replaceFirst('^0+', '')); 
                    } else {
                        mapResponseTransaccion.put(String.valueOf(listOrder[index].IMP_Posicion__c),'Partida Modificada ' + nuevoPedido.I_ITEM[index].MATNR.replaceFirst('^0+', '')); 
                    }
                }else{
                    mapResponseTransaccion.put(String.valueOf(listOrder[index].IMP_Posicion__c), String.valueOf(results[index].getErrors()));
                }
                if(!newOrderItem.isEmpty()){
                    update newOrderItem;
                }
            }
        }
        
        //noPedido+codigopro+pos
        respuestaSap.VBELN=nuevoPedido.E_VBELN +' : '+mensajePedido;
        respuestaSap.MSGNR=mapResponseTransaccion;
        return respuestaSap;
    }
    /******************************************************************* 
    Purpose: Gets an Account by the LLaveExclusiva__c
    Parameters:
    Returns: SapResponse.
    Throws :
    Information about changes (versions)
    ********************************************************************/ 
    public static Account getAccount(String llave){
        Account cuenta = new Account();
        try{
            cuenta =[SELECT ID FROM ACCOUNT WHERE IMP_LlaveExterna__c =:llave];
        } catch(Exception e){
        }
        return cuenta;
    }
    /******************************************************************* 
    Purpose: Gets an owner by GrupoVendedor__c AND Sucursal
    Parameters:
    Returns: SapResponse.
    Throws :
    Information about changes (versions)
    ********************************************************************/ 
    public static ID getOwner(String grupoVendedor,String sucursalParam){
        system.debug('sucursalParam ' + sucursalParam);
        Map<String,User> mapUsers= new  Map<String,User>();
        for(User usuario:[SELECT Id,Grupo_de_Vendedor__c,Name FROM User WHERE (Grupo_de_Vendedor__c =: Decimal.valueOf(grupoVendedor) OR Name LIKE 'Sucursal%') AND IsActive=true AND Name != 'SAP Integrator']){
            mapUsers.put(String.valueOf(usuario.Grupo_de_Vendedor__c), usuario);
            mapUsers.put(String.valueOf(usuario.Name), usuario);
           
        }
        map<String,String> mapCentroSuministrador = new map<String,String>();
        Schema.DescribeFieldResult fieldResult = Account.centro_suministrador__c.getDescribe();
        for( Schema.PicklistEntry f : fieldResult.getPicklistValues())
        {
            mapCentroSuministrador.put(f.getValue(),f.getLabel());
        } 
        String sucursal='Sucursal '+mapCentroSuministrador.get(sucursalParam);
        String sucursalSinAcento=sucursal.replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replace('ó', 'o').replaceAll('ú', 'u');
        return (grupoVendedor=='001')?mapUsers.containsKey(sucursal)?mapUsers.get(sucursal).Id:mapUsers.containsKey(sucursalSinAcento)?mapUsers.get(sucursalSinAcento).Id:UserInfo.getUserId():mapUsers.containsKey(grupoVendedor)?mapUsers.get(grupoVendedor).Id:UserInfo.getUserId();        
    }
    
    global class SapResponse{
        Public String VBELN;
        public Map<String,String> MSGNR;   
    } 
}