({
    handlePrecios :function(component,event,helper)
    {
        helper.updatePrecios(component,event,helper);
    },
    handleMateriales : function (component) {
        var cmpTarget = component.find('modalFechas');
        var cmpBack = component.find('backModalFechas');
        $A.util.addClass(cmpBack,'slds-backdrop_open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        component.set("v.tipoBusqueda","Materiales");
    }, 
    
    handleDocumentos : function (component) {
        var cmpTarget = component.find('modalFechas');
        var cmpBack = component.find('backModalFechas');
        $A.util.addClass(cmpBack,'slds-backdrop_open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        component.set("v.tipoBusqueda","Documentos");
        
    },
    handlePedidos : function (component) {
        var cmpTarget = component.find('modalFechas');
        var cmpBack = component.find('backModalFechas');
        $A.util.addClass(cmpBack,'slds-backdrop_open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        component.set("v.tipoBusqueda","Pedidos");
        
    },
    buscarMateriales : function (component, event, helper) {
        var validaFormulario = component.find('fieldRequired').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        console.log(validaFormulario);
        if(validaFormulario)
        {
            component.set('v.spinner',true);
            helper.updateData(component,event,helper);
        }
    },
    
    handleDescuentos :function(component,event,helper)
    {
        helper.updateDescuentos(component,event,helper);
    },
    cerrarModal : function (component, event, helper) {
        helper.cerrarModalHelper(component, event);
    },
    
  
})