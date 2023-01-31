@isTest
public class DealerDBService_Test {
    static testMethod void UpsertAccount_ReturnsErrorCode30001_GivenEmptyAccount() {
        DealerDBService.RetailerAccount account = new DealerDBService.RetailerAccount();

        DealerDBService.Response result = DealerDBService.UpsertAccount(account);

        System.assertEquals(30001, result.ErrorCode);
    }

    static testMethod void UpsertAccount_ReturnsSuccess_GivenValidAccount() {
        DealerDBService.RetailerAccount account = new DealerDBService.RetailerAccount();
        account.Dealer_CI_Code = '10000';
        account.Brand = 'J';
        account.ISOCode = 'IN';
        account.Distribution_Code = 'J0586';
        account.Name = 'test';
        account.Retailer_Type = 'test';
        account.Trading_Name = 'test';
        account.Trading_Partner_Type = 'test';
        
        DealerDBService.Response result;
        
        Profile profile = [Select Id From Profile Where Name='DealerDB Integration'];
        User testUser = TestClass_UserCreator.CreateUser(profile);
        
        System.runAs(testUser){	
	        aop_NationalityToISOCode__c countrySetting = new aop_NationalityToISOCode__c(Name='India',aop_ISO_Code__c=account.ISOCode,aop_Region_or_Market__c=account.ISOCode,aop_Checkfront_Instance__c='www.google.com');
	    	insert countrySetting;
    	
            Test.startTest();
            result = DealerDBService.UpsertAccount(account);
            Test.StopTest();
        }

        System.assert(result.IsSuccess);
    }
}