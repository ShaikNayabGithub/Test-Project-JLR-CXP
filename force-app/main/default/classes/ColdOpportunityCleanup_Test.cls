@isTest
public class ColdOpportunityCleanup_Test {

    @isTest
    public static void BatchJob_SetsOpportunityToClosedLost_WhenLastModifiedDateLessThan90DaysAgoAndNoNextActivity() {
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        Test.startTest();
            //cant set LastModifiedDate on a created Opportunity, therefore amended code to retrieve all Opportunities with LastModifiedDate < 2 days time
            Database.executeBatch(new ColdOpportunityCleanup_Batchable(2), 1);
        Test.stopTest();
        opp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Retailer Lost', opp.StageName);
    }
    
    @isTest
    public static void BatchJob_DoesNotSetOpportunityToClosedLost_WhenLastModifiedDateLessThan90DaysAgoAndNextActivityInPast() {
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        String originalOppStage = opp.StageName;
        opp.Next_Activity_Date__c = Date.today().addDays(1);
        insert opp;
        Test.startTest();
            //cant set LastModifiedDate on a created Opportunity, therefore amended code to retrieve all Opportunities with LastModifiedDate < 2 days time
            Database.executeBatch(new ColdOpportunityCleanup_Batchable(2), 1);
        Test.stopTest();
        opp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(originalOppStage, opp.StageName);
    }
    
    @isTest
    public static void BatchJob_DoesNotSetOpportunityToClosedLost_WhenLastModifiedDateGreaterThan90DaysAgo() {
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        String originalOppStage = opp.StageName;
        insert opp;
        Test.startTest();
            //cant set LastModifiedDate on a created Opportunity, therefore amended code to retrieve all Opportunities with LastModifiedDate < 2 days time
            Database.executeBatch(new ColdOpportunityCleanup_Batchable(), 1);
        Test.stopTest();
        opp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(originalOppStage, opp.StageName);
    }

}