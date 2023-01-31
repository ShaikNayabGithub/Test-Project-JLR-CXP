@isTest
public class DMSAdapter_OpportunityStage_India_Test {
	static testMethod void GetIndiaValue_ReturnsEmptyString_GivenSettingHasNoValues() {
		DMSAdapter_OpportunityStage_India adapter = new DMSAdapter_OpportunityStage_India();
        string result = adapter.GetSalesforceValue('doesNotExist');

        System.assertEquals('', result);
    }

	static testMethod void GetIndiaValue_ReturnsEmptyString_GivenInvalidValueAndSettingHasValues() {
        string name = 'test';
        String sfValue ='testValue';

        DMSToSFOpportunityStage__c customSetting = new DMSToSFOpportunityStage__c(Name=name,SF_Value__c=sfValue);
        insert customSetting;
        
        DMSAdapter_OpportunityStage_India adapter = new DMSAdapter_OpportunityStage_India();
        string result = adapter.GetSalesforceValue('doesNotExist');

        System.assertEquals('', result);
    }

    static testMethod void GetIndiaValue_ReturnsOrder_GivenAllotment() {
    	string name = 'Allotment';
        String sfValue ='Order';

        DMSToSFOpportunityStage__c customSetting = new DMSToSFOpportunityStage__c(Name=name,SF_Value__c=sfValue);
        insert customSetting;
        
        DMSAdapter_OpportunityStage_India adapter = new DMSAdapter_OpportunityStage_India();
        string result = adapter.GetSalesforceValue(name);

        System.assertEquals(sfValue, result);
    }
}