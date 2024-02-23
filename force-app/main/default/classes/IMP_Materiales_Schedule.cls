/************************************************************************
Name: IMP_Materiales_Schedule
Copyright © 2022 Salesforce
========================================================================
Purpose:
Scheduler que se ejecuta en un horario predeterminado en trabajos
programados, realiza la consulta de materiales de acuerdo a la fecha.
========================================================================
History:

VERSION        AUTHOR           DATE         DETAIL       Description   
  1.0      mvilchis@ts4.mx    11/04/2022     INITIAL        DEV CSR:
************************************************************************/
public class IMP_Materiales_Schedule implements Schedulable{
    
	public void execute(SchedulableContext ctx) {
        String fechaInicial=(System.Now()-1).format('YYYY/MM/dd');
        String fechaFinal=System.Now().format('YYYY/MM/dd');
        IMP_IntegracionMateriales.getMateriales(fechaInicial.replace('/',''),fechaFinal.replace('/',''));
    }
}