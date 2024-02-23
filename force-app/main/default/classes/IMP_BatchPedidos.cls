public inherited sharing class IMP_BatchPedidos implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    private List<sObject>  listPedidos;
    
    
    public IMP_BatchPedidos( List<sObject> listPedidos){
        this.listPedidos=listPedidos;
    }
    
    public Iterable<sObject> start(Database.BatchableContext BC){
        return this.listPedidos;
    }
    
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){

        List<Database.UpsertResult> results = Database.upsert(scope,Order.pedido__c , False);
        for(Database.UpsertResult itemResult : results){
            if(itemResult.isSuccess()){
            }else If(itemResult.isCreated()){
                system.debug('Error en la creación ::'+itemResult.getErrors()+'-'+itemResult.getId());
            }else{
                system.debug('Error en la modificación ::'+itemResult.getErrors()+'-'+itemResult.getId());
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}