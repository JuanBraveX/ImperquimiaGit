({
    getDisponibilidad : function(component, event, helper)
    {	
        component.set('v.spinner',true);
        var al=component.find("selectAlmacen").get("v.value");
        var actionValidate=component.get('c.getInventario');
        actionValidate.setParams({'productCode':component.get('v.codigoProd'), 'almacen':al});
        actionValidate.setCallback(this,function(response)
                                   {                                       
                                       var data = component.get('v.data');
                                       var respuesta = response.getReturnValue();
                                       if(respuesta.codigo!='ERROR'){
                                           let dataRetrieved = respuesta.listProds; 
                                           for (var it = 0; it < dataRetrieved.length; it++) {
                                               var row = dataRetrieved[it];
                                               row.productCode=row.codigo;
                                               row.productName=row.nombre;
                                               row.quantity=row.disponibles;
                                               
                                           }
                                           dataRetrieved.sort(function(a,b) {
                                               var t1 = a.almacen == b.almacen, t2 = a.almacen < b.almacen;
                                               return t1? 0: (true?-1:1)*(t2?1:-1);
                                           });
                                           component.set("v.data", dataRetrieved);
                                           component.set('v.spinner',false);
                                       }
                                       else
                                       {
                                           var toastEvent = $A.get("e.force:showToast");
                                           toastEvent.setParams({
                                               "mode": 'sticky',
                                               "type":"error",
                                               "title": "",
                                               "message": respuesta.mensaje
                                           }); 
                                           component.set('v.spinner',false);
                                           toastEvent.fire(); 
                                       }
                                       

                                   });
        $A.enqueueAction(actionValidate); 
    },
    
    getInicialData : function(component, event, helper)
    {		
        component.set('v.spinner',true);
        var actionValidate=component.get('c.getInicialData');
        actionValidate.setParams({'fieldObject':"centro_suministrador__c"});
        actionValidate.setCallback(this,function(response)
                                   {                                       
                                       var data = component.get('v.data');
                                       var response = response.getReturnValue();
                                       console.log(response);
                                       let dataRetrieved = response.listCatalogo; 
                                       component.set('v.selectedValue',dataRetrieved[0])
                                       component.set('v.listEnvios',dataRetrieved);//listProds
                                       component.set('v.listProds',response.listProd2);
                                       component.set('v.spinner',false);
                                   });
        $A.enqueueAction(actionValidate); 
        
    },
})