({
	doInit : function(component, event, helper) {
        component.set('v.dataCountryAndState', null);
        component.set('v.EventCheckIn', {'sobjectType': 'Event', Tipo__c: '', IMP_Pais__c: '', IMP_Estado__c: null, IMP_Ciudad__c : '', IMP_Calle__c:'', IMP_CodigoPostal__c: '', Geolocation__latitude__s: null, Geolocation__longitude__s: null});
        component.set('v.disableBtn', true);
        component.set('v.showSpinner', false);
        component.set('v.disableBtn', true);
        component.set('v.description', '');
        component.set('v.distancia', '');
        component.set('v.type', '');
        component.set('v.recordType', '');

        let distanciaToValidate = parseInt($A.get("$Label.c.IMP_DistanciaCheckIn"));
        component.set('v.distanciaMinima', distanciaToValidate);
        
        var today = new Date();
        component.set('v.currentDate', today);
        helper.doInit(component,event);
    },
    
    geolocalization : function(component, event, helper) {
        var idCheckInPending = component.get('v.IdCheckInPending');
        let IsCheckInPending = component.get('v.CheckInPending');
        if(IsCheckInPending){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": idCheckInPending,
                "slideDevName": "related"
            });
            navEvt.fire();
        }
        else{
            component.set("v.isModalOpen", true);
        }
    },

    
    closeModel : function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    submitDetails : function(component, event, helper) {
        helper.registerEvent(component,event);
    },
   
    getLocationOfAddres : function(component, event, helper) {

        let eventCheck = component.get('v.dataCountryAndState');
        eventCheck = eventCheck.CheckInEvent;
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            title : 'Complete los campos.',
            duration:' 2000',
            key: 'info_alt',
            type: 'warning',
            mode: 'pester'
        });

        if(!eventCheck.IMP_Pais__c){
            toastEvent.setParams({message: 'Debe de seleccionar el país'});
            toastEvent.fire();

            return;
        }

        if(!eventCheck.IMP_Estado__c){
            toastEvent.setParams({message: 'Debe de seleccionar el estado'});
            toastEvent.fire();

            return;
        }

        if(!eventCheck.IMP_Ciudad__c){
            toastEvent.setParams({message: 'Debe ingresar la ciudad'});
            toastEvent.fire();

            return;
        }

        if(!eventCheck.IMP_Calle__c){
            toastEvent.setParams({message: 'Debe ingresar la calle'});
            toastEvent.fire();

            return;
        }

        if(!eventCheck.IMP_CodigoPostal__c){
            toastEvent.setParams({message: 'Debe de ingresar el código postal'});
            toastEvent.fire();

            return;
        }

        
        helper.getGeolocationFromContact(component, event);
    },
})