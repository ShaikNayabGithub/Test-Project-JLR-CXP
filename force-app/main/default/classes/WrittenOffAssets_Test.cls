@isTest
public class WrittenOffAssets_Test {
    public static testmethod void testAccountChanged() {
        
        List<Account> listOfAccounts = new List<Account>();
        
        Account testAccount1 = TestClass_AccountCreator.BuildRetailer();
        testAccount1.Country_ISO_Code__c = 'JP';
        insert testAccount1;
        
        Account testAccount2 = TestClass_AccountCreator.BuildRetailer();
        testAccount2.Country_ISO_Code__c = 'BR';
        insert testAccount2;
        
        //Account pcAccount = TestClass_AccountCreator.CreatePersonAccount();
        //Account testAccount3 = [Select id from Account where personemail = 'test@test.com'];
        Account testAccount3 = TestClass_AccountCreator.CreatePersonAccount();
        testAccount3.Country_ISO_Code__pc = 'IN';
        update testAccount3;
        
        //Written Off Vehicle Accounts
        Account japanAccount = TestClass_AccountCreator.BuildRetailer();
        japanAccount.Name = 'Japan Written Off Vehicles';
        japanAccount.Country_ISO_Code__c = 'JP';
        
        Account indiaAccount = TestClass_AccountCreator.BuildRetailer();
        indiaAccount.Name = 'India Written Off Vehicles';
        indiaAccount.Country_ISO_Code__c = 'IN';
        
        Account brazilAccount = TestClass_AccountCreator.BuildRetailer();
        brazilAccount.Name = 'Brazil Written Off Vehicles';
        brazilAccount.Country_ISO_Code__c = 'BR';

        listOfAccounts.add(japanAccount);
        listOfAccounts.add(indiaAccount);
        listOfAccounts.add(brazilAccount);
        insert listOfAccounts;
        
        List<Asset> listOfAssets = new List<Asset>();
        //New Asset build
        Vehicle_Specification__c vehSpec = TestClass_VehicleSpecificationBuilder.BuildMake();
        Asset newAsset1 = new Asset();
        newAsset1.Name = 'Test Asset';
        newAsset1.AccountId = testAccount1.Id;
        newAsset1.Brand__c = vehSpec.Id;
        newAsset1.Status = 'Owned';
        //insert newAsset1;
        listOfAssets.add(newAsset1);
        
        //newAsset1.Status = 'Written Off';
        //update newAsset1;
        
        Asset newAsset2 = new Asset();
        newAsset2.Name = 'Test Asset 2';
        newAsset2.AccountId = testAccount2.Id;
        newAsset2.Brand__c = vehSpec.Id;
        newAsset2.Status = 'Owned';
        //insert newAsset2;
        listOfAssets.add(newAsset2);
        
        //newAsset2.Status = 'Written Off';
        //update newAsset2;
        
        Asset newAsset3 = new Asset();
        newAsset3.Name = 'Test Asset 3';
        newAsset3.AccountId = testAccount3.Id;
        newAsset3.Brand__c = vehSpec.Id;
        newAsset3.Status = 'Owned';
        //insert newAsset3;
        listOfAssets.add(newAsset3);
        
        //newAsset3.Status = 'Written Off';
        //update newAsset3;
        
        insert listOfAssets;
        
        for(Asset a : listOfAssets){
            a.Status = 'Written Off';
        }
        update listOfAssets;
        
        test.startTest();
        Asset assetStatus = [Select accountId from Asset where id =:newAsset3.Id];
        system.assertEquals(indiaAccount.Id, assetStatus.AccountId);
        test.stopTest(); 
        
    }
}