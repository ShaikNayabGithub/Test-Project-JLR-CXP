@IsTest
public class NewOppController_Test {
	
	
	@IsTest 
	static void Test_PageReferenceIsReturned() {
		NewOppController controller = new NewOppController(new ApexPages.StandardController(new Opportunity()));
		PageReference pageRef = controller.createNewOpp();
		System.Assert(pageRef != null);
		System.AssertEquals(pageRef.getParameters().get('nooverride'), '1');
	}
	
	@IsTest 
	static void Test_PageReferenceIsReturned_WhenAccIdDefined() {
		ApexPages.currentPage().getParameters().put('accid', 'Test');
		NewOppController controller = new NewOppController(new ApexPages.StandardController(new Opportunity()));
		PageReference pageRef = controller.createNewOpp();
		System.Assert(pageRef != null);
		System.AssertEquals(pageRef.getParameters().get('nooverride'), '1');
	}
}