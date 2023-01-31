/**
 * Created by Ethan Sargent on 12/08/2021.
 */

@IsTest
private class OpportunityTriggerHandlerAU_Test
{

    @TestSetup
    static void setup()
    {

    }

    @IsTest
    static void testStageChangeNoError()
    {
        // Arrange
        OpportunityTriggerHandlerAU.runInTestContext = true;
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Handover & RDA';
        opp.Country_ISO_Code__c = 'AU';
        // dummy Id, not inserted, doesn't matter
        opp.Id = '0061o000011PdFLAA0';

        opp.Always_Allow_Stage_Change__c = false;
        Opportunity oldOppMock = new Opportunity();
        oldOppMock.Id = opp.Id;
        oldOppMock.StageName = 'Not Handover';

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>{opp.Id => oldOppMock};
        // Act

        OpportunityTriggerHandlerAU.PreUpdate(new List<Opportunity> {opp} , opportunityMap);
        // Assert
        System.assertNotEquals(true, opp.hasErrors());
    }

    @IsTest
    static void testNameChangeNoError()
    {
        // Arrange
        OpportunityTriggerHandlerAU.runInTestContext = true;
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        opp.Country_ISO_Code__c = 'AU';
        // dummy Id, not inserted, doesn't matter
        opp.Id = '0061o000011PdFLAA0';

        opp.Always_Allow_Stage_Change__c = false;
        Opportunity oldOppMock = new Opportunity();
        oldOppMock.Id = opp.Id;
        oldOppMock.Name = 'ChangedName';

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>{opp.Id => oldOppMock};
        // Act

        OpportunityTriggerHandlerAU.PreUpdate(new List<Opportunity> {opp} , opportunityMap);
        // Assert
        System.assertNotEquals(true, opp.hasErrors());
    }
}