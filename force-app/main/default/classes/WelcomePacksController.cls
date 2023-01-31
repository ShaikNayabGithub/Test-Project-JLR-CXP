/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 21/10/2019.
 */

public with sharing class WelcomePacksController {

    public static List<String> COMPLETED_STATUS = new List<String> { 'Auto - Call Completed', 'Call Completed' };
    public static final String WELCOME_TO_THE_BRAND_RECORD_TYPE_NAME = 'Welcome_to_the_Brand';
    public static final String PREVIOUS_OWNER_ROLE = 'Previous Owner';
    public static final String CURRENT_OWNER_ROLE = 'Current Owner';

    public static GetWelcomePacksResponseDto getWelcomePacks(GetWelcomePacksRequestDto request)
    {
        List<Task> tasks =
        [
                SELECT
                        Id,
                        WhoId,
                        WhatId
                FROM Task
                WHERE RecordType.DeveloperName = :WELCOME_TO_THE_BRAND_RECORD_TYPE_NAME
                    AND Status IN :COMPLETED_STATUS
                    AND Task.Completed_Time__c > :request.dateStart
                    AND WhoId != NULL
                    AND WhatId != NULL
                    AND WhoId IN (SELECT Id FROM Contact WHERE Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA)
        ];
        System.debug('Size = ' + tasks.size());
        List<String> whatIds = new List<String>();
        List<String> whoIds = new List<String>();
        for (Task t : tasks)
        {
            whatIds.add(t.WhatId);
            whoIds.add(t.WhoId);
        }
        Map<Id, Asset> assets = new Map<Id, Asset>([
                SELECT
                        Id,
                        Warranty_End_Date__c,
                        Warranty_Start_Date__c,
                        Derivative__r.Name,
                        VIN__c,
                        Registration_Number__c,
                        Brand__r.Name,
                        Model__r.Name,
                        Model__r.Model_Alternative__c
                FROM Asset WHERE Id IN :whatIds
        ]);

        Set<Id> AssetIds = assets.keySet();

        Map<Id, Contact> contacts = new Map<Id, Contact>([
                SELECT
                        Id,
            			AccountId,
                        MailingStreet,
                        MailingCountry,
                        MailingPostalCode,
                        MailingState,
                        MailingCity,
                        Account.BillingStreet,
                        Account.BillingCountry,
                        Account.BillingPostalCode,
                        Account.BillingState,
                        Account.BillingCity,
                        Account.Name,
                        Account.Primary_Account__c,
                        Name,
                        Email,
                        FirstName,
                        LastName,
                        HomePhone,
                        MobilePhone,
                        Birthdate,
                        Salutation,
                        Phone,
                        IsPersonAccount
                FROM Contact WHERE Id IN :whoIds
        ]);

        Map<String, Contact> primaryAccountIdToContact = new Map<String, Contact>();
        for (Contact con : contacts.values())
        {
            primaryAccountIdToContact.put(con.Account.Primary_Account__c, con);
        }

        List<Role__c> roles = [
                SELECT Vehicle__c, Account__c
                FROM Role__c
                WHERE Account__c IN :primaryAccountIdToContact.keySet()
        ];

        Map<Contact, List<Role__c>> contactToListOfRoles = new Map<Contact, List<Role__c>>();
        for (Contact con : contacts.values())
        {
            contactToListOfRoles.put(con, new List<Role__c>());
        }
        for (Role__c role : roles)
        {
            contactToListOfRoles.get(primaryAccountIdToContact.get(role.Account__c)).add(role);
        }

        return new GetWelcomePacksResponseDto(tasks, contacts, assets, contactToListOfRoles);
    }
}