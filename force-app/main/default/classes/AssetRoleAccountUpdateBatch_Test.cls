@isTest(seeAllData=false)
public class AssetRoleAccountUpdateBatch_Test {
	@testSetup static void setup() {
		Account personAccount = TestClass_AccountCreator.createPersonAccount_Australia(); //TestClass_AccountCreator saves Account
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle(true); //TestClass_AssetBuilder creates and saves Account
        //update the vehicle, setting a new AccountId
        vehicle.AccountId = personAccount.Id;
        //force trigger to rerun
        AssetHandler.CreateNewAssetRoleRun = false;
        Test.startTest();
        update vehicle;    
        Test.stopTest();
    }
    
   	static testmethod void testBusinessAccounts() {
        Account businessAccount= TestClass_AccountCreator.GenerateCorporateAccountAustralia('Test Acc1');
        Asset vehicle =[select id, AccountId from Asset limit 1];
        vehicle.AccountId=businessAccount.Id;
        //force trigger to rerun
        AssetHandler.CreateNewAssetRoleRun = false;
        Role__C assetRole = New Role__c();
        assetRole.Account__c=businessAccount.Id;
        assetRole.Vehicle__c=vehicle.id;
        assetRole.Role__c='Previous Owner';
        Test.startTest();
        update vehicle; 
        Insert assetRole;
        database.executeBatch(new AssetRoleAccountUpdateBatch());
        Test.stopTest();
    }
    
    static testmethod void testPersonAccounts() {
        Account businessAccount= TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        Asset vehicle =[select id, AccountId from Asset limit 1];
        Role__C assetRole = New Role__c();
        assetRole.Account__c=vehicle.AccountId;
        assetRole.Vehicle__c=vehicle.id;
        assetRole.Role__c='Previous Owner';
        Test.startTest();
        Insert assetRole;
        database.executeBatch(new AssetRoleAccountUpdateBatch());
        Test.stopTest();
    }
}