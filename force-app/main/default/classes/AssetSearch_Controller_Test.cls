@IsTest
public class AssetSearch_Controller_Test {
    
    @isTest
    public static void testAssetSearchReturnsNull(){
        Asset asNew = AssetSearch_Controller.searchForIds('aa');
        system.assert(asNew == null);
        
        
    }
    
    @isTest
    public static void testAssetSearchDoesNotReturnsNull(){
        
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle(false); //TestClass_AssetBuilder creates and saves Account        
        vehicle.Vin__c = 'aa';
        Asset toUse = [SELECT AccountId FROM Asset where Id = :vehicle.id];
        Account acc = new Account();
        acc.id = toUse.AccountId;
        acc.Country_Iso_code__c = 'AU';
        update acc;
        
        update vehicle;       
        System.debug('Vehicle '+vehicle);
        Asset asNew = AssetSearch_Controller.searchForIds('aa');
        
         system.assert(asNew != null);
        
    }
    
    @isTest
    public static void testtransferAsset(){
        
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle(false); //TestClass_AssetBuilder creates and saves Account
        
        vehicle.Vin__c = 'aa';
        update vehicle;
        
        
        AssetSearch_Controller.transferAsset(vehicle.Id);
        
        
        
    }
    
}