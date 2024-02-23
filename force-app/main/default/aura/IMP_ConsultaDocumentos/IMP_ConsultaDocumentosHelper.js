({
    idPedidoSAP : function(component, event, helper) {
        var action = component.get('c.getPedido');
        action.setParams({
            "recordId" : component.get('v.recordId'),
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            component.set("v.currentOrder",response.getReturnValue());
            component.set("v.showSpinner", false);
            console.log(component.get("v.currentOrder"));
        });
        $A.enqueueAction(action);
    },
    
    updateDocuments : function(component, event, helper) {
        let help=this;
        var action = component.get('c.getFacturasPedido');
        action.setParams({
            "pedidoId" :component.get("v.currentOrder").pedido__c,
        });
        action.setCallback(this, function(response){
            component.set("v.showSpinner", false);
            help.messageFunction(component, response);  
            $A.get('e.force:refreshView').fire();

        });
        $A.enqueueAction(action);
    },
    
    messageFunction : function(component,response) {
        var toastEvent = $A.get("e.force:showToast");
        component.set('v.spinner',false);
        let estado=response.getState();
        if(estado==='SUCCESS'){
            var wrapper = response.getReturnValue();
            toastEvent.setParams({
                "type":"success",
                "title": "Actualizacion de Datos Completa",
                "message": "No. Facturas Actualizadas: "+ wrapper.noFacturas, 
            });
        }else{
            var errors = response.getError();
            toastEvent.setParams({
                "mode": 'sticky',
                "type":"error",
                "title": "",
                "message": errors[0].message
            });
        }
        toastEvent.fire();  
    }
    
})