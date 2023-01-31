/**
 * Created by Ethan Sargent on 5/5/20.
 */

public with sharing class AccountContactMergeController_Batch implements Database.Batchable<SObject>, Database.Stateful
{
    private static final String corporatePrimaryAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    public Set<String> failureIds = new Set<String>();
    private static List<String> errorStrings = new List<String>();


    public Database.QueryLocator start(Database.BatchableContext batchableContext)
    {
        Set<Id> parentIds = new Set<Id>();
        // Grabs all the primary accounts from the incorrect accounts in the database and selects them
        for (Account[] accs : [SELECT Primary_Account__c, Id, ParentId, CurrencyIsoCode, OwnerId, Phone, Fax, (SELECT Id, OwnerId, CurrencyIsoCode, ReportsToId, Phone, Fax FROM Contacts) FROM Account WHERE Name = '.' AND IsPersonAccount = FALSE])
        {
            for (Account acc : accs)
            {
                if (String.isNotBlank(acc.Primary_Account__c))
                {
                    parentIds.add(acc.Primary_Account__c);
                    System.debug('string Is not blank: '+ acc.Primary_Account__c);
                }
                else
                {
                    parentIds.add(acc.Id);
                    System.debug('string is blank: ' + acc.Id);
                }
            }
        }

        return Database.getQueryLocator('SELECT Primary_Account__c, RecordTypeId, Id, ParentId, CurrencyIsoCode, OwnerId, Phone, Fax, ' +
                '(SELECT Id, OwnerId, CurrencyIsoCode, ReportsToId, Phone, Fax FROM Contacts) ' +
                'FROM Account WHERE (Id IN :parentIds OR Primary_Account__c IN :parentIds) AND Country_Iso_code__c = \'AU\'');
    }


    Set<Id> primaryAccountIds = new Set<Id>();
    Set<Id> secondaryAccountIds = new Set<Id>();
    public void execute(Database.BatchableContext batchableContext, List<Account> scope)
    {
        marryAccounts(scope);
    }

    public void finish(Database.BatchableContext batchableContext)
    {
        if (failureIds.size() > 0)
        {
            System.debug(JSON.serializePretty(errorStrings));
            EmailUtility.SendEmail('ethan@argologic.com.au', 'Jaguar Apex Error', 'Apex Error in Person Account CreatePersonAccounts', 'Failed Ids: ' + JSON.serializePretty(failureIds) + 'Exceptions: ' + JSON.serializePretty(errorStrings));
        }
    }

    public void marryAccounts(List<Account> accountsToMarry)
    {
        List<Contact> contacts = new List<Contact>();
        for (Account acc : accountsToMarry)
        {
            if (acc.Contacts.size() != 1)
            {

                System.debug('CONTACT ERROR: size = ' + acc.Contacts.size());
                failureIds.add(acc.Id);
                if (String.isNotBlank(acc.Primary_Account__c))
                {
                    failureIds.add(acc.Primary_Account__c);
                }
                continue;
            }

            AccountContactPreparedForMerge res = prepareAccountForMerge(acc);


            acc = res.account;
            if (res.accountIsPrimary)
            {
                primaryAccountIds.add(acc.Id);
            }
            else
            {
                secondaryAccountIds.add(acc.Id);
            }
            contacts.add(res.contact);

        }

        // Ensuring any accounts (and related primary/secondary accounts) which have an incorrect number of contacts do not get converted
      List<Account> accsToBeRemoved = new List<Account>();
        for (Account acc: accountsToMarry)
        {
            if (failureIds.contains(acc.Id) || failureIds.contains(acc.Primary_Account__c))
            {
                accsToBeRemoved.add(acc);
              //  accountsToMarry.remove(accountsToMarry.indexOf(acc));
            }
        }
        if(accsToBeRemoved.Size() > 0 ){
            for(Account acc : accsToBeRemoved){
                  accountsToMarry.remove(accountsToMarry.indexOf(acc));
            }
        }
        

       

        for (Id primaryId: primaryAccountIds)
        {
            if (failureIds.contains(primaryId))
            {
                primaryAccountIds.remove(primaryId);
            }
        }
        for (Id secondaryId: secondaryAccountIds)
        {
            if (failureIds.contains(secondaryId))
            {
                secondaryAccountIds.remove(secondaryId);
            }
        }

        update accountsToMarry;
        update contacts;

        // Retrieve just recordTypeId for person account merge process
        List<Account> primaryAccounts = [SELECT RecordTypeId FROM Account WHERE Id IN :primaryAccountIds];
        List<Account> secondaryAccounts = [SELECT RecordTypeId FROM Account WHERE Id IN :secondaryAccountIds];

        List<Account> updateAccounts = new List<Account>();
        // Update Record Types according to primary/secondary account relationship
        for (Account acc : primaryAccounts)
        {
            Account tmpAcc = new Account();
            tmpAcc.Id = acc.Id;
            tmpAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
            updateAccounts.add(tmpAcc);
            System.debug('Primary Account added');
        }
        for (Account acc : secondaryAccounts)
        {
            Account tmpAcc = new Account();
            tmpAcc.Id = acc.Id;
            tmpAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
            updateAccounts.add(tmpAcc);
            System.debug('Secondary Account Added');
        }
        Database.SaveResult[] srList = Database.update(updateAccounts, false);

        for (Database.SaveResult sr : srList)
        {
            if (!sr.isSuccess())
            {
                failureIds.add(sr.getId());
                Database.Error[] errs = sr.getErrors();
                for (Database.Error err : errs)
                {
                    errorStrings.add('On account Id ' + sr.getId() + ' the following error has occurred:' + err.getMessage() + ' ' + err.getStatusCode() + 'The following fields affected this error:' + err.getFields());
                    System.debug('On account Id ' + sr.getId() + ' the following error has occurred:' + err.getMessage() + ' ' + err.getStatusCode() + 'The following fields affected this error:' + err.getFields());
                }
            }
        }
    }


    private AccountContactPreparedForMerge prepareAccountForMerge(Account acc)
    {
        Contact contact = acc.Contacts[0];
        acc.ParentId = null;
        acc.CurrencyIsoCode = contact.CurrencyIsoCode;
        acc.OwnerId = contact.OwnerId;
        acc.Fax = contact.Fax;
        acc.Phone = contact.Phone;
        contact.ReportsToId = null;
        AccountContactPreparedForMerge result = new AccountContactPreparedForMerge(acc, contact);
        return result;
    }

    private class AccountContactPreparedForMerge
    {
        public AccountContactPreparedForMerge(Account acc, Contact con)
        {
            this.account = acc;
            this.contact = con;
            System.debug('Acc.RecTypeId =>' + acc.RecordTypeId);
            System.debug('corporatePrimaryAccountRecordTypeId => ' + corporatePrimaryAccountRecordTypeId);
            System.debug('Creating result, (acc.RecordTypeId == corporatePrimaryAccountRecordTypeId) => '+ (acc.RecordTypeId == corporatePrimaryAccountRecordTypeId));
            this.accountIsPrimary = !!(acc.RecordTypeId == corporatePrimaryAccountRecordTypeId);
        }

        Account account { get; set; }
        Boolean accountIsPrimary { get; set; }
        Contact contact { get; set; }
    }
}