({
	createOrder : function(component, event, helper) {
		var action = component.get('c.getOpportunity');
        action.setParams({
            "oppRec" : component.get('v.recordId'),
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            component.set("v.showSpinner", false);
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
                $A.get('e.force:closeQuickAction').fire();
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"success",
                    "title": "",
                    "message": "Se creó correctamente el pedido #"+result
                });
                toastEvent.fire();
            } else {
                let errors = response.getError();
                console.log(errors);
                if (errors) {
                    $A.get('e.force:closeQuickAction').fire();
                    if (errors[0] && errors[0].message) {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "mode": 'sticky',
                            "type":"error",
                            "title": "Error!",
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
	}
})