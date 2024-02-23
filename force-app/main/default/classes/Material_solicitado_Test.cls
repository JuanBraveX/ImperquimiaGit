@isTest
public without sharing class Material_solicitado_Test {

/******************************************************************* 
    Purpose: Inserts all information to run the class method.
    Information about changes (versions):
    ********************************************************************/    
    @testSetup static void setup(){
  
                        
        Product2 prod =new Product2();
        prod.Name = 'ELASTON ROJO 12L';
        prod.ProductCode='100028-I';
        prod.Family = 'Naya';
        prod.Description = '';
        prod.IsActive = true;
        prod.CurrencyIsoCode='MXN';
        prod.Grupo_de_Materiales__c ='03';            
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId(); 

        PricebookEntry pbeSt = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            IsActive = true,
            CurrencyIsoCode='MXN',
            UnitPrice = 1100,
            UseStandardPrice=false
        );
        
        insert pbeSt;
        
        Solicitud_de_pintura_rotulaci_n__c Solicitud_de_pintura_rotulaci_n = new Solicitud_de_pintura_rotulaci_n__c(
        Name = 'Solicitud distribuidor test4',
        Estatus__c ='Nuevo',
        Tipo_de_Solicitud__c ='Nuevo Distribuidor',
        Compra_Trimestral__c =160000
        );
        
        insert Solicitud_de_Pintura_Rotulaci_n;
            
        
        Productos__c material_solicitado = new productos__c (
        Name ='Producto Test 5',
        Lista_de_precios__c = pricebookId,
        Producto__c = prod.Id,
        Solicitud_de_pintura_Rotulaci_n__c  = solicitud_de_pintura_Rotulaci_n.Id
        );
        
        insert material_solicitado;
        
        
    }
/******************************************************************* 
Purpose: Test class method to consult the PricebookEntry in relation to the Product and Price list of the sample.
Parameters:PricebookEntry pricebook , Id cotizacion.
Returns: 
Throws :
Information about changes (versions)
********************************************************************/   
    @isTest public static void crearMaterialsolicitado(){
        Productos__c material_solicitado = [SELECT Id FROM Productos__c WHERE Name ='Producto Test 5'];
    }
    

}