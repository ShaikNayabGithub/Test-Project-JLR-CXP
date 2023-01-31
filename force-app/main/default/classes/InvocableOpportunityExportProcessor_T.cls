@IsTest
public class InvocableOpportunityExportProcessor_T
{
    @IsTest
	static void Test_processCallout()
    {
        // ARRANGE
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity();
        Test.setMock(HttpCalloutMock.class, new OpportunityExportToVitalMockImpl());

        // ACT
        Test.startTest();
        InvocableOpportunityExportProcessor.process(new List<Id>{ opp.Id });
        Test.stopTest();

        // ASSERT

    }
}