@isTest
public class AssetPriceUpdaterTriggerHandler_Test { 

    public static testMethod void main() {
    
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
        ass.local_price__c = 0.00;
        insert ass;
        
        AssetPriceUpdater__c apu = new AssetPriceUpdater__c(Name=ass.name,localprice__c = 1.99);
        insert apu;
        
        ass = [select local_price__c from asset where name = : apu.name limit 1];
        
        system.assertEquals(ass.local_price__c,apu.localprice__c);
    
    }

}