/**
 * Created by caleb@argologic.com.au on 24/03/2021.
 */

public without sharing class ContactAuditLogger
{

    public static Set<String> AlreadyRunPersonContactIdNamePairs = new Set<String>();
    //@Future
    public static void InsertAuditLogsContact(List<Contact> currentContacts, Map<Id, Contact> oldContacts)
    {
        // since the triggers are not properly de recursed we make sure we at least don't run this code more than once if we do not have to
        List<Contact> currentContactsFiltered = new List<Contact>();
        for (Contact con : currentContacts)
        {
            System.debug('con.Country_ISO_Code__c = ' + con.Country_ISO_Code__c);
            System.debug('con.FirstName = ' + con.FirstName);
            System.debug('oldContacts.get(con.Id).FirstName = ' + oldContacts.get(con.Id).FirstName);
            System.debug('con.LastName = ' + con.LastName);
            System.debug('oldContacts.get(con.Id).LastName = ' + oldContacts.get(con.Id).LastName);
            if (con.Country_ISO_Code__c != 'AU' || (con.FirstName == oldContacts.get(con.Id).FirstName && con.LastName == oldContacts.get(con.Id).LastName)) continue;
            String key = con.Id + ':' + con.FirstName + ':' + con.LastName;
            if (!AlreadyRunPersonContactIdNamePairs.contains(key))
            {
                currentContactsFiltered.add(con);
                AlreadyRunPersonContactIdNamePairs.add(key);
            }
        }
        if (currentContactsFiltered.size() == 0) return;

        List<OpportunityLineItem> relatedOpps = [
                SELECT Opportunity.Primary_Contact__c, Asset__r.Is_Price_Protected__c, Asset__c
                FROM OpportunityLineItem
                WHERE Opportunity.Primary_Contact__c = :oldContacts.keySet()
                AND Asset__c != NULL
        ];
        System.debug('relatedOpps = ' + JSON.serialize(relatedOpps));

        Map<String, OpportunityLineItem> contactIdToOpportunity = new Map<String, OpportunityLineItem>();
        for (OpportunityLineItem opp : relatedOpps)
        {
            contactIdToOpportunity.put(opp.Opportunity.Primary_Contact__c, opp);
        }

        List<Contact> contactsWithModifiedNames = new List<Contact>();
        for (Contact con : currentContactsFiltered)
        {
            if (contactIdToOpportunity.containsKey(con.Id) && contactIdToOpportunity.get(con.Id).Asset__r.Is_Price_Protected__c && con.Country_ISO_Code__c == 'AU' && (con.FirstName != oldContacts.get(con.Id).FirstName || con.LastName != oldContacts.get(con.Id).LastName))
            {
                contactsWithModifiedNames.add(con);
            }
        }

        List<Account_Detail_Audit__c> toInsert = new List<Account_Detail_Audit__c>();
        for (Contact con : contactsWithModifiedNames)
        {
            Account_Detail_Audit__c aad = new Account_Detail_Audit__c();
            aad.New_Contact_First_Name__c = con.FirstName;
            aad.New_Contact_Last_Name__c = con.LastName;
            aad.Old_Contact_First_Name__c = oldContacts.get(con.Id).FirstName;
            aad.Old_Contact_Last_Name__c = oldContacts.get(con.Id).LastName;
            aad.Contact__c = con.Id;
            aad.Modified_User__c = UserInfo.getUserId();
            aad.Asset__c = contactIdToOpportunity.get(con.Id).Asset__c;
            toInsert.add(aad);
        }
        insert toInsert;
    }


    public static Set<String> AlreadyRunPersonAccountIdNamePairs = new Set<String>();

    //@Future
    public static void InsertAuditLogsPersonAccount(List<Account> currentAccounts, Map<Id, Account> oldAccounts)
    {
        // since the triggers are not properly de recursed we make sure we at least don't run this code more than once if we do not have to
        List<Account> currentAccountsFiltered = new List<Account>();
        for (Account acc : currentAccounts)
        {
            if (!acc.IsPersonAccount || acc.Country_ISO_Code__c != 'AU' || (acc.FirstName == oldAccounts.get(acc.Id).FirstName || acc.LastName == oldAccounts.get(acc.Id).LastName)) continue;
            String key = acc.Id + ':' + acc.FirstName + ':' + acc.LastName;
            if (!AlreadyRunPersonAccountIdNamePairs.contains(key))
            {
                currentAccountsFiltered.add(acc);
                AlreadyRunPersonAccountIdNamePairs.add(key);
            }
        }
        if (currentAccountsFiltered.size() == 0) return;

        List<OpportunityLineItem> relatedOpps = [
                SELECT Opportunity.AccountId, Asset__r.Is_Price_Protected__c, Asset__c
                FROM OpportunityLineItem
                WHERE Opportunity.AccountId = :oldAccounts.keySet()
                AND Asset__c != NULL
        ];

        Map<String, OpportunityLineItem> accountIdToOpportunity = new Map<String, OpportunityLineItem>();
        for (OpportunityLineItem opp : relatedOpps)
        {
            accountIdToOpportunity.put(opp.Opportunity.AccountId, opp);
        }

        List<Account> accountsWithModifiedNames = new List<Account>();
        for (Account acc : currentAccountsFiltered)
        {
            if (accountIdToOpportunity.containsKey(acc.Id) && accountIdToOpportunity.get(acc.Id).Asset__r.Is_Price_Protected__c && acc.IsPersonAccount && acc.Country_ISO_Code__c == 'AU' && (acc.FirstName != oldAccounts.get(acc.Id).FirstName || acc.LastName != oldAccounts.get(acc.Id).LastName))
            {
                accountsWithModifiedNames.add(acc);
            }
        }

        List<Account_Detail_Audit__c> toInsert = new List<Account_Detail_Audit__c>();
        for (Account acc : accountsWithModifiedNames)
        {
            Account_Detail_Audit__c aad = new Account_Detail_Audit__c();
            aad.New_Contact_First_Name__c = acc.FirstName;
            aad.New_Contact_Last_Name__c = acc.LastName;
            aad.Old_Contact_First_Name__c = oldAccounts.get(acc.Id).FirstName;
            aad.Old_Contact_Last_Name__c = oldAccounts.get(acc.Id).LastName;
            aad.Contact__c = acc.PersonContactId;
            aad.Modified_User__c = UserInfo.getUserId();
            aad.Asset__c = accountIdToOpportunity.get(acc.Id).Asset__c;
            toInsert.add(aad);
        }
        insert toInsert;
    }
}