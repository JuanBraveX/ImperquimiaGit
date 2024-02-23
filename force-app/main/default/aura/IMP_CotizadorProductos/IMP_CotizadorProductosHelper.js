({
    getInitialData : function(component,event, helper) {
        var actionDatos = component.get('c.getInitialData');
        component.set('v.spinnerPopUp',true);
        actionDatos.setParams({
            "cotizacionId": component.get("v.recordId")
        });
        actionDatos.setCallback(this,function(response){
            var data = response.getReturnValue();
            component.set('v.spinnerPopUp',true);
            var cotizacionSincronizada = data.cotizacion.IsSyncing; 
            component.set('v.cotizacionSincronizada', cotizacionSincronizada);

            if(data.status==='SUCCESS'){
                component.set('v.spinnerPopUp',false);
                component.set('v.cotizacion', data.cotizacion);
                component.set('v.valueListaPrecios', data.cotizacion.Pricebook2Id);
                component.set('v.listQuoteLineItems',data.listQuoteLineItems); 
                component.set('v.nombreCuenta', data.cotizacion.Account.Name);
                component.set('v.listaPrecios', data.listPrecios);
                component.set('v.wrapperDiscounts', data.wrapperDiscounts);

            }

        });
        $A.enqueueAction(actionDatos); 

		
	},
    
    buscaProducto : function(component,event,helper) {
        
        var nombreProducto = component.get('v.searchData');

        if(nombreProducto!=''){
            component.set("v.busquedaProd", true);
        }else { 
            component.set("v.busquedaProd", false);
        }
        if(nombreProducto != undefined){
            if(nombreProducto.includes(',')){
                var codes = nombreProducto.split(',');
                var ProductCode="(";
                for (var i=0; i<codes.length; i++) { 
                    if(i==codes.length-1){
                        ProductCode+="'"+codes[i]+"')";
                    }else{
                        ProductCode+="'"+codes[i]+"',";
                    }
                }
                nombreProducto=ProductCode;
            }
        }
        var pageSize = component.get("v.pageSize");
        var pageNumber= component.get("v.pageNumber2");
        var action=component.get('c.getProductos');
        action.setParams({
            'nombre':nombreProducto,
            'listaPrecios': component.get('v.valueListaPrecios'),
            'pageSize' : pageSize,
            'pageNumber' : pageNumber,
            'recordId': component.get('v.recordId'),

        });
        action.setCallback(this,function(response){
            
            var state = response.getState();
            let dataRetrieved = response.getReturnValue(); 
                
            if (dataRetrieved == null){
                
                component.set('v.resultadosBusqueda',false);
                component.set('v.spinner',false);
            }else{
                
                if(dataRetrieved.listProducts.length>0){           
                    if(dataRetrieved.pageNumber < dataRetrieved.totalPages){
                        component.set("v.isLastPage", false);
                    } else{
                        component.set("v.isLastPage", true);
                    }
                    
                    component.set("v.dataSize", dataRetrieved.listProducts.length);
                    component.set("v.resultsSize",dataRetrieved.totalProducts);
                    component.set("v.totalPages",dataRetrieved.totalPages);
                    component.set("v.pageNumber",dataRetrieved.pageNumber);
                    component.set("v.pageNumberCajaTexto",dataRetrieved.pageNumber);
                    component.set('v.spinner',false);
                    component.set('v.resultadosBusqueda',true);
                    component.set("v.dataQuoteLineItem", dataRetrieved.listProducts);
                    
                    
                }else{
                    component.set('v.resultadosBusqueda',false);
                    component.set('v.spinner',false);
                    component.set("v.dataQuoteLineItem", '');
                }
            }
            
        });
        $A.enqueueAction(action); 
        
    },
    crearQuoteLineItem: function(component,rowData,idProducto){ 

        var action=component.get('c.crearQuoteLineItem');
        var wrapperDiscounts = component.get('v.wrapperDiscounts');
       
        action.setParams({
            'pbe':rowData,
            'cotizacion':component.get('v.recordId'), 
            'MapSecuences': JSON.stringify(wrapperDiscounts) 
        });
        action.setCallback(this,function(response){ 
            var respuesta=response.getReturnValue(); 

            if (respuesta.status=='SUCCESS') {
                console.log(respuesta.cotizacion);
                component.set('v.spinner',false);
                component.set('v.cotizacion', respuesta.cotizacion);
                component.set('v.totalFinal', respuesta.totalFinal);
                component.set('v.descuentos', respuesta.listDescuentos);
                component.set('v.listQuoteLineItems',respuesta.listQuoteLineItems);              
                component.set('v.valueListaPrecios', respuesta.cotizacion.Pricebook2Id);
                component.set('v.listaPrecios', respuesta.listPrecios);

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "",
                    "message": "Se ha agregado correctamente!"
                });
                toastEvent.fire();
                component.set("v.busquedaProd", false);
                component.set('v.searchData', '');
                
            }
            else{
                component.set('v.spinner',false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "Error",
                    "title": "",
                    "message": "No puede agregar productos a la cotización"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    
})