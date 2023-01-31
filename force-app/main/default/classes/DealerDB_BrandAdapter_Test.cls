@isTest
public class DealerDB_BrandAdapter_Test {
    static testMethod void GetSFValue_ReturnsEmptyString_GivenInvalidString() {
        string input = 'test';

        string result = DealerDB_BrandAdapter.GetSFValue(input);

        System.assertEquals('', result);
    }

    static testMethod void GetSFValue_ReturnsJaguar_GivenJ() {
        string input = 'J';
        string salesforceValue = 'Jaguar';
        
        DealerDBToSF_Brand__c setting = new DealerDBToSF_Brand__c(Name=input, SF_Value__c=salesforceValue);
        insert setting;
        
        string result = DealerDB_BrandAdapter.GetSFValue(input);

        System.assertEquals(salesforceValue, result);
    }
}