@IsTest
public class ExtractOpportunityController_Test {
	
	@IsTest
	static void Test_ListIsEmptyWhenNoProductsDefined() {
		ApexPages.currentPage().getParameters().put('id', 'Test');
		ExtractOpportunityController controller = new ExtractOpportunityController(new ApexPages.StandardController(new Opportunity()));
		System.AssertEquals(controller.ListOpportunityProducts.size(), 0);
	} 
}