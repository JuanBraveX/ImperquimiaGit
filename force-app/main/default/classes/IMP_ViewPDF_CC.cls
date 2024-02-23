public without sharing class IMP_ViewPDF_CC {
    public IMP_ViewPDF_CC() {

    }
    @AuraEnabled
    public static String getObjectTypeName(String objectId) {
        String objectName;
        
        try {
            Id idobjecto = (Id)objectId;
            objectName = idobjecto.getSObjectType().getDescribe().getName();
        } catch (Exception e) {
            objectName = '';
        }
        
        return objectName;
    }

    @AuraEnabled
    public static String getPDF(String idRecord, String tipoObjeto){
        blob file;
        String contentDocumentId = '';
        
        try {
           

            if(tipoObjeto == 'Quote'){

                PageReference pref = page.IMP_CotizacionPDF;
                pref.getParameters().put('id',idRecord);
                pref.setRedirect(true);
                
                if (Test.IsRunningTest()) {
                    file = Blob.valueOf('UNIT.TEST');
                }
                else {
                    file = pref.getContentAsPDF();
                }
            
                Quote quoteInfo = [SELECT ID, Name, QuoteNumber FROM Quote WHERE ID=: idRecord];
                // Create a new ContentVersion object
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title =  ' PDF Presupuesto ' + quoteInfo.Name;
                contentVersion.VersionData = file;
                contentVersion.PathOnClient = 'PDFPresupuesto_' + quoteInfo.Name + '_' + quoteInfo.QuoteNumber  + '.pdf';
                
                // Insert the ContentVersion object to create a new ContentDocument
                INSERT contentVersion;

                contentDocumentId = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = : contentVersion.Id].Id;
            }
            else  if(tipoObjeto == 'Order'){

                PageReference pref = page.IMP_PedidoPDF;
                pref.getParameters().put('id',idRecord);
                pref.setRedirect(true);
                
                if (Test.IsRunningTest()) {
                    file = Blob.valueOf('UNIT.TEST');
                }
                else {
                    file = pref.getContentAsPDF();
                }

                Order pedido = [SELECT ID, OrderNumber FROM Order WHERE ID=: idRecord];

                // Create a new ContentVersion object
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title =  ' PDF Pedido ' + pedido.OrderNumber;
                contentVersion.VersionData = file;
                contentVersion.PathOnClient = 'PDFPedido_' + pedido.OrderNumber + '_' + pedido.OrderNumber  + '.pdf';
                
                // Insert the ContentVersion object to create a new ContentDocument
                INSERT contentVersion;

                contentDocumentId = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = : contentVersion.Id].Id;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return contentDocumentId;
    }
}