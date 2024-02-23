({
	
    init : function(component,event,helper)
    {
        component.set('v.spinnerPopUp',true);
        helper.getInitialData(component);

    },
    
    searchProductEnter: function(component, event, helper){
        component.set("v.spinner", true);
        component.set("v.pageNumber2",1);
        helper.buscaProducto(component,event,helper);
    },
    
    addProduct : function(component, event, helper) {
        var recordId = event.target.closest("[data-id]").dataset.id;
        var data = component.get('v.dataQuoteLineItem');
        data = data.map(function(rowData) {
            if (rowData.Id === recordId) {
                component.set('v.spinner',true);
                var idProducto = rowData.Id;
                helper.crearQuoteLineItem(component,rowData,idProducto);
            }
        });
    },
    handleClick: function(component, event, helper){
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
        //window.location.reload();
    },
     handlePrev : function(component, event, helper){    
        component.set("v.spinner", true);
        var pageNumber = component.get("v.pageNumber");
        var nameButton=event.getSource().getLocalId();
        if(nameButton=='pStart'){
            component.set("v.pageNumber2",1);
        }else{
            component.set("v.pageNumber2", pageNumber-1);
        }
        helper.buscaProducto(component,event, helper );
    },
    handleNext : function(component, event, helper) { 
        component.set("v.spinner", true);
        var pageNumber = component.get("v.pageNumber");
        var nameButton=event.getSource().getLocalId();
        if(nameButton=='pEnd'){
            component.set("v.pageNumber2",component.get("v.totalPages"));
        }else{
            component.set("v.pageNumber2", pageNumber+1);
        }
        
        helper.buscaProducto(component,event, helper );
    },
    
})