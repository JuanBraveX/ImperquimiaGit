/************************************************************************
Name: IMP_HandleFacturas
Copyright © 2023 Salesforce
========================================================================
Purpose:
Obtiene lo montos faturados mensualmente
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
3.0      rotrejo@ts4.mx     26/05/2023     
************************************************************************/
public inherited sharing class IMP_HandleFacturas {

    /*******************************************************************
    Purpose: Obtiene las facturacion mensual de las facturas nuevas o modificadas
    Parameters: List<Factura__c> listFacts
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static void getMontos(List<Factura__c> listFacts){
        
        set<String> setCanales = new  set<String>();
        List<Date> setFechas = new  List<Date>();
        set<ID> setOwners = new  set<ID>();
        
        for(Factura__c factura:listFacts){
            setCanales.add(factura.IMP_CanalVentas__c);
            setFechas.add(factura.IMP_FechaFactura__c);
            setOwners.add(factura.IMP_Vendedor__c);
        }
        setFechas.sort();
        System.debug(setFechas.get(0));
        System.debug(setFechas.get(setFechas.size()-1));
        System.debug('CANALES '+setCanales);
        Date firstDayOfMonth =  Date.newInstance(setFechas.get(0).year(),setFechas.get(0).month() , 01);
        Date firstDayOfLastMonth = setFechas.get(setFechas.size()-1).toStartOfMonth();
        Date lastDayOfMonth = firstDayOfLastMonth.addDays(Date.daysInMonth(firstDayOfLastMonth.year(), firstDayOfLastMonth.month()) - 1);
        System.debug('First Date - '+ firstDayOfMonth);
        System.debug('Last Date - '+ lastDayOfMonth);
        
        Map<String,Decimal> mapReturn = new Map<String,Decimal>();
        for(Factura__c factura : [SELECT Id,Name,IMP_FechaFactura__c,IMP_CanalVentas__c,IMP_Vendedor__c,IMP_Vendedor__r.Name,Monto_Factura__c FROM Factura__c WHERE 
                                  IMP_CanalVentas__c IN: setCanales  AND IMP_FechaFactura__c>=:firstDayOfMonth AND 
                                  IMP_FechaFactura__c<=:lastDayOfMonth AND IMP_Vendedor__c IN :setOwners  AND IMP_Vendedor__c!= NULL]){
                                     System.debug(factura);
                                      String llave =factura.IMP_CanalVentas__c+'/'+factura.IMP_Vendedor__c+'/'+factura.IMP_FechaFactura__c.month()+'/'+factura.IMP_FechaFactura__c.year();
                                      if(!mapReturn.containsKey(llave)){
                                          mapReturn.put(llave,0);
                                      } 
                                      mapReturn.put(llave,mapReturn.get(llave)+factura.Monto_Factura__c );
                                  }
        
        Map<String,Presupuesto__c> mapPresupuestos = getPresupuestos(setCanales,firstDayOfMonth,lastDayOfMonth);
        Map<String,Decimal> mapOpps = getOpps(setOwners);
        System.debug(mapOpps);
        List<Presupuesto__c> listPresupuestos = new List<Presupuesto__c>();        
        for(String  key : mapReturn.keySet()){
            System.debug('KEY : '+ key+ '| MONTO: '+ mapReturn.get(key));
            List<String> split = key.split('/');
            String keyOpp = split.get(0)+'/'+split.get(1);
            if(mapPresupuestos.containsKey(key)){
                System.debug('PRESUPUESTO ENCONTRADO '+key );
                mapPresupuestos.get(key).IMP_FacturadoMes__c=mapReturn.get(key); 
                mapPresupuestos.get(key).IMP_TotalOportunidadesPorCerrar__c = mapOpps.containsKey(keyOpp) ?mapOpps.get(keyOpp):mapPresupuestos.get(key).IMP_TotalOportunidadesPorCerrar__c;
            }else{
                mapPresupuestos.put(key, new Presupuesto__c(
                    IMP_CanalVentas__c = split.get(0),
                    IMP_Vendedor__c  = split.get(1),
                    IMP_FacturadoMes__c=mapReturn.get(key), 
                    IMP_Fecha__c = Date.newInstance(Integer.valueOf(split.get(3)), Integer.valueOf(split.get(2)) , 1),
                    IMP_TotalOportunidadesPorCerrar__c = mapOpps.containsKey(keyOpp) ?mapOpps.get(keyOpp):0,
                    OwnerId =  split.get(1)
                ));
            }
        }
        System.debug(mapPresupuestos.values());
        upsert mapPresupuestos.values();
    }  
    
    /*******************************************************************
    Purpose: Obtiene las oportunidades actuales abiertas.
    Parameters: set<ID> ownersId
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static Map<String,Decimal> getOpps(set<ID> ownersId){
        Map<String,Decimal> mapOpps = new  Map<String,Decimal>();
        //Cuenta clave_delcanal__c 2 oppo
        try{
            
            for(Opportunity opp : [SELECT Id, CloseDate, AccountId, Account.clave_delcanal__c, OwnerId, Importe__c
                                   FROM Opportunity WHERE ownerId IN :ownersId AND StageName !=:'Ganada' AND StageName !=:'Perdida' AND CloseDate >=TODAY]){
                                       if(!mapOpps.containsKey(opp.Account.clave_delcanal__c+'/'+opp.ownerId)){
                                           mapOpps.put(opp.Account.clave_delcanal__c+'/'+opp.ownerId,0);
                                       } 
                                       mapOpps.put(opp.Account.clave_delcanal__c+'/'+opp.ownerId,mapOpps.get(opp.Account.clave_delcanal__c+'/'+opp.ownerId)+opp.Importe__c);
                                   }
        }catch(Exception exc){}
        return mapOpps;
    }
    
        /*******************************************************************
    Purpose: Obtiene los presupuestos dependiendo las fechas y el canal
    Parameters: Set<String> setCanales,Date firstDayOfMonth,Date lastDayOfMonth
    Returns: Order
    Throws [Exceptions]:
    Information about changes (versions) []:
    ********************************************************************/
    public static Map<String,Presupuesto__c> getPresupuestos(Set<String> setCanales,Date firstDayOfMonth,Date lastDayOfMonth){
        
        Map<String,Presupuesto__c > mapPresupuesto= new  Map<String,Presupuesto__c >();
        
        try{
            for(Presupuesto__c presupuesto:[SELECT Id,IMP_CanalVentas__c,IMP_Vendedor__c,IMP_Fecha__c,IMP_TotalOportunidadesPorCerrar__c,
                                            IMP_FacturadoMes__c  FROM Presupuesto__c WHERE IMP_CanalVentas__c IN: setCanales
                                             AND IMP_Fecha__c>=:firstDayOfMonth AND  IMP_Fecha__c<=:lastDayOfMonth]){
                mapPresupuesto.put(presupuesto.IMP_CanalVentas__c+'/'+presupuesto.IMP_Vendedor__c+'/'+presupuesto.IMP_Fecha__c.month()+'/'+presupuesto.IMP_Fecha__c.year(), presupuesto);
            }
            
        }catch(Exception exc){}
        
        return mapPresupuesto;
    }
}