@isTest
public class OpportunityStageDetailController_Test {

    static testmethod void ControllerListsDisplayedFieldsForValidStage() {
        Opportunity_Stage_Details__mdt stageDetails = [SELECT Label, Field_API_Names__c FROM Opportunity_Stage_Details__mdt WHERE Label = 'Qualified' LIMIT 1];
        Account acc = new Account(Name='Test', RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId());
        insert acc;
        Opportunity opp = new Opportunity(Name='Test', AccountId=acc.Id, RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Process_with_RDA').getRecordTypeId(), StageName='Qualified', CloseDate=Date.today()+4);
        insert opp;
        List<OpportunityStageDetailController.fieldWrap> stagefields = OpportunityStageDetailController.getStageFieldNames(opp.Id);
       // System.assertEquals(stageDetails.Field_API_Names__c.split(',')[0], stagefields[0]);
    }
    
    static testmethod void IsOpportunityClosedReturnsFalseForOpenOpportunity() {
        Account acc = new Account(Name='Test', RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId());
        insert acc;
        Opportunity opp = new Opportunity(Name='Test', AccountId=acc.Id, RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Process_with_RDA').getRecordTypeId(), StageName='Qualified', CloseDate=Date.today()+4);
        insert opp;
        System.assertEquals(false, OpportunityStageDetailController.isOpportunityClosed(opp.Id));
    }
    
}