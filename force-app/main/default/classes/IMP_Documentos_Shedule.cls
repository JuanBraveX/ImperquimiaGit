/************************************************************************
Name: IMP_Documentos_Shedule
Copyright © 2023 Salesforce
========================================================================
Purpose:
Scheduler que se ejecuta en un horario predeterminado en trabajos
programados, realiza la consulta de documentos de acuerdo a la fecha.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      rotrejo@ts4.mx    02/05/2023     INITIAL        DEV CSR:
************************************************************************/
global class IMP_Documentos_Shedule implements Schedulable,Database.AllowsCallouts {
    public void execute(SchedulableContext ctx) {
        getDailyDocs();
    }
    
    @future(callout=true) public static void getDailyDocs(){
        String fechaInicial = (System.now()-1).format('dd/MM/YYYY');
        String fechaFinal= System.now().format('dd/MM/YYYY');
        IMP_FlujoDocumentos.Wrapper newWrapper = IMP_FlujoDocumentos.getFacturasWrapper(null,fechaInicial.replace('/','.'),fechaFinal.replace('/','.'));
        Database.upsert(newWrapper.listFacturas,Factura__c.IMP_LlaveExclusiva__c , FALSE);
    }
}