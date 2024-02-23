({
    
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [
            {label: 'Código del Producto', wrapText: 'true', fieldName: 'productCode', type: 'text' },
            {label: 'Nombre del Producto', wrapText: 'true', fieldName: 'productName', type: 'text'},
            {label: 'Almacén', wrapText: 'true', fieldName: 'almacen', type: 'text'},
            {label: 'Cantidad Disponible', fieldName: 'quantity', wrapText: 'true', type: 'number', cellAttributes: { alignment:'left'}},
            {label: 'Número de Lote', wrapText: 'true', fieldName: 'noLote', type: 'text'},
            {label: 'Fecha de Caducidad', wrapText: 'true', fieldName: 'fecha', type: 'text'},
            {label: 'Fecha de Fabricación', wrapText: 'true', fieldName: 'fechaFab', type: 'text'}]);
        helper.getInicialData(cmp, event, helper);
    },
    handleClick: function (cmp, event, helper) {
        var select = cmp.find('userinput');
        if (!select.checkValidity()) {
            //select.showHelpMessageIfInvalid();
            select.reportValidity();
        }  else  {
            helper.getDisponibilidad(cmp, event, helper); 
        } 

    },
   
    
    // When user types the value in field
    getPickListValues : function(component, event, helper) {
        var newList=[];
        const list = component.get("v.listProds");
        component.set("v.picklistValues", list);
        var resultBox = component.find('resultBox');
        var currentText = component.get("v.currentText");

        if(component.get("v.currentText") != undefined) {
            list.forEach(iterator => {
                if(iterator.ProductCode != null)
                if(iterator.ProductCode.toLowerCase().includes(currentText.toLowerCase())){
                newList.push(iterator);
            }});            
            component.set("v.picklistValues", newList);               
            if(component.get("v.picklistValues").length == 0) {
                $A.util.removeClass(resultBox, 'slds-is-open');
            }else{
                $A.util.addClass(resultBox, 'slds-is-open');
            }
        }else{
            $A.util.addClass(resultBox, 'slds-is-open');
        }
        
    },
        
    // When user types the value in field
    searchField : function(component, event, helper) {
        const list = component.get("v.listProds");
        component.set("v.picklistValues", list);
        var resultBox = component.find('resultBox');
        var currentText =event.getSource().get("v.value");
        component.set("v.currentText", currentText);
        component.set("v.value", currentText);
        var newList=[];
        if(currentText.length > 0) {
            list.forEach(iterator => {
                if(iterator.ProductCode != null)
                if(iterator.ProductCode.toLowerCase().includes(currentText.toLowerCase())){
                newList.push(iterator);
            }});            
            component.set("v.picklistValues", newList);               
            if(component.get("v.picklistValues").length == 0) {
                $A.util.removeClass(resultBox, 'slds-is-open');
            }else{
                $A.util.addClass(resultBox, 'slds-is-open');
            }
        }
        else {
            $A.util.addClass(resultBox, 'slds-is-open');
        }
    },
    
    
    //When user selects a record, set it as selected
    setSelectedRecord : function(component, event, helper) {
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.currentText", event.currentTarget.dataset.name);
        component.set("v.codigoProd",event.currentTarget.dataset.name);
        var resultBox = component.find('resultBox');
        $A.util.removeClass(resultBox, 'slds-is-open');
       // helper.getDisponibilidad(component, event, helper); 
        
    }, 
    
    //Function when user clicks outside Component to close the dropdown list
    closeDropDown : function(component, event, helper) {
        var resultBox = component.find('resultBox');
        $A.util.removeClass(resultBox, 'slds-is-open');
    },           
})