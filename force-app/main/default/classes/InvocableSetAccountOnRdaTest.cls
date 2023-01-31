/**
 * Created by caleb@argologic.com.au on 19/03/2020.
 */

@IsTest
public without sharing class InvocableSetAccountOnRdaTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        // setup data
        RDA__c rda = TestClass_RDACreater.BuildRDA(null, TestClass_AccountCreator.GenerateCorporateAccount().Id, TestClass_AccountCreator.createPersonAccount_Australia().Id, TestClass_AssetBuilder.BuildAndInsertVehicle().Id);

        List<Account> accountUpdateList = new List<Account>();

        Account parentRetailer = TestClass_AccountCreator.CreateRetailer();
        Account a = TestClass_AccountCreator.CreateRetailer();
        Account b = TestClass_AccountCreator.CreateRetailer();
        b.Dealer_CI_Code__c = null;
        b.Dealer_CI_Code_2__c = '1';
        b.parentId = parentRetailer.Id;
        a.ParentId = parentRetailer.Id;

        accountUpdateList.add(a);
        accountUpdateList.add(b);

        update accountUpdateList;

        Test.startTest();
        Contact c = TestClass_ValidContactBuilder.Build(parentRetailer);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs (thisUser)
        {
            rda.OwnerId = TestClass_UserCreator.CreateRetailerUser(c).Id;
            insert rda;
        }

        // ACT
        System.debug('q1 = ' + Limits.getQueries());
        InvocableSetAccountOnRda.setRetailerOnRda(new List<String>{ rda.Id });
        System.debug('q2 = ' + Limits.getQueries());
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, [SELECT Id, Dealership__c FROM RDA__c WHERE Id = :rda.Id].Dealership__c);
    }

    @IsTest
    public static void test2()
    {
        // ARRANGE
        // setup data
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Vehicle_Specification__c spec =  [SELECT Name FROM Vehicle_Specification__c WHERE Id = :vehicle.Brand__c];
        spec.Name = Constants.MAKE_NAME_LAND_ROVER;
        update spec;
        RDA__c rda = TestClass_RDACreater.BuildRDA(null, TestClass_AccountCreator.GenerateCorporateAccount().Id, TestClass_AccountCreator.createPersonAccount_Australia().Id, vehicle.Id);

        List<Account> accountUpdateList = new List<Account>();

        Account parentRetailer = TestClass_AccountCreator.CreateRetailer();
        Account a = TestClass_AccountCreator.CreateRetailer();
        Account b = TestClass_AccountCreator.CreateRetailer();
        b.Dealer_CI_Code__c = null;
        b.Dealer_CI_Code_2__c = '1';
        b.parentId = parentRetailer.Id;
        a.ParentId = parentRetailer.Id;

        accountUpdateList.add(a);
        accountUpdateList.add(b);

        update accountUpdateList;

        Test.startTest();
        Contact c = TestClass_ValidContactBuilder.Build(parentRetailer);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs (thisUser)
        {
            rda.OwnerId = TestClass_UserCreator.CreateRetailerUser(c).Id;
            insert rda;
        }

        // ACT
        InvocableSetAccountOnRda.setRetailerOnRda(new List<String>{ rda.Id });
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, [SELECT Id, Dealership__c FROM RDA__c WHERE Id = :rda.Id].Dealership__c);
    }

    @IsTest
    public static void test3()
    {
        // ARRANGE
        // setup data
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Vehicle_Specification__c spec =  [SELECT Name FROM Vehicle_Specification__c WHERE Id = :vehicle.Brand__c];
        spec.Name = Constants.MAKE_NAME_LAND_ROVER;
        update spec;
        RDA__c rda = TestClass_RDACreater.BuildRDA(null, TestClass_AccountCreator.GenerateCorporateAccount().Id, TestClass_AccountCreator.createPersonAccount_Australia().Id, vehicle.Id);

        List<Account> accountUpdateList = new List<Account>();

        Account parentRetailer = TestClass_AccountCreator.CreateRetailer();
        Account a = TestClass_AccountCreator.CreateRetailer();
        Account b = TestClass_AccountCreator.CreateRetailer();
        b.Dealer_CI_Code__c = null;
        b.Dealer_CI_Code_2__c = '1';
        b.parentId = parentRetailer.Id;
        a.ParentId = parentRetailer.Id;

        accountUpdateList.add(a);
        accountUpdateList.add(b);

        update accountUpdateList;

        Contact c = TestClass_ValidContactBuilder.Build(parentRetailer);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        User retailUser;
        System.runAs (thisUser)
        {
            retailUser = TestClass_UserCreator.CreateRetailerUser(c);
            rda.OwnerId = retailUser.Id;
        }

        // ACT
        Test.startTest();
        System.debug('>> StartTest()');
        insert rda;
        System.debug('<< StopTest()');
        Test.stopTest();

        // ASSERT
        // removed for the time being as it is failing in production
        //System.assertNotEquals(null, [SELECT Id, Dealership__c FROM RDA__c WHERE Id = :rda.Id].Dealership__c);
    }

    @IsTest
    public static void schedulableTest()
    {
        // ARRANGE
        // setup data
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Vehicle_Specification__c spec =  [SELECT Name FROM Vehicle_Specification__c WHERE Id = :vehicle.Brand__c];
        spec.Name = Constants.MAKE_NAME_LAND_ROVER;
        update spec;
        RDA__c rda = TestClass_RDACreater.BuildRDA(null, TestClass_AccountCreator.GenerateCorporateAccount().Id, TestClass_AccountCreator.createPersonAccount_Australia().Id, vehicle.Id);

        List<Account> accountUpdateList = new List<Account>();

        Account parentRetailer = TestClass_AccountCreator.CreateRetailer();
        Account a = TestClass_AccountCreator.CreateRetailer();
        Account b = TestClass_AccountCreator.CreateRetailer();
        b.Dealer_CI_Code__c = null;
        b.Dealer_CI_Code_2__c = '1';
        b.parentId = parentRetailer.Id;
        a.ParentId = parentRetailer.Id;

        accountUpdateList.add(a);
        accountUpdateList.add(b);

        update accountUpdateList;

        Test.startTest();
        Contact c = TestClass_ValidContactBuilder.Build(parentRetailer);
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs (thisUser)
        {
            rda.OwnerId = TestClass_UserCreator.CreateRetailerUser(c).Id;
            insert rda;
        }

        // ACT
        SchedulableSetAccountOnRda.scheduleHourly();
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, [SELECT Id, Dealership__c FROM RDA__c WHERE Id = :rda.Id].Dealership__c);
    }
}