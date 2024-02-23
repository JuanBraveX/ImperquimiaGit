/************************************************************************
Name: IMP_BRAnalyticsSchedule
Copyright © 2022 Salesforce
========================================================================
Purpose:
Scheduler que se ejecuta en un horario predeterminado en trabajos
programados, realiza la inserción de proyectos de acuerdo a la fecha.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      dmarcos@ts4.mx    03/05/2022     INITIAL        DEV CSR:
************************************************************************/
public class IMP_BRAnalyticsSchedule implements Schedulable{
    public void execute(SchedulableContext ctx){
        String fechaConsulta =(System.Now()-1).format('YYYY-MM-dd');
        System.debug('fechaConsulta'+fechaConsulta);
        //String fechaConsulta =(System.Now()).format('YYYY-MM-dd');
        IMP_BRAnalyticsIntegration.getDataAnalytics(fechaConsulta);
    }
}