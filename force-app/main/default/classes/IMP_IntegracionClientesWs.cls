/************************************************************************
Name: IMP_IntegracionClientesWs
Copyright © 2022 Salesforce
========================================================================
Purpose:
Expone una clase como un servicio REST para recibir cuentas de SAP
e insertar en salesforce.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
 2.0      mvilchis@ts4.mx     11/04/2022     Se realizaron mejoras y
 optimización de código. 
 3.0     rortega@ts4.mx   24/03/2023   Se agregan campos de dirección personalizados
 , reemplazando los estándar ShippingPostalCode y ShippingStreet
************************************************************************/
@RestResource(urlMapping='/CreateAccount/*')
global without sharing class IMP_IntegracionClientesWs {

    /*******************************************************************
    Purpose: Metodo HttpPost recibe una lista de cuentas "Accounts" para
    insertar en salesforce tomando como llave externa id_de_sap__c.
    Parameters: List<AccountsWrapper> Accounts
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    @HttpPost
    global static void accountPost(List<AccountsWrapper> Accounts){
        
        List<Account> lstAccIns = new List<Account>();
        Set<Id> lstAccIDs = new Set<Id>();
        Set<Id> idsCreated = new Set<Id>();
        List<AccountsWrapper> lstAccJSON = new List<AccountsWrapper>();
        String body = '';

        try {

            RestResponse res = RestContext.response;
            System.debug(res);
            Set<Decimal> grupoVendedor = new Set<Decimal>();
            Set<String> idsSap = new Set<String>();
            Map<String,Id> usuarioOwner=new Map<String,Id> ();
            Map<String,list<Account>> mapAccount=new Map<String,list<Account>> ();
            list<Account> listAccountsUpsert=new list<Account>();
            list<Account> listAccountsUpdate=new list<Account>();
            list<Integration_Logs__c> listaErrores=new list<Integration_Logs__c> ();
            map<String,String> mapCentroSuministrador = new map<String,String>();
            Schema.DescribeFieldResult fieldResult = Account.centro_suministrador__c.getDescribe();
            for( Schema.PicklistEntry f : fieldResult.getPicklistValues())
            {
                mapCentroSuministrador.put(f.getValue(),f.getLabel());
            } 

            for(AccountsWrapper acc : Accounts) {
                idsSap.add(acc.KUNNR);
                if (acc.VKGRP!=null) {
                    grupoVendedor.add(Decimal.valueOf(acc.VKGRP));
                }

            }
            for(User usuario:[SELECT Id,Grupo_de_Vendedor__c,Name FROM User WHERE (Grupo_de_Vendedor__c IN: grupoVendedor OR Name LIKE 'Sucursal%') AND IsActive=true])
            {
                if(usuario.Grupo_de_Vendedor__c==1)
                {
                    usuarioOwner.put(usuario.Name, usuario.Id);
                }
                else {
                    usuarioOwner.put(String.valueOf(usuario.Grupo_de_Vendedor__c), usuario.Id);
                }
            }
            for (Account cuenta : [SELECT Name,IMP_PaisFacturacion__c,IMP_LlaveExterna__c,CorreoElectronico__c,id_de_sap__c,ShippingStreet,Numero_Exterior__c,Colonia__c,Delegacion__c,ShippingPostalCode,billing_address_state__c,Phone,RegimenFiscal__c,RFC__c,CurrencyIsoCode,Intercoms_1__c,Intercoms_2__c,Tipo_de_persona__c,OrganizacionVentas__c,clave_delcanal__c,Sector__c FROM Account WHERE Id_de_sap__c IN : idsSap]) 
            {
                if (!mapAccount.containsKey(cuenta.id_de_sap__c)) {
                    mapAccount.put(cuenta.id_de_sap__c, new list<Account>());
                }
                mapAccount.get(cuenta.id_de_sap__c).add(cuenta);
            }

            for(AccountsWrapper acc : Accounts) {

                String llaveExterna=acc.KUNNR+acc.VKORG+acc.VTWEG+acc.SPART;
                acc.NAME2=(acc.NAME2==null)?'':' '+acc.NAME2.toUpperCase();
                acc.NAME3=(acc.NAME3==null)?'':' '+acc.NAME3.toUpperCase();
                acc.NAME4=(acc.NAME4==null)?'':' '+acc.NAME4.toUpperCase();
                System.debug('LLave ::'+llaveExterna);
                
                Boolean existeLlave=false;
                if(mapAccount.containsKey(acc.KUNNR))
                {
                    System.debug('---Existe el Cliente en SF---');
                    for(Account cuenta:mapAccount.get(acc.KUNNR))
                    {
                        System.debug('Cuenta SF::'+ cuenta.IMP_LlaveExterna__c + ' - '+cuenta.Id);
                        if(cuenta.IMP_LlaveExterna__c==null){
                            cuenta.IMP_LlaveExterna__c=cuenta.id_de_sap__c+cuenta.OrganizacionVentas__c+cuenta.clave_delcanal__c+cuenta.Sector__c;
                            if(llaveExterna==cuenta.IMP_LlaveExterna__c)
                            {
                                System.debug('Existe la cuenta, extension:::');
                                existeLlave=true;
                                Account updateExtension=getExtensionCuenta(acc,mapCentroSuministrador,usuarioOwner);
                                updateExtension.Id=cuenta.Id;
                                listAccountsUpdate.add(updateExtension);
                            }
                            else {
                                System.debug('NO existe la cuenta ::');
                                listAccountsUpdate.add(getDatosGenerales(cuenta, acc));
                            }
                        }
                        else {
                            if(llaveExterna==cuenta.IMP_LlaveExterna__c)
                            {
                                System.debug('Has una extension de cuenta');
                                existeLlave=true;
                                listAccountsUpsert.add(getExtensionCuenta(acc,mapCentroSuministrador,usuarioOwner));
                            }
                            else {
                                System.debug('Modifica Datos generales');
                                listAccountsUpsert.add(getDatosGenerales(cuenta, acc));
                            }
                        }
                    }
                }
                if(!existeLlave && acc.VKGRP!=null)
                {
                     System.debug('Se generara un cliente nuevo::: '+acc.KUNNR+acc.VKORG+acc.VTWEG+acc.SPART);
                     listAccountsUpsert.add(getExtensionCuenta(acc,mapCentroSuministrador,usuarioOwner));
                }
            }
            System.debug('Antes del Update or Upsert ');
            upsert listAccountsUpsert IMP_LlaveExterna__c;
            update listAccountsUpdate;

            //JSON Response
            System.debug('Antes del JSON ');
            String output = IMP_JsonOutput.output(listAccountsUpsert);
            res.statusCode = 200;
            res.responseBody = Blob.valueof(output);
            res.addHeader('Content-Type', 'application/json');
        }
        catch(Exception e) {
            RestResponse res = RestContext.response;
            System.debug('RESPONSE ERROR: '+res);
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('Bad request error: '+e.getMessage());
            System.debug('Un ERROR ha Ocurrido ' + e.getMessage());
            Integration_Logs__c systemLog = new Integration_Logs__c(Linea__c=String.valueOf(e.getLineNumber()),
                                                                    Clase__c=e.getTypeName()+' '+e.getCause()+' '+e.getStackTraceString(),
                                                                    Mensaje_SFDC__c=e.getMessage(),/*Body_JSON__c=body,*/Tipo__c='CREACION_CLIENTES_SAP'
            														);
            insert systemLog;
        }
    }
    private static Account getExtensionCuenta(AccountsWrapper acc,map<String,String> mapCentroSuministrador, Map<String,Id> usuarioOwner) {
        System.debug('ENTRA EXTENSION CUENTA CON '+acc.KUNNR+'-'+acc.VTWEG);
        String sucursal='Sucursal '+mapCentroSuministrador.get(acc.VWERK);
        String sucursalSinAcento=sucursal.replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replace('ó', 'o').replaceAll('ú', 'u');
        System.debug('Antes del Account ');
        Account cuenta=new Account();
        
        cuenta=getDatosGenerales(cuenta, acc);
        System.debug('Despues de account');
        cuenta.OrganizacionVentas__c=acc.VKORG;
        System.debug('OrganizacionVentas__c'+ cuenta.OrganizacionVentas__c);
        cuenta.clave_delcanal__c=acc.VTWEG;
        System.debug('clave_delcanal__c'+cuenta.clave_delcanal__c);
        cuenta.Sector__c=acc.SPART;
        System.debug('cuenta.Sector__c'+cuenta.Sector__c);
        cuenta.zona_de_ventas__c=acc.BZIRK;
        System.debug('zona_de_ventas__c'+cuenta.zona_de_ventas__c);
        cuenta.centro_suministrador__c=acc.VWERK;
        System.debug('centro_suministrador__c'+cuenta.centro_suministrador__c);
        cuenta.grupo__c=acc.KDGRP;
        System.debug('grupo__c'+cuenta.grupo__c);
        cuenta.Grupo_de_precios__c=acc.KONDA;
        System.debug('Grupo_de_precios__c'+cuenta.Grupo_de_precios__c);
        cuenta.IMP_LlaveExterna__c=acc.KUNNR+acc.VKORG+acc.VTWEG+acc.SPART;
        System.debug('IMP_LlaveExterna__c'+cuenta.IMP_LlaveExterna__c);
        cuenta.IMP_IndicadorImpuesto__c=IMP_CreateJson.getImpuesto(acc.VTWEG,acc.VWERK);
        System.debug('IMP_IndicadorImpuesto__c'+cuenta.IMP_IndicadorImpuesto__c);
        cuenta.condiciones_de_pago__c=acc.ZTERM;
        System.debug('condiciones_de_pago__c'+cuenta.condiciones_de_pago__c);
        cuenta.ListaPrecios__c=acc.PLTYP;
        System.debug('ListaPrecios__c'+cuenta.ListaPrecios__c);
        cuenta.OwnerId=(acc.VKGRP=='001')?usuarioOwner.containsKey(sucursal)?usuarioOwner.get(sucursal):usuarioOwner.containsKey(sucursalSinAcento)?usuarioOwner.get(sucursalSinAcento):UserInfo.getUserId():usuarioOwner.containsKey(acc.VKGRP)?usuarioOwner.get(acc.VKGRP):UserInfo.getUserId();
        System.debug('OwnerId'+cuenta.OwnerId);
        return cuenta;
    }
    private static Account getDatosGenerales(Account cuenta,AccountsWrapper acc) {
        cuenta.id_de_sap__c=acc.KUNNR;
        cuenta.IMP_PaisFacturacion__c=acc.LAND.toUpperCase();
        cuenta.Name=(acc.NAME1+acc.NAME2+acc.NAME3+acc.NAME4).toUpperCase();
        cuenta.CorreoElectronico__c=acc.SMTP_ADDR;
        cuenta.IMP_Calle__c = (String.isNotBlank(acc.STRAS) ? acc.STRAS.trim().toUpperCase(): acc.STRAS ); 
        cuenta.Numero_Exterior__c = (String.isNotBlank(acc.HOUSE_NO) ? acc.HOUSE_NO.trim().toUpperCase(): acc.HOUSE_NO);
        cuenta.Numero_Interior__c= (String.isNotBlank(acc.BUILDING) ? acc.BUILDING.trim().toUpperCase(): acc.BUILDING);
        cuenta.Colonia__c = (String.isNotBlank(acc.CITY1) ? acc.CITY1.trim().toUpperCase(): acc.CITY1);
        cuenta.Delegacion__c= (String.isNotBlank(acc.CITY2 ) ? acc.CITY2.trim().toUpperCase() : acc.CITY2);
        cuenta.IMP_CodigoPostal__c = (String.isNotBlank(acc.PSTLZ) ? acc.PSTLZ.trim().toUpperCase(): acc.PSTLZ);
        cuenta.billing_address_state__c=acc.REGIO;
        cuenta.Phone=acc.TEL1;
        cuenta.RegimenFiscal__c=acc.BEGRU;
        cuenta.RFC__c=acc.STCD1;
        cuenta.CurrencyIsoCode=acc.WAERS;
        cuenta.Intercoms_1__c=acc.INCO1;
        cuenta.Intercoms_2__c=acc.INCO2;
        cuenta.Tipo_de_persona__c=acc.STKZN== 'X' ? true : false;
        cuenta.Grupo_de_Cuentas__c=acc.AKONT;
        cuenta.grupo_de_tesoreria__c=acc.FDGRV;
        return cuenta;
    }

    
	global class AccountsWrapper {
		public String BUILDING;	
		public String HOUSE_NO;	
		public String BEGRU;	
		public String WAERS;	
		public String VKBUR;	
		public String VKGRP;	
		public String VWERK;	
		public String INCO2;	
		public String INCO1;	
		public String PLTYP;	
		public String KONDA;	 
		public String BZIRK;	
		public String KDGRP;	
		public String SPART;	
		public String VTWEG;	
		public String VKORG;	
		public String FDGRV;	
		public String KTGRD;	 
		public String ZWELS;	
		public String ZTERM;	
		public String AKONT;	
		public String STKZN;
		public String STCD1;	
		public String STRAS;	
		public String REGIO;	
		public String PSTLZ;	
		public String CITY2;	
		public String CITY1;	
		public String TEL1;	
		public String NAME2;
        public String NAME1;
        public String NAME3;
        public String NAME4;
		public String LAND;	
		public String KUNNR_SF;
        public String KUNNR;
        public String SMTP_ADDR;
	}
    
}