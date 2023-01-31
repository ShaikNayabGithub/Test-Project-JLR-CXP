public class DMSAdapter_GenderPicklist_India {
    public static string GetIndiaValue(string salesforceValue)
    {
    	SFGenderToDMSPicklistMapping_India__c customSetting = SFGenderToDMSPicklistMapping_India__c.getInstance(salesforceValue);
    	if(customSetting == null){ return ''; }
    	return customSetting.DMS_Value__c;
    }
}