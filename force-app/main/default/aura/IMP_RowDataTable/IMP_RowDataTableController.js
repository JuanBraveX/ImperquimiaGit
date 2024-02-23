({
    inlineEditQuantity : function(component){   
        component.set("v.quantityEditMode", true); 
        setTimeout(function(){ 
            component.find("inputId").focus();
        }, 100);
    },
    ingresaDescuento : function(component){   
        console.log('ingresa');
        component.set("v.descuentoAdicional", true); 
        setTimeout(function(){ 
            component.find("inputIdDesc").focus();
        }, 100);
    },
    closeQuantityBox : function (component, event, helper) {
        component.set('v.spinner',true);
        component.set("v.quantityEditMode", false);
        var tipoACampo = 'Cantidad';
        helper.updateCantidad(component, event, helper, tipoACampo);
    }, 
    closeDiscountBox : function (component, event, helper) {
        component.set('v.spinner',true);
        component.set("v.descuentoAdicional", false);
        var tipoACampoDesc = 'Descuento adicional';   

        helper.enviaDescuentoAprob(component, event, helper, tipoACampoDesc);
    },
    inlineEditDescTotal : function(component){   
        component.set("v.descTotalEditMode", true); 
        setTimeout(function(){ 
            component.find("inputDescTotalId").focus();
        }, 100);
    },
    closeDescTotalBox : function (component, event, helper) {
        component.set('v.spinner',true);
        component.set("v.descTotalEditMode", false); 
        var tipoACampo = 'Descuento';
        helper.updateCantidad(component, event, helper, tipoACampo);
    },
    inlineEditDescCliente : function(component){   
        component.set("v.descClienteEditMode", true); 
        setTimeout(function(){ 
            component.find("inputDescClienteId").focus();
        }, 100);
    },
    closeDescClienteBox : function (component, event, helper) {
        component.set('v.spinner',true);
        component.set("v.descClienteEditMode", false);
        var tipoACampo = 'Descuento';
       helper.updateCantidad(component, event, helper, tipoACampo);
    },
    activarDescuento: function(component, event, helper) {
        var index=component.get('v.index');
        var listProducts=component.get('v.listQuoteLineItems');
        listProducts[index].DescuentoEditable__c=!listProducts[index].DescuentoEditable__c;
        component.set('v.listQuoteLineItems',listProducts);  
        var tipoACampo = 'Descuento';
        helper.updateCantidad(component, event, helper, tipoACampo);
    },
    delProduct:function(component,event,helper)
    {
        component.set('v.spinner',true);
        helper.deleteProduct(component,event);
    }
    
})