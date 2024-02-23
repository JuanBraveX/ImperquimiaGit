public class IMP_UpdateParentPrices implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    public List<sObject> listPrices;
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, Name ,IMP_update__c, Sucursal__c, Lista_de_precios_SAP__c FROM Pricebook2 WHERE IsStandard=false AND IMP_update__c = false lIMIT 1');
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        this.listPrices=scope;
        
        for(sobject s : scope){
            String idP =(String) s.get('Id'); 
            IMP_PriceManager.getPrice(idP);
        }
    }
            
    public void finish(Database.BatchableContext BC){
        if(this.listPrices != null){
            Database.executeBatch(new IMP_UpdateParentPrices());
        }
    }
}