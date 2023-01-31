/**
 * Created by caleb@argologic.com.au on 12/02/2021.
 */

public with sharing class OpportunityTriggerHandlerAU
{
    public static Boolean runInTestContext = false;

    public static void PostUpdate(List<Opportunity> currentOpportunities, Map<Id, Opportunity> oldOpportunities)
    {
        List<String> oppIdsToRemoveAssetFrom = new List<String>();
        for (Opportunity opp : currentOpportunities)
        {
            if (opp.Country_ISO_Code__c == Constants.COUNTRY_CODE_AU && opp.StageName == 'Lost' && oldOpportunities.get(opp.Id).StageName != 'Lost') oppIdsToRemoveAssetFrom.add(opp.Id);
        }
        List<OpportunityLineItem> olisToRemoveAssetFrom = [SELECT Id FROM OpportunityLineItem
                                                           WHERE OpportunityId IN :oppIdsToRemoveAssetFrom
                                                           AND Product2.RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT
                                                          ];
        for (OpportunityLineItem oli : olisToRemoveAssetFrom)
        {
            //if (true) throw new JlrCustomException('asdasdda');
            oli.Asset__c = null;
        }
        update olisToRemoveAssetFrom;
    }
    
    public static User loggedInUser = getLoggedInUser(UserInfo.getUserId());
    
    public static User getLoggedInUser(Id userId) {
        if(loggedInUser == null || loggedInUser.Id != userId) {
            loggedInUser = [SELECT Id, IsPortalEnabled FROM User WHERE Id = :userId];
        }
        return loggedInUser;
    }

    public static void PreUpdate(List<Opportunity> currentOpportunities, Map<Id, Opportunity> oldOpportunities)
    {
        if (!Test.isRunningTest() || runInTestContext)
        {
            // User u = [SELECT Id, IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId()];
            User u = getLoggedInUser(UserInfo.getUserId());
            
            for (Opportunity opp : currentOpportunities)
            {
                if (opp.Country_ISO_Code__c == 'AU'
                        && opp.StageName == 'Handover & RDA'
                        && oldOpportunities.get(opp.Id).StageName != 'Handover & RDA'
                        && !opp.Always_Allow_Stage_Change__c
                        && u.IsPortalEnabled)
                {
                    //opp.addError('You cannot change the stage to Won on the Opportunity details page. Please use the Milestone Checklist.');
                }

                if (opp.Country_ISO_Code__c == 'AU'
                        && opp.Name != oldOpportunities.get(opp.Id).Name
                        && !opp.Always_Allow_Stage_Change__c
                        && u.IsPortalEnabled)
                {
                    //opp.addError('You cannot change the Opportunity Name on the Opportunity details page');
                }
            }

            for (Opportunity opp : currentOpportunities)
            {
                opp.Always_Allow_Stage_Change__c = false;
            }
        }
    }
}