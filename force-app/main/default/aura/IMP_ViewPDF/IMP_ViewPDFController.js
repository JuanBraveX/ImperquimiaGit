({
    loadPDF: function(component, event, helper) {

        try{
           
            var device =  $A.get("$Browser.formFactor");
            component.set('v.typeDevice', device);

            var action = component.get('c.getObjectTypeName');
            action.setParams({
                "objectId": component.get("v.recordId")
            });

            action.setCallback(this,function(response){
                var estado = response.getState();
                if(estado==='SUCCESS'){
                    let tipoObjecto = response.getReturnValue();
                    
                    component.set('v.spinner',false);
                    component.set('v.typeObject',tipoObjecto);

                    //alert(tipoObjecto);

                    if(device != 'DESKTOP') {
                        //alert(device);
                        component.set('v.spinner',true);
                        var actionDataPdf = component.get('c.getPDF');
                        actionDataPdf.setParams({
                            "idRecord": component.get("v.recordId"),
                            "tipoObjeto": tipoObjecto
                        });
                        
                        actionDataPdf.setCallback(this,function(response){
                            var estado = response.getState();
                            if(estado==='SUCCESS'){
                                
                                component.set('v.spinner',false);
                                var idContentPDF = response.getReturnValue()
                                
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": idContentPDF,
                                    "slideDevName": "related"
                                });
                                navEvt.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                component.set('v.spinner',false);
                            }
                            else {
                                alert('No se pudo generar el pdf')
                                component.set('v.spinner',false);
                            }
                        });
                        $A.enqueueAction(actionDataPdf); 
                    }
                 
                }
                else {
                    alert('No se pudo obtener el tipo de pdf a generar')
                    component.set('v.spinner',false);
                }
            });
            $A.enqueueAction(action); 
            
           
        }
        catch(e){
            console.log(e);
        }

    }
})