({
    init: function (cmp, event, helper) {
        cmp.set('v.spinner',true);
        cmp.set('v.columns', [
            {type: 'button-icon',initialWidth: 8,typeAttributes: {iconName: 'utility:delete',name: 'Borrar',variant: 'border-filled',alternativeText: 'Borrar'},cellAttributes: { alignment:'center', class: { fieldName: 'product2Manufactura' } }},
            {label: 'Codigo del Producto', wrapText: 'true', fieldName: 'productCode', type: 'text', cellAttributes: { alignment:'center'}},
            {label: 'Nombre del Producto', wrapText: 'true', fieldName: 'productName', type: 'text', cellAttributes: { alignment:'center'}},
            {label: 'Cantidad', fieldName: 'quantity', wrapText: 'true', type: 'number', cellAttributes: { alignment:'center'}},
            {label: 'Precio Unitario', fieldName: 'unitPrice', wrapText: 'true', type: 'currency', typeAttributes: { currencyCode: 'MXN', maximumSignificantDigits: 5}, cellAttributes: { alignment:'center'}},
            {label: 'Descuento SAP', fieldName: 'descSAP', wrapText: 'true', type: 'percent', typeAttributes: { currencyCode: 'MXN',  minimumFractionDigits: '2', maximumFractionDigits: '2'}, cellAttributes: { alignment:'center'}},
            {label: 'Descuento Adicional', fieldName: 'desc', wrapText: 'true', type: 'percent', typeAttributes: { currencyCode: 'MXN',  minimumFractionDigits: '2', maximumFractionDigits: '2'}, cellAttributes: { alignment:'center'}},
            {label: 'Descuento Promoción', fieldName: 'descPromo', wrapText: 'true', type: 'percent', typeAttributes: { currencyCode: 'MXN',  minimumFractionDigits: '2', maximumFractionDigits: '2'}, cellAttributes: { alignment:'center'}},
            {label: 'Precio Total', fieldName: 'totalPrice', wrapText: 'true', type: 'currency', typeAttributes: { currencyCode: 'MXN', maximumSignificantDigits: 5}, cellAttributes: { alignment:'center'}},
            {label: 'Disponibilidad',cellAttributes: {class: { fieldName: 'estiloIconoSemaforo'},iconName: 'utility:record',alignment:'center'}}
        ]);
            helper.getInicialData(cmp); 
           // helper.getDataOrder(cmp);
    },
    handleDelete : function(component, event, helper) {
        component.set('v.spinner',true);
        var row = event.getParam('row');
        helper.deleteItem(row, component);
        
    },
    handleSend : function(component, event, helper) {
        component.set('v.spinner',true);
        helper.enviarSAP(component);   
    },

});