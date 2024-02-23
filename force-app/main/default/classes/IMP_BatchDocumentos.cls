public inherited sharing class IMP_BatchDocumentos implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    private List<sObject>  listFacts;
    
    public IMP_BatchDocumentos( List<sObject>  listFacts){
        this.listFacts=listFacts;
    }
    
    public Iterable<sObject> start(Database.BatchableContext BC){
        return this.listFacts;
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug(scope.size());
        if(scope.size()>0){
            List<Database.UpsertResult> results =  Database.upsert(scope,Factura__c.IMP_LlaveExclusiva__c , FALSE);
            for(Database.UpsertResult itemResult : results){
                if(itemResult.isSuccess()){
                    System.debug(itemResult.id+' - Registro Creado');
                }else{
                    System.debug(itemResult.getId() +' - Error: '+itemResult.getErrors());
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
}