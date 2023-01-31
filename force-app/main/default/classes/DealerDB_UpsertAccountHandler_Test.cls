@isTest
public class DealerDB_UpsertAccountHandler_Test {
    static testMethod void UpsertAccount_Inserts1Accounts_GivenNewAccount() {
        DealerDB_UpsertAccountHandler handler = CreateHandler();
        DealerDBService.RetailerAccount account = BuildValidAccount();
        
        aop_NationalityToISOCode__c countrySetting = new aop_NationalityToISOCode__c(Name='India',aop_ISO_Code__c=account.ISOCode,aop_Region_or_Market__c=account.ISOCode,aop_Checkfront_Instance__c='www.google.com');
    	insert countrySetting;

        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            handler.UpsertAccount(account);
            Test.StopTest();
        }

        integer totalRecordCount = [Select Count() From Account];

        System.assertEquals(1, totalRecordCount);
    }

    static testMethod void UpsertAccount_InsertsNoAccounts_GivenExistingAccountWithNoParent() {
        DealerDB_UpsertAccountHandler handler = CreateHandler();
        DealerDBService.RetailerAccount account = BuildValidAccount();
        
        aop_NationalityToISOCode__c countrySetting = new aop_NationalityToISOCode__c(Name='India',aop_ISO_Code__c=account.ISOCode,aop_Region_or_Market__c=account.ISOCode,aop_Checkfront_Instance__c='www.google.com');
    	insert countrySetting;
    	
        insert account.ToSFAccount();

        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            handler.UpsertAccount(account);
            Test.StopTest();
        }

        integer totalRecordCount = [Select Count() From Account];

        System.assertEquals(1, totalRecordCount);
    }


    private static DealerDB_UpsertAccountHandler CreateHandler()
    {
        DummyRule validationRule = new DummyRule();
        RetailAccountIdResolver retailAccountIdResolver = new RetailAccountIdResolver();
        return new DealerDB_UpsertAccountHandler(validationRule, retailAccountIdResolver);
    }

    private static DealerDBService.RetailerAccount BuildValidAccount()
    {
        DealerDBService.RetailerAccount account = new DealerDBService.RetailerAccount();

        account.Dealer_CI_Code = '10000';
        account.Brand = 'J';
        account.ISOCode = 'IN';
        account.Distribution_Code = 'J0586';
        account.Name = 'test';

        return account;
    }

    private class DummyRule implements DealerDb_AccountValidationRule_I{
        public void Validate(DealerDBService.RetailerAccount retailerAccount){}
    }
}