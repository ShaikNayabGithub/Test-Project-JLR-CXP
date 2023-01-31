public class DMSAdapter_LeadSourcePicklist_India {
     public static string GetIndiaValue(string salesforceValue)
     {
    	SFLeadChannelToDMSPicklistMapping_India__c customSetting = SFLeadChannelToDMSPicklistMapping_India__c.getInstance(salesforceValue);
    	if(customSetting == null){ return ''; }
    	return customSetting.DMS_Value__c;
     }
}