public class DMSAdapter_OpportunityStage_India implements I_DMSAdapter_OpportunityStage{
    public string GetSalesforceValue(string dmsValue)
    {
    	DMSToSFOpportunityStage__c customSetting = DMSToSFOpportunityStage__c.getInstance(dmsValue);
    	if(customSetting == null){ return ''; }
    	return customSetting.SF_Value__c;
    }
}