/*************************************************************** 
Name: Trigger Account
Copyright © 2021 Salesforce
======================================================
Purpose:
Class trigger Account.
======================================================
History:
Modification
VERSION  AUTHOR           DATE          DETAIL     Description
3.0      rotrejo@ts4.mx    20/04/2022    INITIAL     DEV CSR: 
***************************************************************/
trigger IMP_AccountTrigger on Account(
  after insert,
  before update,
  before insert
) {
  if (Trigger.isBefore && Trigger.isUpdate) {
    Map<Id, Account> mapOldValues = new Map<Id, Account>(Trigger.old);
    for (Account acc : Trigger.new) {
      if (
        acc.Credito_SAP__c != mapOldValues.get(acc.Id).Credito_SAP__c &&
        acc.Credito_SAP__c
      ) {
        IMP_ConsultaCredito.updateCredito(
          acc.id_de_sap__c,
          acc.LineaCredito__c
        );
        if (IMP_ConsultaCredito.hasError) {
          acc.addError('Error al actualizar el crédito.');
        }
      }
    }
  }
}
