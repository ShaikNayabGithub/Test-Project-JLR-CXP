@isTest
public class DMSAdapter_AccountRecordType_India_Test {
	static testMethod void GetIndiaValue_ReturnsCorporate_GivenSettingHasNoValues() {
        string result = DMSAdapter_AccountRecordType_India.GetIndiaValue('doesNotExist');

        System.assertEquals('Corporate', result);
    }

	static testMethod void GetIndiaValue_ReturnsCorporate_GivenInvalidValueAndSettingHasValues() {
        string name = 'test';
        String dmsValue ='testValue';

        SFAccountTypeToDMSPicklistMapping_India__c customSetting = new SFAccountTypeToDMSPicklistMapping_India__c(Name=name,DMS_Value__c=dmsValue);
        insert customSetting;
        
        string result = DMSAdapter_AccountRecordType_India.GetIndiaValue('doesNotExist');

        System.assertEquals('Corporate', result);
    }

    static testMethod void GetIndiaValue_ReturnsPersonal_GivenIndividual() {
    	string name = 'Individual';
        String dmsValue ='Personal';

        SFAccountTypeToDMSPicklistMapping_India__c customSetting = new SFAccountTypeToDMSPicklistMapping_India__c(Name=name,DMS_Value__c=dmsValue);
        insert customSetting;
        
        string result = DMSAdapter_AccountRecordType_India.GetIndiaValue(name);

        System.assertEquals(dmsValue, result);
    }
}