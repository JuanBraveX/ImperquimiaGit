public class BatchUpsertDiscounts implements Database.Batchable<Descuento__c>,Database.AllowsCallouts{

    private List<Descuento__c>  listDicounts;
   
    
    public BatchUpsertDiscounts(List<Descuento__c>  listDicounts){
        this.listDicounts=listDicounts;
    }
    
    public Iterable<Descuento__c> start(Database.BatchableContext BC){
        System.debug('Descuentos entrantes BatchUpsertDiscounts :: '+this.listDicounts.size());
        
        return this.listDicounts;
    }
    
    public void execute(Database.BatchableContext BC, List<Descuento__c> scope){
        List<Database.UpsertResult> results = Database.upsert(scope,Descuento__c.IMP_IdExterno__c , FALSE);
        for(Database.UpsertResult itemResult : results){
            if(!itemResult.isSuccess()){
                system.debug(itemResult.getErrors());
            }
        }
        System.debug('Registros modificados : BatchUpsertDiscounts '+results.size());
        
    }
    
    public void finish(Database.BatchableContext BC){
      
    }      
    
}