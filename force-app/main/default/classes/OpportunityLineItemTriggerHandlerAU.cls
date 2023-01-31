/**
 * Created by caleb on 11/05/2022.
 */

public without sharing class OpportunityLineItemTriggerHandlerAU
{
    public static void AfterInsert()
    {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (OpportunityLineItem oli : (List<OpportunityLineItem>)Trigger.new)
        {
            if (oli.Related_Opportunity_Sales_Type__c == 'New'
                    && oli.Asset__c != null
                    && oli.Related_Asset_Planned_Delivery_Date__c != null
                    && oli.Related_Opportunity_Is_Won__c
                    && oli.Related_Opportunity_Iso_Code__c == 'AU')
            {
                Opportunity opp = new Opportunity(Id = oli.OpportunityId,
                        Handover_Date__c = oli.Related_Asset_Planned_Delivery_Date__c.AddDays(10));
                oppsToUpdate.add(opp);
            }
        }
        update oppsToUpdate;
    }

    public static void AfterUpdate()
    {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (OpportunityLineItem oli : (List<OpportunityLineItem>)Trigger.new)
        {
            if (oli.Related_Opportunity_Sales_Type__c == 'New'
                    && oli.Asset__c != ((Map<Id, OpportunityLineItem>)Trigger.oldMap).get(oli.Id).Asset__c
                    && oli.Related_Asset_Planned_Delivery_Date__c != null
                    && oli.Related_Opportunity_Is_Won__c
                    && oli.Related_Opportunity_Iso_Code__c == 'AU')
            {
                Opportunity opp = new Opportunity(Id = oli.OpportunityId,
                        Handover_Date__c = oli.Related_Asset_Planned_Delivery_Date__c.AddDays(10));
                oppsToUpdate.add(opp);
            }
        }
        update oppsToUpdate;
    }


}