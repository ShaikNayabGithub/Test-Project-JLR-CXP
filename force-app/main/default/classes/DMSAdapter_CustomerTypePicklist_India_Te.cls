@isTest
public class DMSAdapter_CustomerTypePicklist_India_Te {
	static testMethod void GetIndiaValue_ReturnsOther_GivenSettingHasNoValues() {
        string result = DMSAdapter_CustomerTypePicklist_India.GetIndiaValue('doesNotExist');

        System.assertEquals('Other', result);
    }

	static testMethod void GetIndiaValue_ReturnsOther_GivenInvalidValueAndSettingHasValues() {
        string name = 'test';
        String dmsValue ='testValue';

        SFCustomerTypeToDMSPicklistMapping_India__c customSetting = new SFCustomerTypeToDMSPicklistMapping_India__c(Name=name,DMS_Value__c=dmsValue);
        insert customSetting;
        
        string result = DMSAdapter_CustomerTypePicklist_India.GetIndiaValue('doesNotExist');

        System.assertEquals('Other', result);
    }

    static testMethod void GetIndiaValue_ReturnsRepeat_GivenCustomer() {
    	string name = 'Customer';
        String dmsValue ='Repeat';

        SFCustomerTypeToDMSPicklistMapping_India__c customSetting = new SFCustomerTypeToDMSPicklistMapping_India__c(Name=name,DMS_Value__c=dmsValue);
        insert customSetting;
        
        string result = DMSAdapter_CustomerTypePicklist_India.GetIndiaValue(name);

        System.assertEquals(dmsValue, result);
    }
}