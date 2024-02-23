/************************************************************************
Name: IMP_CreateJson
Copyright © 2022 Salesforce
========================================================================
Purpose:
Genera Json para cuentas y materiales para realizar el post al servicio
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
2.0            mvilchis@ts4.mx    11/04/2022     
3.0            rortega@ts4.mx    24/03/2022   Se agregan campos personalizados al método createJsonAccount (Código postal y Calle)
************************************************************************/
public without sharing class IMP_CreateJson {

    /*******************************************************************
    Purpose: Genera el token
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    @AuraEnabled
    public static String getToken() {
        Map<String, String> mapToken = new Map<String, String>{
            'Username' => System.Label.User_Integration,
            'Password' => System.Label.Password_Integration
        };
        String jsonToken = JSON.serialize(mapToken);
        return jsonToken;
    }
    /*******************************************************************
    Purpose: Genera el json de cuentas
    Parameters: List<Id> lstId
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    @AuraEnabled
    public static String createJsonAccount(List<Id> lstId) {
        String jsonString;
        Map<String,Contact> mapContact = new Map<String,Contact>();
        Map<String, String> mapAccount = new Map<String, String>();
        List<Account> lstAcc = new List<Account>([SELECT Id,AccountNumber,id_de_sap__c,/*Pais de Facturación,*/Name,/*nombre2,Street,*/Numero_Interior__c,Numero_Exterior__c,Owner.Grupo_de_Vendedor__c, 
                                                  Colonia__c,BillingStreet,ShippingStreet,Delegacion__c,BillingPostalCode,ShippingPostalCode,billing_address_state__c,Phone,/*MobilePhone,*/CorreoElectronico__c, 
                                                  RegimenFiscal__c,RFC__c,Grupo_de_Cuentas__c,grupo_de_tesoreria__c,condiciones_de_pago__c,/*ViaPago__c,*/OrganizacionVentas__c,
                                                  clave_delcanal__c,Sector__c,zona_de_ventas__c,centro_suministrador__c,grupo__c,CurrencyIsoCode,Grupo_de_precios__c,
                                                  ListaPrecios__c,BillingCountry,ShippingCountry,Intercoms_1__c,Intercoms_2__c,GrupoImputacion__c,Tipo_de_persona__c,IMP_PaisFacturacion__c/*,impuesto*/
                                                  , IMP_Calle__c, IMP_CodigoPostal__c,ViaPago__c,Apellidos__c
                                                 FROM Account
                                                 WHERE Id IN : lstId]);
        for(Contact contAcc : [SELECT Id,AccountId,MobilePhone
                               FROM Contact
                               WHERE AccountId IN : lstAcc]) {
            mapContact.put(contAcc.AccountId,contAcc);
        }

        for(Account a : lstAcc) {
            
            //System.debug('nombreCuenta');
            //System.debug(nombreCuenta);
            String grupoVendedor=a.Owner.Grupo_de_Vendedor__c<10?'00'+a.Owner.Grupo_de_Vendedor__c:''+a.Owner.Grupo_de_Vendedor__c;
            
            mapAccount.put('I_KUNNR_SF',EncodingUtil.base64Encode(Blob.valueOf(a.Id+'')));
            mapAccount.put('I_LAND',EncodingUtil.base64Encode(Blob.valueOf(a.IMP_PaisFacturacion__c+'')));
            if (a.Tipo_de_persona__c==true) {
                String nombreCuenta = a.Name.toUpperCase();
                String apellidoCuenta = a.Apellidos__c.toUpperCase();
                mapAccount.put('I_NAME1',EncodingUtil.base64Encode(Blob.valueOf(nombreCuenta+'')));
                mapAccount.put('I_NAME2',EncodingUtil.base64Encode(Blob.valueOf(apellidoCuenta+'')));
            } else {
                List<String> nombreCuenta1 = splitString(a.Name.toUpperCase());
                mapAccount.put('I_NAME1',EncodingUtil.base64Encode(Blob.valueOf(nombreCuenta1.size()>=1 ? nombreCuenta1[0]:'')));
                mapAccount.put('I_NAME2',EncodingUtil.base64Encode(Blob.valueOf(nombreCuenta1.size()>=2 ? nombreCuenta1[1]:'')));
                mapAccount.put('I_NAME3',EncodingUtil.base64Encode(Blob.valueOf(nombreCuenta1.size()>=3 ? nombreCuenta1[2]:'')));
                mapAccount.put('I_NAME4',EncodingUtil.base64Encode(Blob.valueOf(nombreCuenta1.size()>=4 ? nombreCuenta1[3]:'')));
            }
            
            mapAccount.put('I_TEL1', EncodingUtil.base64Encode(Blob.valueOf(a.Phone)));
            mapAccount.put('I_CITY1', EncodingUtil.base64Encode(Blob.valueOf((String.isNotEmpty(a.Colonia__c) ? a.Colonia__c.trim().toUppercase() : a.Colonia__c+''))));
            mapAccount.put('I_CITY2', EncodingUtil.base64Encode(Blob.valueOf((String.isNotBlank(a.Delegacion__c) ? a.Delegacion__c.trim().toUppercase() : a.Delegacion__c+''))));
            mapAccount.put('I_PSTLZ', EncodingUtil.base64Encode(Blob.valueOf((String.isNotBlank(a.IMP_CodigoPostal__c) ? a.IMP_CodigoPostal__c.trim().toUppercase() : a.IMP_CodigoPostal__c+'')))); 
            mapAccount.put('I_REGIO',EncodingUtil.base64Encode(Blob.valueOf(a.billing_address_state__c+'')));
            mapAccount.put('I_STRAS', EncodingUtil.base64Encode(Blob.valueOf((String.isNotBlank(a.IMP_Calle__c) ? a.IMP_Calle__c.trim().toUppercase(): a.IMP_Calle__c+''))));
            mapAccount.put('I_STCD1',EncodingUtil.base64Encode(Blob.valueOf(a.RFC__c+'')));
            mapAccount.put('I_STKZN',EncodingUtil.base64Encode(Blob.valueOf(a.Tipo_de_persona__c==true?'X':'')));
            mapAccount.put('I_AKONT',EncodingUtil.base64Encode(Blob.valueOf(a.Grupo_de_Cuentas__c+'')));
            mapAccount.put('I_ZTERM',EncodingUtil.base64Encode(Blob.valueOf(a.condiciones_de_pago__c+'')));
            mapAccount.put('I_ZWELS',EncodingUtil.base64Encode(Blob.valueOf(a.ViaPago__c+'')));
            mapAccount.put('I_KTGRD', EncodingUtil.base64Encode(Blob.valueOf((!String.isBlank(a.GrupoImputacion__c) ? a.GrupoImputacion__c: ''))));
            mapAccount.put('I_FDGRV',EncodingUtil.base64Encode(Blob.valueOf(a.grupo_de_tesoreria__c+'')));
            mapAccount.put('I_VKORG',EncodingUtil.base64Encode(Blob.valueOf(a.OrganizacionVentas__c+'')));
            mapAccount.put('I_VTWEG',EncodingUtil.base64Encode(Blob.valueOf(a.clave_delcanal__c+'')));
            mapAccount.put('I_SPART',EncodingUtil.base64Encode(Blob.valueOf(a.Sector__c+'')));
            mapAccount.put('I_KDGRP',EncodingUtil.base64Encode(Blob.valueOf(a.grupo__c+'')));
            mapAccount.put('I_BZIRK',EncodingUtil.base64Encode(Blob.valueOf(a.zona_de_ventas__c+'')));
            mapAccount.put('I_KONDA',EncodingUtil.base64Encode(Blob.valueOf(a.Grupo_de_precios__c+'')));
            mapAccount.put('I_PLTYP',EncodingUtil.base64Encode(Blob.valueOf(a.ListaPrecios__c+'')));
            mapAccount.put('I_INCO1',EncodingUtil.base64Encode(Blob.valueOf(a.Intercoms_1__c+'')));
            mapAccount.put('I_INCO2',EncodingUtil.base64Encode(Blob.valueOf(a.Intercoms_2__c+'')));
            mapAccount.put('I_SMTP_ADDR',EncodingUtil.base64Encode(Blob.valueOf(a.CorreoElectronico__c+'')));
            mapAccount.put('I_TEL2',EncodingUtil.base64Encode(Blob.valueOf(mapContact.size()>0 ? String.valueOf(mapContact.get(a.Id).MobilePhone) : '')));
            mapAccount.put('I_VWERK',EncodingUtil.base64Encode(Blob.valueOf(a.centro_suministrador__c+'')));
            mapAccount.put('I_VKGRP',EncodingUtil.base64Encode(Blob.valueOf(grupoVendedor+'')));
            mapAccount.put('I_VKBUR',EncodingUtil.base64Encode(Blob.valueOf(a.centro_suministrador__c+'')));
            mapAccount.put('I_WAERS',EncodingUtil.base64Encode(Blob.valueOf(a.CurrencyIsoCode+'')));
            mapAccount.put('I_BEGRU',EncodingUtil.base64Encode(Blob.valueOf(a.RegimenFiscal__c+'')));
            mapAccount.put('I_HOUSE_NO',EncodingUtil.base64Encode(Blob.valueOf((String.isNotBlank(a.Numero_Exterior__c) ? a.Numero_Exterior__c.trim().toUppercase(): ''))));
            mapAccount.put('I_BUILDING',EncodingUtil.base64Encode(Blob.valueOf((String.isNotBlank(a.Numero_Interior__c) ? a.Numero_Interior__c.trim().toUppercase(): ''))));
            mapAccount.put('I_STKZU',EncodingUtil.base64Encode(Blob.valueOf((getImpuesto(a.clave_delcanal__c,a.centro_suministrador__c))+'')));
            //mapAccount.put('I_KTOKD',(a.Grupo_de_Cuentas__c=='121000' ? 'YB04':'YBEC'));

            System.debug('Mapa to serialize');

            System.debug(mapAccount);

        }
        jsonString = jsonString+JSON.serialize(mapAccount);
        jsonString = jsonString.replace('null', '');
        jsonString = jsonString.replace('":,', '":"",');

        // Convertir la cadena JSON a Base64
        Blob jsonBlob = Blob.valueOf(jsonString);
        String base64String = EncodingUtil.base64Encode(jsonBlob);
        return jsonString;

    }
    /*******************************************************************
    Purpose: Retorna el impuesto del cliente de acuerdo al canal de
    distribución y al centro suministrador.
    Parameters: String canal,String centroSuministrador
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static String getImpuesto(String canal,String centroSuministrador) {
        String centroImpuesto=System.Label.IMP_Impuesto;
        map<String,String> mapCentroSuministrador = new map<String,String>();
        Schema.DescribeFieldResult fieldResult = Account.centro_suministrador__c.getDescribe();
        for( Schema.PicklistEntry f : fieldResult.getPicklistValues())
        {
            mapCentroSuministrador.put(f.getValue(),f.getLabel());
        } 
        return (canal=='07' || centroImpuesto.contains(mapCentroSuministrador.get(centroSuministrador)))?'2':'1'; 
    }
    /*******************************************************************
    Purpose: Genera el json de materiales
    Parameters: String fechaInicio, String fechaFinal
    Returns: String
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    @AuraEnabled
    public static String createMateriales(String fechaInicio, String fechaFinal) {
        String jsonString;
        List<WrapperInnerMat> lstWrapp= new List<WrapperInnerMat>();
        WrapperInnerMat wrappInner = new WrapperInnerMat();
        wrappInner.MATNR='';
        wrappInner.WERKS='';
        wrappInner.MAKTX='';
        wrappInner.KONWA='';
        wrappInner.MATKL='';
        wrappInner.KONDM='';
        wrappInner.SKU='';
        wrappInner.TAXKM='';
        wrappInner.PLTYP='';
        wrappInner.MEINS='';
        wrappInner.LVORM='';
        lstWrapp.add(wrappInner);

        WrapperMat wrappMat = new WrapperMat();
        wrappMat.I_ERSDA=fechaInicio;
        wrappMat.I_LAEDA=fechaFinal;
        wrappMat.IT_MATERIALES=lstWrapp;
        jsonString = jsonString+JSON.serialize(wrappMat);
        jsonString = jsonString.replace('null', '');
        return jsonString;
    }

    private static List<string> splitString(String accName){ 
        List<String> ArrayWords = new List<String>();
        ArrayWords = accName.split(' ');
        integer indexStringRow = 0;
        List<String> ArrayStringRow = new List<String>();
        
        for(integer a =0; a < ArrayWords.size(); a++){
            if(a == 0){
                ArrayStringRow.add(ArrayWords[a]);
            }
            else if( (ArrayStringRow[indexStringRow].length()  + ArrayWords[a].length()  + 1) <= 35)
            {
                ArrayStringRow[indexStringRow] = ArrayStringRow[indexStringRow] + ' ' + ArrayWords[a];
            }
            else {
                indexStringRow++;
                ArrayStringRow.add(ArrayWords[a]);
            }
        }
        return ArrayStringRow;
    }
    
    public class WrapperMat{
        @AuraEnabled public String I_ERSDA {get; set;}
        @auraEnabled public String I_LAEDA {get;set;}
        @auraEnabled public List<WrapperInnerMat> IT_MATERIALES {get;set;}
        
    }
    public class WrapperInnerMat{
        @AuraEnabled public String MATNR {get; set;}
        @auraEnabled public String WERKS {get;set;}
        @auraEnabled public String MAKTX {get;set;}
        @auraEnabled public String KONWA {get;set;}
        @auraEnabled public String MATKL {get;set;}
        @auraEnabled public String KONDM {get;set;}
        @auraEnabled public String SKU {get;set;}
        @auraEnabled public String TAXKM {get;set;}
        @auraEnabled public String PLTYP {get;set;}
        @auraEnabled public String MEINS {get;set;}
        @auraEnabled public String LVORM {get;set;}
    }
}