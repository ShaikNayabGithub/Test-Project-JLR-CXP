public class DMSAdapter_CustomerTypePicklist_India {
    public static string GetIndiaValue(string salesforceValue)
    {
    	SFCustomerTypeToDMSPicklistMapping_India__c customSetting = SFCustomerTypeToDMSPicklistMapping_India__c.getInstance(salesforceValue);
    	if(customSetting == null){ return 'Other'; }
    	return customSetting.DMS_Value__c;
    }
}