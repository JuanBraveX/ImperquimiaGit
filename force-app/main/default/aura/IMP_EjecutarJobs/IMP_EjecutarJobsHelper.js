({
    updateData : function(component) {
        let help=this;
        if(component.get("v.tipoBusqueda")=="Materiales"){
            var actionProfile=component.get('c.getMateriales');
            actionProfile.setParams({'fechaInicio':component.get('v.fechaInicio'),'fechaFin':component.get("v.fechaFin")});
            actionProfile.setCallback(this,function(response)
            {
                var estado = response.getState();
            	help.messageFunction(component,response);
            
        });
            $A.enqueueAction(actionProfile);
        }else if(component.get("v.tipoBusqueda")=="Documentos"){
            var actionProfile=component.get('c.getFacturas');
            actionProfile.setParams({'fechaInicio':component.get('v.fechaInicio'),'fechaFin':component.get("v.fechaFin")});
            actionProfile.setCallback(this,function(response)
                                      {
                                          var toastEvent = $A.get("e.force:showToast");
                                          var estado = response.getState();
                                          component.set('v.spinner',false);
                                          help.messageFunction(component,response);
                                      });
            $A.enqueueAction(actionProfile);
        }else{
            var actionProfile=component.get('c.getPedidos');
            actionProfile.setParams({'fechaInicio':component.get('v.fechaInicio'),'fechaFin':component.get("v.fechaFin")});
            actionProfile.setCallback(this,function(response)
                                      {
                                          var toastEvent = $A.get("e.force:showToast");
                                          var estado = response.getState();
                                          component.set('v.spinner',false);
                                          help.messageFunction(component,response);
                                      });
            $A.enqueueAction(actionProfile);
        }

    }, 
    cerrarModalHelper:function(component)
    {
        var cmpTarget = component.find('modalFechas');
        var cmpBack = component.find('backModalFechas');
        $A.util.removeClass(cmpBack,'slds-backdrop_open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        component.set("v.fechaInicio", null);
        component.set("v.fechaFin", null);
    }, 
    updatePrecios : function(component) {
        let help=this;
        //help.messageFunction(component,response);
        var actionPrice=component.get('c.getPrices');
        actionPrice.setCallback(this,function(response)
                                {                                   
                                    var estado = response.getState();
                                    help.messageFunction(component,response);
                                });
        $A.enqueueAction(actionPrice);

    }, 
    updateDescuentos : function(component) {
        let help=this;
        var actionPrice=component.get('c.getDescuentos');
        actionPrice.setCallback(this,function(response)
                                {       
                                    var estado = response.getState();
                                    help.messageFunction(component,response);
                                });
        $A.enqueueAction(actionPrice);
        
    },
    messageFunction : function(component,response) {
        var toastEvent = $A.get("e.force:showToast");
        component.set('v.spinner',false);
        let estado=response.getState();
        console.log(estado);
        if(estado==='SUCCESS'){
            toastEvent.setParams({
                "mode": 'sticky',
                "type":"success",
                "title": "",
                "message": "Actualización Exitosa!"
            });
            this.cerrarModalHelper(component);
        }else{
            var errors = response.getError();
            console.log('error');
            console.log(errors);
            toastEvent.setParams({
                "mode": 'sticky',
                "type":"error",
                "title": "",
                "message": errors[0].message
            });
        }
        toastEvent.fire();  
    }
})