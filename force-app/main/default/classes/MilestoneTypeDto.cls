/**
 * Created by caleb@argologic.com.au on 3/03/2020.
 */

public with sharing class MilestoneTypeDto
{
    @AuraEnabled
    public string DeveloperName {get; set;}

    @AuraEnabled
    public string ActivityMilestoneDeveloperName {get; set;}

    @AuraEnabled
    public string Label {get; set;}

    @AuraEnabled
    public string OpportunityStageName {get; set;}

    @AuraEnabled
    public Boolean IsDefault {get; set;}

    @AuraEnabled
    public Integer StageNumber {get; set;}

    public MilestoneTypeDto(Opportunity_Stage_Map__mdt milestone)
    {
        ActivityMilestoneDeveloperName = milestone.Activity_Related_Milestone_Name__c;
        DeveloperName = milestone.DeveloperName;
        Label = milestone.MasterLabel;
        OpportunityStageName = milestone.Opportunity_Stage_Name__c;
        StageNumber = Integer.valueOf(milestone.Stage_Number__c);
        IsDefault = false;
    }
}