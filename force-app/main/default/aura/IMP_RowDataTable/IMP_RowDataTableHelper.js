({
    updateCantidad : function(component, event, helper, tipoACampo) {
        
        var rows=component.get('v.listQuoteLineItems');
        var index=component.get('v.index');    
        var action=component.get('c.updateQuoteLineItem');
        
        action.setParams({'productEdit':rows[index], 
                          'tipoACampo' : tipoACampo
                         });
        action.setCallback(this,function(response)
                           {
                               var respuesta=response.getReturnValue();                              
                               if(respuesta.status==='SUCCESS'){
                                   component.set('v.spinner',false);
                                   component.set('v.cotizacion', respuesta.cotizacion);                                   
                                   rows[index]=respuesta.quoteLineProduct; 
                                   component.set('v.listQuoteLineItems', rows);
                                   
                                   let toastEvent = $A.get("e.force:showToast");
                                   toastEvent.setParams({
                                       "type" : "success",
                                       "title": "",
                                       "message": "Se ha actualizado correctamente!"
                                   });
                                   toastEvent.fire();
                               }
                               else
                               {
                                   component.set('v.spinner',false);
                                   let toastEvent = $A.get("e.force:showToast");
                                   toastEvent.setParams({
                                       "type" : "error",
                                       "title": "",
                                       "message": "Error al actualizar!"
                                   });
                                   toastEvent.fire();
                                   
                               }
                           });
        $A.enqueueAction(action); 
        
        
    },
    deleteProduct:function(component){
        var rows=component.get('v.listQuoteLineItems');
        var index=component.get('v.index');
        var row=rows[index];
        var action=component.get('c.deleteQuoteLineItem');
        action.setParams({'qli':row});
        action.setCallback(this,function(response){
            
            var respuesta=response.getReturnValue();
            
            if(respuesta.status==='SUCCESS'){
                component.set('v.spinner',false);
                component.set('v.cotizacion', respuesta.cotizacion);
                component.set('v.totalFinal', respuesta.totalFinal);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "",
                    "message": "Se ha eliminado correctamente!"
                });
                toastEvent.fire();
                
                let rowIndex = rows.indexOf(row);
                rows.splice(rowIndex, 1);
                component.set('v.cotizacion', respuesta.cotizacion);
                component.set('v.totalFinal', respuesta.totalFinal);
                component.set('v.listQuoteLineItems', rows);
                
            }
        });
        $A.enqueueAction(action); 
    },
    enviaDescuentoAprob: function(component, event, helper, tipoACampoDesc){
        var rows=component.get('v.listQuoteLineItems');
        var index=component.get('v.index');
        var valueDesc = component.get("v.item.Descuento_adicional__c");
        var id =component.get("v.recordId");       
        var action=component.get('c.procesoDescuento');
        action.setParams({'productEdit':rows[index],
                          'valueDesc': component.get("v.item.Descuento_adicional__c")
                         });
        action.setCallback(this,function(response){
            var respuesta=response.getReturnValue();
            if(respuesta.status==='SUCCESS'){
                component.set('v.spinner',false);
                component.set('v.cotizacion', respuesta.cotizacion);
                rows[index]=respuesta.quoteLineProduct;
                component.set('v.listQuoteLineItems', rows);
                
                
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "",
                    "message": "Se ha actualizado correctamente!"
                });
                toastEvent.fire();
            } else
            {
                component.set('v.spinner',false);
                let toastEvent = $A.get("e.force:showToast");                  
                toastEvent.setParams({
                    "type" : "error",
                    "title": "",
                    "message": "No se ha podido actualizar"
                });
                toastEvent.fire(); 
            }
        });
        $A.enqueueAction(action); 
        
        
    },
    
})