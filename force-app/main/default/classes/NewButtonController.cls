public with sharing class NewButtonController
{
	public NewButtonController(ApexPages.StandardController controller)
	{
		this.controller = controller;
	}
	
	public PageReference redirectToSearchPage() {
		
			String parentAccount = ApexPages.currentPage().getParameters().get(System.Label.Account_Field_ID_Lead);
			String parentAccountId = ApexPages.currentPage().getParameters().get(System.Label.Lead_Account_ID_Field_ID);
			String recordType = ApexPages.currentPage().getParameters().get('RecordType');
			if (!String.isEmpty(parentAccount)) {
				List<RecordType> recordNames = [select Name from RecordType where Id = :recordType and SobjectType = 'Lead' limit 1];
		    	if(recordNames.isEmpty())
		    	{
		    		recordType = '';
		    	}
		        PageReference pageRef = new PageReference('/00Q/e?retURL=%2F00Q%2Fo' + '&RecordType='+recordType + '&'+System.Label.Account_Field_ID_Lead+'='+parentAccount + '&'+System.Label.Lead_Account_ID_Field_ID+'='+parentAccountId);
		        pageRef.getParameters().put('nooverride','1');
		        return pageRef;
			}
			PageReference pageRef = Page.searchFirst;
			pageRef.setRedirect(true);
			pageRef.getParameters().put('recordType',recordType);
        	return pageRef;
		} 
    
    private final ApexPages.StandardController controller;
}