({
    init : function(component,event,helper)
    {
        component.set('v.spinnerPopUp',true);
        helper.getInitialData(component);
        helper.getPicklistValues(component, event);
        
    },
    handleClick: function(component, event, helper){
        
        helper.actualizarCotizacion(component, event, helper);

    },
    
})