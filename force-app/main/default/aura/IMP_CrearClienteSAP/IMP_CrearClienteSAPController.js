({
    doInit : function(component, event, helper) {
        component.set("v.spinner", true);
        helper.enableButton(component, event, helper);
        //helper.solicitarToken(component, event, helper);
    },
    
    altaSAP : function(component, event, helper) {
        component.set("v.spinner", true);
        helper.postAccountSAP(component, event, helper);
    },
    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
})