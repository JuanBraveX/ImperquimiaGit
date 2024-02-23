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
global class IMP_Descuentos_Shedule implements Schedulable{
    public void execute(SchedulableContext ctx) {
        System.enqueueJob(new DescuentosQueable()); 
        // Database.executeBatch(new IMP_BatchDescuentos(),10000);
    }    
}