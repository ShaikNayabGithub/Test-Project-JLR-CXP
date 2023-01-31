/**
 * Created by caleb@argologic.com.au on 3/03/2020.
 */

public without sharing class MilestoneController
{
    @AuraEnabled
    public static List<MilestoneTypeDto> getNextMilestones(String developerName)
    {
        System.debug('developerName = ' + developerName);
        List<Opportunity_Stage_Map__mdt> milestones =
        [
                SELECT Next_MDT_Stage_Name__c, DeveloperName, Opportunity_Stage_Name__c, MasterLabel, Activity_Related_Milestone_Name__c, Stage_Number__c
                FROM Opportunity_Stage_Map__mdt ORDER BY Stage_Number__c
        ];

        List<MilestoneTypeDto> nextMilestones = new List<MilestoneTypeDto>();
        String nextMilestoneDevNames = null;
        for (Opportunity_Stage_Map__mdt milestone : milestones)
        {
            nextMilestones.add(new MilestoneTypeDto(milestone));
            if (milestone.Activity_Related_Milestone_Name__c == developerName)
            {
                nextMilestoneDevNames = milestone.Next_MDT_Stage_Name__c;
            }
        }

        for (MilestoneTypeDto milestoneType : nextMilestones)
        {
            if (milestoneType.DeveloperName == nextMilestoneDevNames)
            {
                milestoneType.IsDefault = true;
            }
        }

        return nextMilestones;
    }
}