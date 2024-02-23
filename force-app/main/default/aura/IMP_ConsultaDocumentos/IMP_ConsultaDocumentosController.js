({
    doInit : function(component, event, helper) {
        helper.idPedidoSAP(component, event, helper);
    },
    cancelClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleDocuments : function(component, event, helper) {
        helper.updateDocuments(component, event, helper);
    },
})