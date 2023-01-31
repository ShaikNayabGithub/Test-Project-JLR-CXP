@isTest
public class DMSAdapter_GenderPicklist_India_Test {
	static testMethod void GetIndiaValue_ReturnsEmptyString_GivenSettingHasNoValues() {
        string result = DMSAdapter_GenderPicklist_India.GetIndiaValue('doesNotExist');

        System.assertEquals('', result);
    }

	static testMethod void GetIndiaValue_ReturnsEmptyString_GivenInvalidValueAndSettingHasValues() {
        string name = 'test';
        String dmsValue ='testValue';

        SFGenderToDMSPicklistMapping_India__c customSetting = new SFGenderToDMSPicklistMapping_India__c(Name=name,DMS_Value__c=dmsValue);
        insert customSetting;
        
        string result = DMSAdapter_GenderPicklist_India.GetIndiaValue('doesNotExist');

        System.assertEquals('', result);
    }

    static testMethod void GetIndiaValue_ReturnsM_GivenMale() {
    	string name = 'Male';
        String dmsValue ='M';

        SFGenderToDMSPicklistMapping_India__c customSetting = new SFGenderToDMSPicklistMapping_India__c(Name=name,DMS_Value__c=dmsValue);
        insert customSetting;
        
        string result = DMSAdapter_GenderPicklist_India.GetIndiaValue(name);

        System.assertEquals(dmsValue, result);
    }
}