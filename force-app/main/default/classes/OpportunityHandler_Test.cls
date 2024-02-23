@isTest
public class OpportunityHandler_Test {
	@testSetup static void setup(){
        
        Account cuenta = new Account();
        cuenta.name = 'Cuenta Prueba';
        insert cuenta;
        
    }
    
    @isTest public static void insertOpp(){
        OpportunityHandler.createdOrder();
        List<Account> lstOpp = [SELECT Id FROM Account LIMIT 1];
        
    }
}