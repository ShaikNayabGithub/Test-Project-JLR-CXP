public class DealerDB_BrandAdapter {
	public static string GetSFValue(string dealerDbValue)
	{
		DealerDBToSF_Brand__c setting = DealerDBToSF_Brand__c.getInstance(dealerDbValue);
		if(setting == null) { return ''; }
		return setting.SF_Value__c;
	}
}