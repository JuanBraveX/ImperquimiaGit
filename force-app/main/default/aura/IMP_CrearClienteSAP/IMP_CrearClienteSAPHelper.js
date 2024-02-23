({
    enableButton : function(component, event, helper) {
        var accountId = component.get("v.recordId");
        var actionDatosValidated = component.get("c.sapValidated");
            actionDatosValidated.setParams({"accountId": accountId
                                        });
            actionDatosValidated.setCallback(this, function(respuesta){
                component.set("v.spinner", false); 
                var data = respuesta.getReturnValue();
                console.log(data);
                component.set("v.currentAcc",data.cuenta);
                component.set("v.mensaje",data.mensaje);
                component.set("v.status",data.status);
                component.set("v.enviadoSap",data.enviadoSap);
                component.set("v.validToken",data.validToken);
                component.set("v.token",data.token);

               /*
                if(data.SAP_Validated__c === true && data.Estatus__c ==='Aprobada'){
                    console.log('entra if : ');
                    let button = component.find('disablebuttonid');
                    button.set('v.disabled',false);
                }else{
                    console.log('entra false : ');
                    let button = component.find('disablebuttonid');
                    button.set('v.disabled',true);
                }*/
                
            });
            $A.enqueueAction(actionDatosValidated);
	}, 
    
    solicitarToken : function(component, event, helper) {
        component.set("v.spinner", true); 
        var actionInit = component.get("c.retriveToken");
        actionInit.setCallback(this, function(respuesta){
            var dataInit = respuesta.getReturnValue();
            console.log('dataInit '+dataInit);
            if (respuesta.getReturnValue().status === "SUCCESS"){
                component.set('v.token',dataInit.token);
                console.log('TOKEN IF : '+component.get("v.token"));
                component.set("v.spinner", false); 
                //helper.postAccountSAP(component, event, helper);
            }else{
                component.set('v.spinner',false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "Error",
                        "title": "",
                        //"message": "El token no ha sido generado"
                        "message": "No se ha podido crear el cliente token"+data.mensaje
                    });
                console.log(data.mensaje);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(actionInit);
    },
    
    postAccountSAP : function(component, event, helper) {
        console.log('ENTRO POSTACCOUNTSAP ::: ');
        component.set("v.spinner", true); 
        var accountId = component.get("v.recordId");
        var accounts = component.get('v.accounts');
        var token = component.get('v.token');
        accounts.push(component.get("v.recordId"));
        component.set('v.accounts',accounts);
        var actionDatosToken = component.get("c.postAccount");
        actionDatosToken.setParams({"token": component.get('v.token'),
                                    "lstAccount":component.get('v.accounts')});
        actionDatosToken.setCallback(this, function(respuesta){
                var data = respuesta.getReturnValue();
                if (data.status === "SUCCESS"){
                    component.set('v.spinner',false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "success",
                        "title": "",
                        "message": "Se ha creado correctamente!"
                    });
                    $A.get('e.force:closeQuickAction').fire();
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    component.set('v.spinner',false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "Error",
                        "title": "",
                        "message": "No se ha podido crear el cliente envio cliente "+data.mensaje
                    });
                    toastEvent.fire();
                    console.log(data.mensaje);
                }
            });
            $A.enqueueAction(actionDatosToken);
	}, 
    
})