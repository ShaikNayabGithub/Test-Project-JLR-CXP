public class DMSAdapter_AccountRecordType_India {
    public static string GetIndiaValue(string salesforceValue)
    {
    	SFAccountTypeToDMSPicklistMapping_India__c customSetting = SFAccountTypeToDMSPicklistMapping_India__c.getInstance(salesforceValue);
    	if(customSetting == null){ return 'Corporate'; }
    	return customSetting.DMS_Value__c;
    }
}