/************************************************************************
Name: IMP_EjecutarJobs_cc
Copyright © 2022 Salesforce
========================================================================
Purpose:
Servicio web para la consulta de documentos de un pedido desde SAP 
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
 1.0      rotrejo@ts4.mx      19/04/2023    
************************************************************************/
public without sharing class IMP_EjecutarJobs_cc {

    @AuraEnabled
    public static void getPrices() {
        List<Pricebook2> listPrecio = [SELECT Id, Name , IMP_update__c , Sucursal__c, Lista_de_precios_SAP__c FROM Pricebook2 WHERE IsStandard=false FOR UPDATE];
        for(Pricebook2 precio : listPrecio){
            precio.IMP_update__c= false;
        }
        update listPrecio;
        Database.executeBatch(new IMP_UpdateParentPrices());
    }
    
    /*******************************************************************
    Purpose: Actualiza los materiales al dia de hoy.
    Parameters:
    Returns:
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
    @AuraEnabled
    public static void getMateriales(Date fechaInicio,Date fechaFin){
        String fechaInicial=Datetime.newInstance(fechaInicio, Time.newInstance(12, 0, 0, 0)).format('YYYY/MM/dd');
        String fechaFinal=Datetime.newInstance(fechaFin, Time.newInstance(12, 0, 0, 0)).format('YYYY/MM/dd');
        IMP_IntegracionMateriales.getMateriales(fechaFinal.replace('/',''),fechaFinal.replace('/',''));
    }
    
    
    /*******************************************************************
    Purpose: Actualiza los materiales al dia de hoy.
    Parameters:
    Returns:
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
    @AuraEnabled
    public static IMP_FlujoDocumentos.Wrapper  getFacturas(Date fechaInicio,Date fechaFin){
   
        Integer days = fechaInicio.daysBetween(fechaFin);
        IMP_FlujoDocumentos.Wrapper newWrapper;
        try{
            if(days>7){
                AuraHandledException e = new AuraHandledException('');
                e.setMessage('El período de consulta no debe ser mayor a 7 días.');
                throw e;
                
            }else{
                String fechaInicial=Datetime.newInstance(fechaInicio, Time.newInstance(12, 0, 0, 0)).format('dd/MM/YYYY');
                String fechaFinal=Datetime.newInstance(fechaFin, Time.newInstance(12, 0, 0, 0)).format('dd/MM/YYYY');
                newWrapper = IMP_FlujoDocumentos.getFacturasWrapper(null,fechaInicial.replace('/','.'),fechaFinal.replace('/','.'));
                if(newWrapper.listFacturas != null){
                    Database.executeBatch(new IMP_BatchDocumentos(newWrapper.listFacturas),10000);
                }  
            }
        }catch(Exception ex){
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
             throw new AuraHandledException(ex.getMessage()); 
        }
        
      
        return newWrapper;
    }
    
    
    /*******************************************************************
    Purpose: Actualiza los descuentos
    Parameters:
    Returns:
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
    @AuraEnabled
    public static void getDescuentos(){
        try{
           // Database.executeBatch(new IMP_BatchDescuentos(),10000);
           IMP_DescuentosManager.upsertDiscounts();
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage()); 
        }        
    }
    
    /*******************************************************************
    Purpose: Actualiza los materiales al dia de hoy.
    Parameters:
    Returns:
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/ 
    @AuraEnabled
    public static void getPedidos(Date fechaInicio,Date fechaFin){
        String fechaInicial=Datetime.newInstance(fechaInicio, Time.newInstance(12, 0, 0, 0)).format('dd/MM/YYYY').replace('/','-');
        String fechaFinal=Datetime.newInstance(fechaFin, Time.newInstance(12, 0, 0, 0)).format('dd/MM/YYYY').replace('/','-');
        Database.executeBatch(new IMP_BatchPedidos(IMP_ListPedido.getListPedido(fechaInicial,fechaFinal)),10000);

    }
    
}