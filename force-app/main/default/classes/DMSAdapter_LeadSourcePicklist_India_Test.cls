@isTest
public class DMSAdapter_LeadSourcePicklist_India_Test {
	static testMethod void GetIndiaValue_ReturnsEmptyString_GivenSettingHasNoValues() {
        string result = DMSAdapter_LeadSourcePicklist_India.GetIndiaValue('doesNotExist');

        System.assertEquals('', result);
    }

	static testMethod void GetIndiaValue_ReturnsEmptyString_GivenInvalidValueAndSettingHasValues() {
        string name = 'test';
        String dmsValue ='testValue';

        SFLeadChannelToDMSPicklistMapping_India__c customSetting = new SFLeadChannelToDMSPicklistMapping_India__c(Name=name,DMS_Value__c=dmsValue);
        insert customSetting;
        string result = DMSAdapter_LeadSourcePicklist_India.GetIndiaValue('doesNotExist');

        System.assertEquals('', result);
    }

    static testMethod void GetIndiaValue_ReturnsEvent_GivenOEMExperience() {
    	string name = 'OEM Experience';
        String dmsValue ='Event';

        SFLeadChannelToDMSPicklistMapping_India__c customSetting = new SFLeadChannelToDMSPicklistMapping_India__c(Name=name,DMS_Value__c=dmsValue);
        insert customSetting;
        string result = DMSAdapter_LeadSourcePicklist_India.GetIndiaValue(name);

        System.assertEquals(dmsValue, result);
    }
}