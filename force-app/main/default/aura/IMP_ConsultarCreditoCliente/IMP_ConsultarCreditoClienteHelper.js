({
    consultaIdSAP : function(component, event, helper) {
        component.set("v.spinner", true);
        var accountId = component.get("v.recordId");
        var actionDatosValidated = component.get("c.consultaIdSAP");
            actionDatosValidated.setParams({"accountId": accountId
                                        });
            actionDatosValidated.setCallback(this, function(respuesta){
                var data = respuesta.getReturnValue();
                console.log('data id_de_sap__c: '+data.id_de_sap__c);
                component.set('v.idSAP',data.id_de_sap__c);
                if(data.id_de_sap__c == undefined){
                    
                    component.set('v.spinner',false);
                    let button = component.find('disablebuttonid');
                    button.set('v.disabled',true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "Error",
                        "title": "",
                        "message": "No se puede realizar esta acción porque el cliente no tiene id SAP generado"
                    });
                    toastEvent.fire();
                }else{
                    component.set('v.spinner',false);
                    let button = component.find('disablebuttonid');
                    button.set('v.disabled',false);
                    
                }
                
            });
            $A.enqueueAction(actionDatosValidated);
	}, 
    
    creditoCliente : function(component, event, helper) {
    	component.set("v.spinner", true); 
        var accountId = component.get("v.recordId");
        console.log('id sap'+component.get("v.idSAP"));
        console.log('recordId'+component.get("v.recordId"));

        var actionUpdate = component.get("c.updateEdoCuenta");
            actionUpdate.setParams({"clienteId": component.get("v.idSAP"),
                                    "idCuenta":component.get("v.recordId")});
            actionUpdate.setCallback(this, function(respuesta){
                var data = respuesta.getReturnValue();
                if (respuesta.getReturnValue().status === "SUCCESS"){
                    component.set('v.spinner',false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "success",
                        "title": "",
                        "message": "Se ha actualizado correctamente el crédito!"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    window.location.reload();
                }else{
                    component.set('v.spinner',false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "Error",
                        "title": "",
                        "message": "No se ha podido actualizar el crédito "+data.mensaje
                    });
                    toastEvent.fire();
                    
                }
            });
            $A.enqueueAction(actionUpdate);
	}, 
    
})