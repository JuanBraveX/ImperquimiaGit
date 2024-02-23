({
	doInit : function(component, event, helper) {
        component.set("v.spinner", true);
		helper.consultaIdSAP(component, event, helper);
	},
    
	updateCredito : function(component, event, helper) {
		component.set("v.spinner", true);
        helper.creditoCliente(component, event, helper);
	},

})