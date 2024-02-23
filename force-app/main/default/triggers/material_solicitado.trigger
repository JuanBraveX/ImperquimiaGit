trigger material_solicitado on Productos__c (before insert,before update) {

if(trigger.isBefore && trigger.isInsert || trigger.isBefore && trigger.isUpdate){
        Set<Id> productoId = new Set<Id>();
        Set<Id> listaPreciosId = new Set<Id>();

        for(Productos__c material_solicitado : trigger.new){
            productoId.add(material_solicitado.Producto__c);
            listaPreciosId.add(material_solicitado.Lista_de_precios__c);
        }

        try{
            PricebookEntry entradaListaP = [SELECT Id,Pricebook2Id, Product2Id,UnitPrice FROM PricebookEntry
                                            WHERE Pricebook2Id IN:listaPreciosId AND Product2Id IN:productoId];
            
            for(Productos__c material_solicitado: trigger.new){
                material_solicitado.Costo__c =entradaListaP.UnitPrice; 
                
                
            }
        }catch(Exception e){
            for(Productos__c material_solicitado: trigger.new){
                material_solicitado.addError('No existe existe entrada de lista de precios relacionada.');          
            }
            
        }
        
    }
    
}