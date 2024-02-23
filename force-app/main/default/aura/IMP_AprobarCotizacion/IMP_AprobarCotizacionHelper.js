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
            if(data.status==='SUCCESS'){
                component.set('v.spinnerPopUp',false);
                component.set('v.cotizacion', data.cotizacion);
                component.set('v.listQuoteLineItems',data.listQuoteLineItems); 
            }

        });
        $A.enqueueAction(actionDatos); 

		
	},
    
    getPicklistValues: function(component, event) {
        var action = component.get("c.getAprobacionFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.fieldMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    actualizarCotizacion: function(component, event, helper){
        
        var cotizacionId = component.get("v.recordId");
        var aprobacion = component.get('v.quote.AprobacionCliente__c');
        var action = component.get('c.actualizarCotizacion');
        action.setParams({
            "cotizacionId": cotizacionId,
            'valuePickList': aprobacion
        });
        action.setCallback(this, function(respuesta){
            var respuesta = respuesta.getReturnValue();
            if(respuesta.status == 'Ok'){
                var severity = 'success';
                var message = 'Datos guardados correctamente';
                var mode ='dismissable'; 
                var title = '';
                var messageContainer = component.find("messageContainer");
                messageContainer.displayMessage(severity,title,message);

                
            } else {
                var severity = 'error';
                var message = 'No se ha podido actualizar';
                var mode ='dismissable'; 
                var title = '';
                var messageContainer = component.find("messageContainer");
                messageContainer.displayMessage(severity,title,message);

            }
        });
        $A.enqueueAction(action);
        
        
    },
})