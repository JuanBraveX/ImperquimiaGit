({
	getInit : function(component,event) {
		 var action = component.get('c.getQuote');
        action.setParams({
            "idQuote": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var respuesta = response.getReturnValue();
            
            component.set('v.cotizacion',respuesta.cotizacion);

            if(respuesta.header=='Reemplazar sincronización')
            {
                component.set('v.modalHeader','Sincronizar cotización');
                component.set('v.isRemSyncing',true);
            }
            else if(respuesta.header=='Detener sincronización')
            {
                component.set('v.isUnSyncing',true);
                component.set('v.modalHeader','¿Detener sincronización?');


            }
            else if(respuesta.header=='Sincronizar cotización')
            {
                component.set('v.modalHeader',respuesta.header);
                component.set('v.isSyncing',true);
            }

        });
        $A.enqueueAction(action);  

	},
    saveSyncing: function(component,event)
    {
        
         var action = component.get('c.saveSync');
        action.setParams({
            "cotizacion": component.get("v.cotizacion"),
            "unSync":component.get('v.isUnSyncing')
        });
        action.setCallback(this, function(response){

             var respuesta=response.getReturnValue();
           
            component.set('v.spinner',false);
            if(respuesta.status =='SUCCESS')
            {
               
                var cotizacion= component.get('v.cotizacion');
                var mensajeToast;
                if(component.get('v.isSyncing') || component.get('v.isRemSyncing'))
                {
                    mensajeToast="El cotización "+cotizacion.Name+" se ha sincronizado con la oportunidad "+cotizacion.Opportunity.Name+".";
                }
                else if(component.get('v.isUnSyncing'))
                {
                    mensajeToast="El cotización "+cotizacion.Name+" no se ha sincronizado con la oportunidad "+cotizacion.Opportunity.Name+".";
                    
                }
                $A.get("e.force:closeQuickAction").fire();

                $A.get('e.force:refreshView').fire();
              
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "type":"Success",
                    "message": mensajeToast
                });
                toastEvent.fire();

                

            }
            else
            {
                
                var toastEvent = $A.get("e.force:showToast");
                
                var mensaje=respuesta.mensaje;
                
                if(mensaje.includes('No se puede Cerrar'))
                {
                    mensaje='No es posible modificar una cotización de una oportunidad cerrada';
                }

                toastEvent.setParams({
                    "title": "",
                    "type":"Error",
                    "message": mensaje

                });
                toastEvent.fire(); 
            }

            
        });
        $A.enqueueAction(action);  

    }
})