@isTest
public class LC_OpportunityExtract_Test {

    @isTest
    static void Controller_ReturnsNullList_WhenOpportunityHasNoProducts() {
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        List<OpportunityLineItem> res = LC_OpportunityExtract_Controller.getLineItems(opp.Id);
        System.assertEquals(null, res);
    }
    
    @isTest
    static void Controller_ReturnsListWithOneItem_WhenOpportunityHasOneProduct() {
        OpportunityLineItem oli = TestClass_OppLineItemCreator.CreateOppLineItem();
        insert oli;
        List<OpportunityLineItem> res = LC_OpportunityExtract_Controller.getLineItems(oli.OpportunityId);
        System.assertEquals(1, res.size());
    }
    
}