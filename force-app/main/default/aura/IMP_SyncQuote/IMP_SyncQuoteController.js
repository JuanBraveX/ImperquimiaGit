({
    doInit:function(component, event, helper) {
        helper.getInit(component,event);
    },
	cancelClick : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
    saveClick:function(component, event, helper) {
        component.set('v.spinner',true);
        helper.saveSyncing(component,event);
    },
    
})