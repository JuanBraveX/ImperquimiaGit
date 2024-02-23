global  inherited sharing  class IMP_BatchDescuentos implements Database.Batchable<Descuento__c>,Database.AllowsCallouts{
    private List<Descuento__c>  listDicounts;
    
    
    public IMP_BatchDescuentos(List<Descuento__c>  listDicounts){
        this.listDicounts=listDicounts;
    }
    
    public Iterable<Descuento__c> start(Database.BatchableContext BC){
        System.debug('Descuentos entrantes  IMP_BatchDescuentos :: '+this.listDicounts.size());
        return this.listDicounts;
    }
    
    public void execute(Database.BatchableContext BC, List<Descuento__c> scope){
        List<Database.SaveResult> resultUpdate = Database.update(scope, FALSE);
        for(Database.SaveResult itemResult :resultUpdate ){
            if(!itemResult.isSuccess()){
                system.debug(itemResult.getErrors());
            }
        }
        System.debug('Registros modificados : BatchUpsertDiscounts '+resultUpdate.size());
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }      
    
}