@isTest
public class CaseAssetRoleSetter_Test{
    
    static testmethod void SetOwner_NewCase_UpdatesAssetOwner(){
    	Account personAccount = TestClass_AccountCreator.CreatePersonAccount(); //TestClass_AccountCreator saves Account
    	personAccount = [SELECT PersonContactId FROM Account WHERE Id = :personAccount.Id];
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(); //TestClass_AssetBuilder creates and saves Account
        insert vehicle;
		Case assetCase = new Case(Status='Open', Origin='In Person');
		assetCase.AssetId = vehicle.Id;
		assetCase.ContactId = personAccount.PersonContactId;
		assetCase.Vehicle_Relationship__c = 'Owner';
		insert assetCase;
		vehicle = [SELECT AccountId FROM Asset WHERE Id = :vehicle.Id];
		System.assertEquals(personAccount.Id, vehicle.AccountId);
    }
    
    static testmethod void SetDriver_NewCase_CreatesNewDriverAssetRole(){
    	Account personAccount = TestClass_AccountCreator.CreatePersonAccount(); //TestClass_AccountCreator saves Account
    	personAccount = [SELECT PersonContactId FROM Account WHERE Id = :personAccount.Id];
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(); //TestClass_AssetBuilder creates and saves Account
        insert vehicle;
		Case assetCase = new Case(Status='Open', Origin='In Person');
		assetCase.AssetId = vehicle.Id;
		assetCase.ContactId = personAccount.PersonContactId;
		assetCase.Vehicle_Relationship__c = 'Driver';
		insert assetCase;
		List<Role__c> assetRoles = [SELECT Id, Contact__c FROM Role__c WHERE Vehicle__c = :vehicle.Id AND Role__c = 'Current Driver'];
		System.assertEquals(1, assetRoles.size());
		System.assertEquals(personAccount.PersonContactId, assetRoles[0].Contact__c);
    }
    
    static testmethod void SetKeeper_NewCase_CreatesNewKeeperAssetRole(){
    	Account personAccount = TestClass_AccountCreator.CreatePersonAccount(); //TestClass_AccountCreator saves Account
    	personAccount = [SELECT PersonContactId FROM Account WHERE Id = :personAccount.Id];
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(); //TestClass_AssetBuilder creates and saves Account
        insert vehicle;
		Case assetCase = new Case(Status='Open', Origin='In Person');
		assetCase.AssetId = vehicle.Id;
		assetCase.ContactId = personAccount.PersonContactId;
		assetCase.Vehicle_Relationship__c = 'Registered Keeper';
		insert assetCase;
		List<Role__c> assetRoles = [SELECT Id, Contact__c FROM Role__c WHERE Vehicle__c = :vehicle.Id AND Role__c = 'Current Registered Keeper'];
		System.assertEquals(1, assetRoles.size());
		System.assertEquals(personAccount.PersonContactId, assetRoles[0].Contact__c);
    }
    
}