public class DescuentosQueable implements Queueable, Database.AllowsCallouts{
    
    public void execute(QueueableContext qc){
        IMP_DescuentosManager.upsertDiscounts();
        
    }
    public DescuentosQueable(){
    }
}