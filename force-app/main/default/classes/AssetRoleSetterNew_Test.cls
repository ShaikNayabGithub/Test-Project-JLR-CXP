@isTest
public class AssetRoleSetterNew_Test{
    
    @IsTest
    static void SetOwner_NewAssetRetailerOwner_CreatesNoCurrentOwnerAssetRole(){
        Test.startTest();
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle(false); //TestClass_AssetBuilder creates and saves Account
        List<Role__c> assetRoles = [SELECT Id, Account__c FROM Role__c WHERE Vehicle__c = :vehicle.Id AND Role__c = 'Current Owner'];
        System.assertEquals(0, assetRoles.size());
        Test.stopTest();
    }
    
    @IsTest
    static void SetOwner_NewAssetNonRetailerOwner_CreatesOneCurrentOwnerAssetRole(){
        Test.startTest();
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle(true); //TestClass_AssetBuilder creates and saves Account
        List<Role__c> assetRoles = [SELECT Id, Account__c FROM Role__c WHERE Vehicle__c = :vehicle.Id AND Role__c = 'Current Owner'];
        System.assertEquals(1, assetRoles.size());
        System.assertEquals(vehicle.AccountId, assetRoles[0].Account__c);
        Test.stopTest();
    }
    
    @IsTest
    static void SetOwner_EditedAssetOwner_CreatesCurrentOwnerAssetRoleTrue(){
        Account personAccount = TestClass_AccountCreator.createPersonAccount(); //TestClass_AccountCreator saves Account
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle(true); //TestClass_AssetBuilder creates and saves Account
        //update the vehicle, setting a new AccountId
        vehicle.AccountId = personAccount.Id;
        List<Role__c> assetRoles;
        //force trigger to rerun
        Test.startTest();
        AssetHandler.CreateNewAssetRoleRun = false;
   
        update vehicle;
        assetRoles = [SELECT Id, Role__c FROM Role__c WHERE Vehicle__c = :vehicle.Id AND Account__c = :personAccount.Id];
        System.assertEquals(1, assetRoles.size());
        System.assertEquals('Current Owner', assetRoles[0].Role__c);
        Test.stopTest();
    }

}