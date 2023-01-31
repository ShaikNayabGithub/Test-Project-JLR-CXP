public with sharing class NewOppController
{
	private PageReference pageRef;
	
	public NewOppController(ApexPages.StandardController controller)
	{
		this.controller = controller;
	}
	
	public PageReference createNewOpp() {
		
		String parentAccount = ApexPages.currentPage().getParameters().get('accid');
		if (!String.isEmpty(parentAccount)) {
	        pageRef = new PageReference('/006/e?retURL=%2F' + parentAccount + '&accid=' + parentAccount);
	        pageRef.getParameters().put('nooverride','1');
	        pageRef.setRedirect(true);
		}
		else {
			pageRef = new PageReference('/006/e?retURL=%2F006%2Fo');
			pageRef.getParameters().put('nooverride','1');
			pageRef.setRedirect(true);
		}
		
	    return pageRef; 
	} 
    
    private final ApexPages.StandardController controller;
}