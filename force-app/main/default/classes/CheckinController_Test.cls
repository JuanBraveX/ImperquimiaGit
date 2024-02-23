/************************************************************************
Name: CheckinController_Test
Copyright © 2023 Salesforce
========================================================================
Purpose:
validar check-in, check-out
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
2.0            rortega@ts4.mx    24/03/2022   Se modifica el check-in, check out, se genera con base a la dirección de Event
usando un contacto temporal para poder generar la geolocalización
************************************************************************/
@isTest
public without sharing class CheckinController_Test {
	@testSetup static void setup(){
      	Profile perfilUser=[SELECT Name, Id FROM Profile WHERE Name='Ejecutivo'];
        Id roleId = [SELECT Id FROM UserRole WHERE Name = 'Ejecutivo Bajio' limit 1].Id;
        
        User usuario = new User();
        usuario.Username ='usuarioEjecutivo19958@gmail.com';
        usuario.LastName ='Ejecutivo1';
        usuario.FirstName ='Ejecutivo1';
        usuario.CompanyName ='ImpEje1';
        usuario.Email='EjecutivoTest1@test.com';
        usuario.Phone = '45.56.12.34.10';
        usuario.IsActive =true;
        usuario.CommunityNickname='Eje1';
        usuario.TimeZoneSidKey='America/Mexico_City';
        usuario.LocaleSidKey='es_MX';
        usuario.EmailEncodingKey='UTF-8';
        usuario.Alias='EjeIm';
        usuario.ProfileId=perfilUser.Id;
        usuario.LanguageLocaleKey='es';
        INSERT usuario;    
        
        System.runAs(usuario) {
            Event checkIn = new Event( );
            checkIn.Tipo__c = 'Check In'; 
            checkIn.Subject= 'Check In AdminTest01'; 
            checkIn.Geolocation__latitude__s = 19.5904851; 
            checkIn.Geolocation__longitude__s = -98.9914178; 
            checkIn.StartDateTime = DateTime.now();
            checkIn.EndDateTime = DateTime.now(); 
            checkIn.Subject= 'Check In' + ' ' + DateTime.now().addHours(-6); 
            checkIn.Description = 'Prueba';
            checkIn.IMP_Pais__c = 'MÉXICO';
            checkIn.IMP_Estado__c = 'CIUDAD DE MÉXICO';
            checkIn.IMP_Ciudad__c = 'CIUDAD DE MÉXICO';
            checkIn.IMP_Calle__c = 'CALLE BAHÍA DE LAS PALMAS 33';
            checkIn.IMP_CodigoPostal__c = '11300';
            INSERT checkIn;
        }
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Claudio';
        contacto.LastName = 'Ordoñez';
        contacto.email = 'test@test.com';
        contacto.MailingStreet = '3022  Strother Street';
        contacto.MailingCity = 'Into';
        contacto.MailingState = 'Alabama';
        contacto.MailingPostalCode = '35222';
        contacto.MailingCountry = 'US';
        INSERT contacto;
        
        Event  evt = new Event();
        evt.Tipo__c = 'Check In'; 
        evt.Geolocation__latitude__s = 19.5904851; 
        evt.Geolocation__longitude__s = -98.9914178; 
        evt.StartDateTime = DateTime.now();
        evt.EndDateTime = DateTime.now(); 
        evt.Subject= 'Check In CheckinController_Test'; 
        evt.Description = 'Prueba';
        evt.IMP_Pais__c = 'MÉXICO';
        evt.IMP_Estado__c = 'CIUDAD DE MÉXICO';
        evt.IMP_Ciudad__c = 'CIUDAD DE MÉXICO';
        evt.IMP_Calle__c = 'CALLE BAHÍA DE LAS PALMAS 33';
        evt.IMP_CodigoPostal__c = '11300';
        INSERT evt;
    }

    @isTest public static void validateGetCountries(){
        
        Profile perfilUser=[SELECT Name, Id FROM Profile WHERE Name='Administrador del sistema'];
            
        User usuario = new User();
        usuario.Username ='usuarioprueba19958@gmail.com';
        usuario.LastName ='Usuario1';
        usuario.FirstName ='Prueba1';
        usuario.CompanyName ='Imperquimia1';
        usuario.Email='usuariotest1@test.com';
        usuario.Phone = '45.56.12.34.10';
        usuario.IsActive =true;
        usuario.CommunityNickname='IMPQ1';
        usuario.TimeZoneSidKey='America/Mexico_City';
        usuario.LocaleSidKey='es_MX';
        usuario.EmailEncodingKey='UTF-8';
        usuario.Alias='impq1';
        usuario.ProfileId=perfilUser.Id;
        usuario.LanguageLocaleKey='es';
        INSERT usuario;    

        System.runAs(usuario) {
            Event  evt = new Event( );
            evt.Tipo__c = 'Check In'; 
            evt.Geolocation__latitude__s = 19.5904851; 
            evt.Geolocation__longitude__s = -98.9914178; 
            evt.StartDateTime = DateTime.now();
            evt.EndDateTime = DateTime.now(); 
            evt.Subject= 'Check In' + ' ' + DateTime.now().addHours(-6); 
            evt.Description = 'Prueba';
            evt.IMP_Pais__c = 'MÉXICO';
            evt.IMP_Estado__c = 'CIUDAD DE MÉXICO';
            evt.IMP_Ciudad__c = 'CIUDAD DE MÉXICO';
            evt.IMP_Calle__c = 'CALLE BAHÍA DE LAS PALMAS 33';
            evt.IMP_CodigoPostal__c = '11300';

            INSERT evt;
            
            CheckinController.wrapperContryAndState checkInController = CheckinController.getCountriesAndStates(evt.Id);
            System.assert(checkInController.ListCountry.size() > 0, 'No se encontró información en GetCountries');
        }
    }
    
    @isTest public static void validGetCountriesAnotherUser(){
        User usuario = [SELECT ID FROM User where username = 'usuarioEjecutivo19958@gmail.com'];
        
        Event eventCheckAdmin = [SELECT id, Tipo__c, Geolocation__latitude__s ,
                                 Geolocation__longitude__s, StartDateTime, 
                                 Subject, Description, IMP_Pais__c,
                                 IMP_Estado__c, IMP_Ciudad__c, IMP_Calle__c, IMP_CodigoPostal__c
                                 FROM Event where createdBy.Id =: usuario.Id];
        
        CheckinController.wrapperContryAndState checkInController = CheckinController.getCountriesAndStates(eventCheckAdmin.Id);
        System.assert(checkInController.IsEventAnotherUser , 'El evento no le pertenece al usuario');
    }

    @isTest public static void validateCreateContactTemp(){
        Event eventCheckIn = [SELECT id, Tipo__c, Geolocation__latitude__s ,
                                Geolocation__longitude__s, StartDateTime, 
                                Subject, Description, IMP_Pais__c,
                                IMP_Estado__c, IMP_Ciudad__c, IMP_Calle__c, IMP_CodigoPostal__c
                                FROM Event where Subject = 'Check In CheckinController_Test'];
        
                                String contactId = CheckinController.createContactTemp(eventCheckIn);
        System.assert(String.isNotBlank(contactId), 'No se pudo crear el contact temporal');
    }
    

    @isTest public static void validateGetGeoCode(){
        Contact contact = [SELECT ID FROM Contact WHERE FirstName = 'Claudio'
        AND LastName = 'Ordoñez'];
        System.debug('validateGetGeoCode contact');
        System.debug(contact);
        List<String> coordenadas = CheckinController.getGeoCode(contact.Id);
        System.assert(coordenadas.size() > 0, 'No se crearon las coordenadas');
    }
    
    @isTest public static void validateUserLocation(){
        Profile perfilUser=[SELECT Name, Id FROM Profile WHERE Name='Administrador del sistema'];
            
        User usuario = new User();
        usuario.Username ='usuarioprueba19958@gmail.com';
        usuario.LastName ='Usuario1';
        usuario.FirstName ='Prueba1';
        usuario.CompanyName ='Imperquimia1';
        usuario.Email='usuariotest1@test.com';
        usuario.Phone = '45.56.12.34.10';
        usuario.IsActive =true;
        usuario.CommunityNickname='IMPQ1';
        usuario.TimeZoneSidKey='America/Mexico_City';
        usuario.LocaleSidKey='es_MX';
        usuario.EmailEncodingKey='UTF-8';
        usuario.Alias='impq1';
        usuario.ProfileId=perfilUser.Id;
        usuario.LanguageLocaleKey='es';
        INSERT usuario;    

        Event  evt = new Event( );

        System.runAs(usuario) {
            evt.Tipo__c = 'Check In'; 
            evt.Geolocation__latitude__s = 19.5904851; 
            evt.Geolocation__longitude__s = -98.9914178; 
            evt.StartDateTime = DateTime.now();
            evt.EndDateTime = DateTime.now(); 
            evt.Subject= 'Check In' + ' ' + DateTime.now().addHours(-6); 
            evt.Description = 'Prueba';
            evt.IMP_Pais__c = 'MÉXICO';
            evt.IMP_Estado__c = 'CIUDAD DE MÉXICO';
            evt.IMP_Ciudad__c = 'CIUDAD DE MÉXICO';
            evt.IMP_Calle__c = 'CALLE BAHÍA DE LAS PALMAS 33';
            evt.IMP_CodigoPostal__c = '11300';

            INSERT evt;
        }
        String checkSaved = CheckinController.userLocation(evt, 19.5904851, -98.9914178);        
        System.assertEquals(checkSaved, 'SUCCESS');
    }

    @isTest public static void validateUserLocationInsert(){
        Profile perfilUser = [SELECT Name, Id FROM Profile WHERE Name='Administrador del sistema'];
            
        User usuario = new User();
        usuario.Username ='usuarioprueba19958@gmail.com';
        usuario.LastName ='Usuario1';
        usuario.FirstName ='Prueba1';
        usuario.CompanyName ='Imperquimia1';
        usuario.Email='usuariotest1@test.com';
        usuario.Phone = '45.56.12.34.10';
        usuario.IsActive =true;
        usuario.CommunityNickname='IMPQ1';
        usuario.TimeZoneSidKey='America/Mexico_City';
        usuario.LocaleSidKey='es_MX';
        usuario.EmailEncodingKey='UTF-8';
        usuario.Alias='impq1';
        usuario.ProfileId=perfilUser.Id;
        usuario.LanguageLocaleKey='es';
        Insert usuario;    

        Event  evt = new Event( );

        System.runAs(usuario) {
            evt.Tipo__c = 'Check In'; 
            evt.Geolocation__latitude__s = 19.5904851; 
            evt.Geolocation__longitude__s = -98.9914178; 
            evt.StartDateTime = DateTime.now();
            evt.EndDateTime = DateTime.now(); 
            evt.Subject= 'Check In' + ' ' + DateTime.now().addHours(-6); 
            evt.Description = 'Prueba';
            evt.IMP_Pais__c = 'MÉXICO';
            evt.IMP_Estado__c = 'CIUDAD DE MÉXICO';
            evt.IMP_Ciudad__c = 'CIUDAD DE MÉXICO';
            evt.IMP_Calle__c = 'CALLE BAHÍA DE LAS PALMAS 33';
            evt.IMP_CodigoPostal__c = '11300';
            Insert evt;
        }
        String checkSaved = CheckinController.userLocation(evt, 19.5904851, -98.9914178);        
        System.assertEquals(checkSaved, 'SUCCESS');
    }
    
    @isTest public static void validateUserLocationInsertCheckOut(){
        Profile perfilUser = [SELECT Name, Id FROM Profile WHERE Name='Administrador del sistema'];
            
        User usuario = new User();
        usuario.Username ='usuarioprueba19958@gmail.com';
        usuario.LastName ='Usuario1';
        usuario.FirstName ='Prueba1';
        usuario.CompanyName ='Imperquimia1';
        usuario.Email='usuariotest1@test.com';
        usuario.Phone = '45.56.12.34.10';
        usuario.IsActive =true;
        usuario.CommunityNickname='IMPQ1';
        usuario.TimeZoneSidKey='America/Mexico_City';
        usuario.LocaleSidKey='es_MX';
        usuario.EmailEncodingKey='UTF-8';
        usuario.Alias='impq1';
        usuario.ProfileId=perfilUser.Id;
        usuario.LanguageLocaleKey='es';
        Insert usuario;    

        Event  evt = new Event( );

        System.runAs(usuario) {
            evt.Tipo__c = 'Check Out'; 
            evt.Geolocation__latitude__s = 19.5904851; 
            evt.Geolocation__longitude__s = -98.9914178; 
            evt.StartDateTime = DateTime.now();
            evt.EndDateTime = DateTime.now(); 
            evt.Subject= 'Check In' + ' ' + DateTime.now().addHours(-6); 
            evt.Description = 'Prueba';
            evt.IMP_Pais__c = 'MÉXICO';
            evt.IMP_Estado__c = 'CIUDAD DE MÉXICO';
            evt.IMP_Ciudad__c = 'CIUDAD DE MÉXICO';
            evt.IMP_Calle__c = 'CALLE BAHÍA DE LAS PALMAS 33';
            evt.IMP_CodigoPostal__c = '11300';
            Insert evt;
        }
        String checkSaved = CheckinController.userLocation(evt, 19.5904851, -98.9914178);        
        System.assertEquals(checkSaved, 'SUCCESS');
    }

}