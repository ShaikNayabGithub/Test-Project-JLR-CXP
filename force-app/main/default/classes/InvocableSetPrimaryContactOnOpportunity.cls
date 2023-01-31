/**
 * Created by caleb@argologic.com.au on 10/12/2019.
 */

public without sharing class InvocableSetPrimaryContactOnOpportunity
{
    @InvocableMethod(label='Set Primary Contact On opportunity')
    public static void SetPrimaryContact(List<Id> opportunityIds)
    {
        if(!system.isFuture() && !system.isBatch()){
        	FutureSetPrimaryContact(opportunityIds);
        }
    }

    // todo - this should not be a future call however I think the contactId is not assigned immediately (something to look into because future callout is not ideal)
    @future
    public static void FutureSetPrimaryContact(List<Id> opportunityIds)
    {
        List<Opportunity> opps = [SELECT id, Primary_Contact__c, ContactId, Account.PersonContactId, Account.IsPersonAccount
        FROM Opportunity
        WHERE Id IN :opportunityIds AND (ContactId != null OR Account.IsPersonAccount = True)];
        for (Opportunity opp : opps)
        {
            if (opp.Account.IsPersonAccount)
            {
                opp.Primary_Contact__c = opp.Account.PersonContactId;
            }
            else
            {
                opp.Primary_Contact__c = opp.ContactId;
            }
        }
        update opps;
    }
}