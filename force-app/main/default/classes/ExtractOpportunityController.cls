public class ExtractOpportunityController {
	
	public List<OpportunityLineItem> ListOpportunityProducts { get; set; }
	
	public ExtractOpportunityController(ApexPages.StandardController controller)
	{
		this.controller = controller;
		
		ListOpportunityProducts = new List<OpportunityLineItem>();
		
		ListOpportunityProducts = [Select Product_Model_Code_Hidden__c, Product_Brand_Hidden__c, Product_Derivative_Hidden__c, Quantity from OpportunityLineItem where OpportunityId = :ApexPages.currentPage().getParameters().get('id')];
		
	}
	
	private final ApexPages.StandardController controller;
}