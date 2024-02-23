({
    doInit : function(component, event) {
        var self = this;
        self.getContryAndState(component,self);        
        
    },

    getContryAndState : function (component, helper) {
        var self = this;
        var recordId = component.get('v.recordId');
        component.set('v.showSpinner', true);
        let disabledCheckIn;

        var action = component.get('c.getCountriesAndStates');
        action.setParams({'recordId': recordId});
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if(state == 'SUCCESS') {
                console.log('ENTRO APEX ::: ');
                let dataInitial = response.getReturnValue();
                let hasCheckInCurrent = false;

                if(dataInitial.hasOwnProperty('CheckInPending')){
                   
                    component.set('v.CheckInPending', true);
                    component.set('v.disableCheckIn', true);
                    component.set('v.type', 'Check In Pending');
                    component.set('v.IdCheckInPending', dataInitial.CheckInPending.Id);
                }
                else{
                    
                    if(dataInitial.hasOwnProperty('CheckInEvent')){
                        if(dataInitial.CheckInEvent){
                            hasCheckInCurrent = true;
                        }
                    }
                    
                    if(hasCheckInCurrent){

                        if(!dataInitial.CheckInEvent.IMP_Check_In__c && !dataInitial.CheckInEvent.IMP_Check_Out__c){
                            disabledCheckIn = false;
                            component.set('v.type', 'Check In');
                            component.set('v.disableCheckIn', disabledCheckIn);
                        } else if(dataInitial.CheckInEvent.IMP_Check_In__c && !dataInitial.CheckInEvent.IMP_Check_Out__c){
                            disabledCheckIn = true;
                            component.set('v.type', 'Check Out');
                            component.set('v.disableCheckIn', disabledCheckIn);
                            
                        }
                        else if(dataInitial.CheckInEvent.IMP_Check_In__c && dataInitial.CheckInEvent.IMP_Check_Out__c){
                            disabledCheckIn = true;
                            component.set('v.type', 'Check completado');
                            component.set('v.disableCheckIn', disabledCheckIn);
                            
                        }

                        if(dataInitial.IsEventAnotherUser){
                            component.set('v.IsEventAnotherUser', true);
                            component.set('v.nameAnotherUser', dataInitial.NameAnotherUser);
                            component.set("v.disableBtn", true);
                        }
                        else {
                            component.set('v.IsEventAnotherUser', false);
                        }
                        component.set('v.latRecord', dataInitial.CheckInEvent.Geolocation__Latitude__s);
                        component.set('v.longRecord', dataInitial.CheckInEvent.Geolocation__Longitude__s);
                    }
                    else{
                        disabledCheckIn = true;
                        component.set('v.disableCheckIn', true);
                        component.set('v.type', 'Check In');
                    }
                }

                console.log('Data initial');
                console.log(dataInitial);

                component.set('v.dataCountryAndState', dataInitial);

                if(navigator.geolocation) {
                    console.log('ENTRO NAV');
                    navigator.geolocation.getCurrentPosition(
                        function(result) {
                            component.set('v.lat',result.coords.latitude);
                            component.set('v.long',result.coords.longitude);
                            console.log('LATITUD 1 : '+component.get("v.lat")+'; LONGUITUDE 1 : '+component.get("v.long"));
                            console.log('LATITUD : '+result.coords.latitude+'LONGUITUDE : '+result.coords.longitude);
                            if(component.get("v.lat") != '' && component.get("v.long") != '') {
                                console.log('COORDERNADAS OBTENIDAS !');
        
                                if(disabledCheckIn){
                                    self.geolocalizationcompare(component);
                                    component.set('v.EventCheckIn', dataInitial.CheckInEvent);
                                }else {
                                    component.set('v.showSpinner', false);
                                }

                            }
                        },
                        self.error,
                        {
                            maximumAge : 0,
                            timeout : 30000,
                            enableHighAccuracy : true
                        }
                    );
                }
            }
        });
        $A.enqueueAction(action);

    },
    
    registerEvent : function (component,event){
        component.set("v.isModalOpen", false);
        component.set("v.disableBtn", true);

        var action = component.get('c.userLocation');

        let checEvent = component.get('v.dataCountryAndState');
        checEvent = checEvent.CheckInEvent;
        let tipo = component.get('v.type');
        let descripcion = component.get('v.description');
        let latitude = component.get('v.latRecord');
        let longitude = component.get('v.longRecord');

        checEvent.Geolocation__latitude__s = latitude;
        checEvent.Geolocation__longitude__s = longitude;
        checEvent.Tipo__c = tipo;
        checEvent.Description = descripcion != '' ? descripcion: null;

        console.log('RegisterEvent');
        console.log('Event Object');
        console.log(JSON.stringify(checEvent));
      
        action.setParams(
        {
            "checkEvent" : checEvent,
            "latitude":  latitude,
            "longitude": longitude
         });

        //checkEvent
        action.setCallback(this, function(response){
            var state = response.getState(); // get the response state
            if(state == 'SUCCESS') {
                var tipoCheck = component.get('v.type');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Registro Completado.',
                    message: tipoCheck + ' registrado correctamente',
                    duration:' 2000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                component.set("v.type", '');
                component.set("v.description", '');
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
               
            }
            else if (state != 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error!',
                    message:'Ha ocurrido un error, por favor intente de nuevo.',
                    duration:' 2000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    getGeolocationFromContact : function (component,event){
        var self = this;
        let eventRow = component.get('v.dataCountryAndState');
        eventRow = eventRow.CheckInEvent;
        
        component.set('v.showSpinner', true);
        component.set('v.disableCheckIn', true);
        
        console.log('1 First Execution: getGeolocationFromContact');

        try{

            var action = component.get('c.createContactTemp');
            action.setParams({
                "eventAddress" : eventRow
            });
            action.setCallback(this, function(response){
                var state = response.getState(); // get the response state
                console.log('Respuesta');
                console.log(response.getReturnValue());
                if(state == 'SUCCESS') {
                    
                    
                    var idContactCreated = response.getReturnValue();
                    console.log('idContactCreated');
                    console.log(idContactCreated);

                    window.setTimeout(
                        $A.getCallback(function() {
                            self.getGeocodeLocation(component, idContactCreated);
                        }), 9000
                    );
                }
                else if (state != 'SUCCESS') {
                    component.set('v.disableCheckIn', false);
                    component.set('v.showSpinner', false);
                    component.set('v.disableCheckIn', false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error!',
                        message:'No se ha podido obtener su ubicación, por favor vuelva a intentarlo.',
                        duration:' 2000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        //$A.get('e.force:refreshView').fire();
        }
        catch(e){
            console.log('getGeolocationFromContact:Ocurrio un error');
            console.log(e.message);
            component.set('v.disableCheckIn', false);
        }
    },
    getGeocodeLocation : function (component, idContactCreated){
        var self = this;
        component.set('v.showSpinner', true);
        component.set('v.disableCheckIn', true);
        console.log('2 Second Execution: getGeocodeLocation');

        try{
            
            
            var actionLoc = component.get('c.getGeoCode');
            actionLoc.setParams({
                "idContact" : idContactCreated
                
            });
            actionLoc.setCallback(this, function(resp){
                var state = resp.getState(); // get the response state
                var objEvent = component.get('v.EventCheckIn');

                if(state == 'SUCCESS') {
                
                    var toastEvent = $A.get("e.force:showToast");
                    let latitude = component.get("v.latRecord");
                    let longitude = component.get("v.longRecord");
                    let ListLocation = resp.getReturnValue();

                    latitude = parseFloat(ListLocation[0]).toFixed(7);
                    longitude = parseFloat(ListLocation[1]).toFixed(7);

                    component.set('v.lstRecord', ListLocation);
                    component.set('v.latRecord', latitude);
                    component.set('v.longRecord', longitude);

                    console.log('latitud record');
                    console.log(latitude);

                    console.log('longitude record');
                    console.log(longitude);

                    if((latitude && longitude) && (!isNaN(latitude) && !isNaN(longitude)) ){
                        toastEvent.setParams({
                            title : 'Geolocalización',
                            message: 'Ubicación encontrada',
                            duration:' 2000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        console.log('Entra comparación de ubicación');
                        objEvent.Geolocation__latitude__s = latitude;
                        objEvent.Geolocation__longitude__s = longitude;
                        console.log(objEvent);
                        component.set('v.EventCheckIn', objEvent);
                        self.geolocalizationcompare(component);
                    }
                    else {
                        component.set('v.disableCheckIn', false);
                        toastEvent.setParams({
                            title : 'Geolocalización',
                            message: 'No se ha podido obtener su ubicación, por favor vuelva a intentarlo.',
                            duration:' 2000',
                            key: 'info_alt',
                            type: 'warning',
                            mode: 'pester'
                        });
                        console.log('No entra comparación de ubicación');
                        component.set('v.showSpinner', false);
                    }
                    toastEvent.fire();
                    
                    console.log('LAT RECORD : ' + latitude + ' LONG RECORD : ' + longitude);
                }
                else if (state != 'SUCCESS') {
                    component.set('v.showSpinner', false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Geolocalización!',
                        message:'No se ha podido obtener su ubicación, por favor vuelva a intentarlo.',
                        duration:' 2000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            });

            $A.enqueueAction(actionLoc);
        }
        catch(error){
            console.log("An error occurred 2 Second Execution: getGeocodeLocation: " + error.message);
        }
    },
    geolocalizationcompare : function (component) {
        try{
            console.log('3 third Execution: geolocalizationcompare');
            console.log('INICIA COMPARACION');
            var lat2 = component.get("v.lat");
            var lon2 = component.get("v.long");
            var lat1 = component.get('v.latRecord');
            var lon1 = component.get('v.longRecord');
            var distanciaMinima = component.get('v.distanciaMinima');
            distanciaMinima = parseInt(distanciaMinima);
            
            //
            var deg2rad = function(deg) {return deg*((Math.PI)/180);}
            var R = 6371; // Radius of the earth in km
            var dLat = deg2rad(lat2-lat1);  // deg2rad below
            var dLon = deg2rad(lon2-lon1); 
            var a = 
                Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
                Math.sin(dLon/2) * Math.sin(dLon/2);
                var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
                var d = (R * c)*1000; // Distance in (Mts,km)
                console.log('DISTANCIA : '+d);
                component.set('v.distancia',d.toFixed(2));
        
            if(d < distanciaMinima){
                console.log('VALIDACION_DISTANCIA');
                component.set('v.disableBtn',false);
            }


            if(component.get('v.type') != 'Check In' ){
                component.set('v.disableCheckIn', true);
            }
            else {
                component.set('v.disableCheckIn', false);
            }

           
            component.set('v.showSpinner', false);
            
        }
        catch(error){
            console.log("An error occurred 3 third Execution: geolocalizationcompare: " + error.message);
        }
    },
})