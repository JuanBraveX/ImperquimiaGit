trigger IMP_Factura on Factura__c (After insert,After update) {
    List<Factura__c> newFacts;
    switch on trigger.operationType{
        when AFTER_UPDATE {
            newFacts = new  List<Factura__c>();
            for(Factura__c factura : trigger.new){
                if(factura.IMP_MontoFactura__c != trigger.oldMap.get(factura.Id).IMP_MontoFactura__c){
                    newFacts.add(factura);
                }
            }
            if(newFacts.size() >0){
                IMP_HandleFacturas.getMontos(newFacts);
            }
        }
        when AFTER_INSERT{
            IMP_HandleFacturas.getMontos(trigger.new);
        }         
     
    }
}