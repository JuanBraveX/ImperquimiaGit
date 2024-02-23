({
    getInicialData : function(component)
    {	
        var actionValidate=component.get('c.getDatosPedido');
        actionValidate.setParams({'pedidoId':component.get('v.recordId')});
        actionValidate.setCallback(this,function(response){             
            var respuesta = response.getReturnValue();
            console.log(respuesta);
            component.set("v.pedido", respuesta.pedido);
            if( respuesta.pedido.Account.Credito_Disponible__c> 0){
                component.set("v.credito", respuesta.pedido.Account.Credito_Disponible__c);
            }
            let dataRetrieved = respuesta.listProds; 
            for (var it = 0; it < dataRetrieved.length; it++) {
                var row = dataRetrieved[it];                                           
                row.productCode=row.Product2.ProductCode;
                row.productName=row.Product2.Name;
                row.quantity=row.Quantity;
                row.unitPrice=row.UnitPrice;
                row.totalPrice=row.PrecioTotal__c ;
                row.desc=row.DescuentoManual__c === undefined? 0: row.DescuentoManual__c/100;
                row.descSAP= row.DescuentoSAP__c=== undefined? 0: row.DescuentoSAP__c/100;
                row.descPromo = row.IMP_DescuentoPromo__c === undefined ? 0: row.IMP_DescuentoPromo__c/100;
                row.estiloIconoSemaforo=((row.TS4_SemaforoDisp__c ==='Success')?'greenColor':'redColor');
            }
            component.set("v.data", dataRetrieved);
            if(respuesta.codigo=='ERROR')
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "mode": 'sticky',
                    "type":"warning",
                    "title": "",
                    "message": 'No se logrado obtener la disponibilidad de los Productos, contacta a tu administrador de Salesforce.'
                });
                toastEvent.fire();  
            }
            component.set('v.spinner',false);
            
        });

        $A.enqueueAction(actionValidate); 
    },
    getDataOrder : function(component)
    {		
        var actionValidate=component.get('c.getPedido');
        actionValidate.setParams({'pedidoId':component.get('v.recordId')});
        actionValidate.setCallback(this,function(response)
        {      
            component.set("v.pedido", response.getReturnValue());
            if( response.getReturnValue().Account.Credito_Disponible__c> 0){
                
                component.set("v.credito", response.getReturnValue().Account.Credito_Disponible__c);
            }
            component.set('v.spinner',false);
        });
        $A.enqueueAction(actionValidate); 
    },
    deleteItem : function(row,component)
    {		
        var actionDelete=component.get('c.deleteOrderItem');
        actionDelete.setParams({'orderItemId':row.Id});
        actionDelete.setCallback(this,function(response)
        {   
            var toastEvent;
            if(response.getState()==='SUCCESS'){

                var rows = component.get("v.data");
                var rowIndex = rows.indexOf(row);
                console.log(rowIndex);
                rows.splice(rowIndex, 1);
                component.set("v.data", rows);
                
               // helper.getInicialData(component); 
                toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "type":"success",
                        "title": "",
                        "message": 'Se ha eliminado correctamente el Item.'
                    });
            }
            toastEvent.fire(); 
            component.set('v.spinner',false);

        });
        $A.enqueueAction(actionDelete); 
    },
    enviarSAP : function(component)
    {		
        var actionValidate=component.get('c.enviarPedioSAP');
        actionValidate.setParams({'pedido':component.get('v.pedido')});
        actionValidate.setCallback(this,function(response)
        {      
            var toastEvent;
            var respuesta=response.getReturnValue();
            if(response.getState()==="SUCCESS"){
                if(respuesta.status==="ERROR"){
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "type":"error",
                        "title": "",
                        "message": 'Error al confirmar el pedido : '+ respuesta.mensaje
                    });
                }else{
                   component.set("v.pedido", respuesta.pedido);
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "type":"success",
                        "title": "",
                        "message": 'Pedido confirmado correctamente, No de pedido: '+respuesta.mensaje
                    });
                }
            }else{
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "mode": 'sticky',
                    "type":"error",
                    "title": "",
                    "message": 'Datos Incompletos o Servicio Inactivo, contacte a su Administrador de Salesforce para mas información. '
                }); 
            }
            component.set('v.spinner',false);
            toastEvent.fire(); 
            
        });
        $A.enqueueAction(actionValidate); 
    },
})