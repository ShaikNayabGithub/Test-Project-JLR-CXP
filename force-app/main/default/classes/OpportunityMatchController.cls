/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class OpportunityMatchController
{
    public static String CONTACT_EMPLOYEE_RECORD_TYPE = 'Employee_Contact';
    public static String CORPORATE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    
    public static Integer MATCH_SCORE_THRESHOLD = 16;

    public static Integer CORPORATE_SEARCH_NO_CONTACT_MATCH_PENALTY = MATCH_SCORE_THRESHOLD / 4;

    @AuraEnabled(Cacheable=true)
    public static GetMatchingAccountsResponseDto getAccounts(GetMatchingAccountsRequestDto request)
    {
        /*
        for (Account a : [SELECT Id, RecordTypeId FROM Account])
        {
            System.debug(a.RecordTypeId);
        }
        System.debug(CORPORATE_RECORD_TYPE_ID);
        */

        try
        {
            OpportunityMatchControllerSearchTerm term = new OpportunityMatchControllerSearchTerm(
                    request.ContactNameFirst,
                    request.ContactNameLast,
                    request.ContactPhoneMobile,
                    request.ContactEmail,
                    request.AccountName
            );

            List<Contact> contacts =
            [
                    SELECT AccountId
                    FROM Contact
                    WHERE
                    (
                            (FirstName != NULL AND FirstName LIKE :term.NameFirstTerms)
                            OR (LastName != NULL AND LastName LIKE :term.NameLastTerms)
                            OR (Email != NULL AND Email LIKE :term.EmailTerms)
                            OR (MobilePhone != NULL AND MobilePhone LIKE :term.PhoneMobileTerms)
                    )
                    AND RecordType.DeveloperName != :CONTACT_EMPLOYEE_RECORD_TYPE
            ];

            List<String> accountIds = new List<String>();
            for (Contact contact : contacts) accountIds.add(contact.AccountId);
            System.debug('AccountIds: ' + accountIds);

            List<Account> accounts =
            [
                    SELECT
                            Id,
                            Name,
                    (
                            SELECT
                                    Id,
                                    Name,
                                    FirstName,
                                    LastName,
                                    Email,
                                    MobilePhone
                            FROM Contacts
                            WHERE
                            (
                                    (FirstName != NULL AND FirstName LIKE :term.NameFirstTerms)
                                    OR (LastName != NULL AND LastName LIKE :term.NameLastTerms)
                                    OR (Email != NULL AND Email LIKE :term.EmailTerms)
                                    OR (MobilePhone != NULL AND MobilePhone LIKE :term.PhoneMobileTerms)
                            )
                            AND RecordType.DeveloperName != :CONTACT_EMPLOYEE_RECORD_TYPE
                    )
                    FROM Account
                    WHERE (Name != NULL AND Name LIKE :term.accountNameTerms)
                    AND RecordTypeId = :CORPORATE_RECORD_TYPE_ID
                    //AND Id IN :accountIds
            ];

            List<MatchingAccountAttributeDto> accountDtos = new List<MatchingAccountAttributeDto>();
            for (Account account : accounts) {
                MatchingAccountAttributeDto accountDto = new MatchingAccountAttributeDto();
                accountDto.Id = account.Id;
                accountDto.AccountName = account.Name;
                accountDto.Contacts = new List<MatchingContactAttributeDto>();

                for (Contact contact : account.Contacts) {
                    MatchingContactAttributeDto contactDto = new MatchingContactAttributeDto();
                    contactDto.Id = contact.Id;
                    contactDto.ContactName = contact.Name;
                    contactDto.ContactFirstName = contact.FirstName;
                    contactDto.ContactLastName = contact.LastName;
                    contactDto.ContactPhoneMobile = contact.MobilePhone;
                    contactDto.ContactEmail = contact.Email;

                    contactDto.MatchScore = term.getContactMatchScore(contact.FirstName, contact.LastName, contact.Email, contact.MobilePhone);

                    accountDto.Contacts.add(contactDto);
                }

                accountDto.OrderContactsByMatchScore();
                accountDto.MatchScore = term.getAccountMatchScore(account.Name, accountDto.GetContactsBestMatchScore());
                if (accountDto.Contacts.size() == 0) accountDto.MatchScore += term.getContactMatchScore('','','','');

                if (accountDto.MatchScore <= MATCH_SCORE_THRESHOLD)
                {
                    accountDtos.add(accountDto);
                }
            }

            GetMatchingAccountsResponseDto response = new GetMatchingAccountsResponseDto();
            response.Accounts = accountDtos;
            response.OrderAccountsByMatchScore();
            
            return response;
        }
        catch (Exception ex)
        {
            GetMatchingAccountsResponseDto response = new GetMatchingAccountsResponseDto();
            response.addError(ex);
            return response;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static GetMatchingPersonAccountsResponseDto getPersonAccounts(GetMatchingPersonAccountsRequestDto request)
    {
        try
        {
            OpportunityMatchControllerSearchTerm term = new OpportunityMatchControllerSearchTerm(
                    request.PersonNameFirst,
                    request.PersonNameLast,
                    request.PersonPhoneMobile,
                    request.PersonEmail
            );

            System.debug('term.NameFirstTerms = ' + JSON.serialize(term.NameFirstTerms));

            List<Account> accounts;
            if (request.OwnerAccountId == null)
            {
                accounts = [
                        SELECT
                                Id,
                                Name,
                                FirstName,
                                LastName,
                                PersonContactId,
                                PersonEmail,
                                PersonMobilePhone

                        FROM Account
                        WHERE (
                                (FirstName != NULL AND FirstName LIKE :term.NameFirstTerms)
                                OR (LastName != NULL AND LastName LIKE :term.NameLastTerms)
                                OR (PersonEmail != NULL AND PersonEmail LIKE :term.PhoneMobileTerms)
                                OR (PersonMobilePhone != NULL AND PersonMobilePhone LIKE :term.EmailTerms)
                        )
                        AND IsPersonAccount = TRUE
                ];
            }
            else
            {
                accounts = [
                        SELECT
                                Id,
                                Name,
                                FirstName,
                                LastName,
                                PersonContactId,
                                PersonEmail,
                                PersonMobilePhone

                        FROM Account
                        WHERE (
                                (FirstName != NULL AND FirstName LIKE :term.NameFirstTerms)
                                OR (LastName != NULL AND LastName LIKE :term.NameLastTerms)
                                OR (PersonEmail != NULL AND PersonEmail LIKE :term.PhoneMobileTerms)
                                OR (PersonMobilePhone != NULL AND PersonMobilePhone LIKE :term.EmailTerms)
                        )
                        AND IsPersonAccount = TRUE
                        AND Owner.Contact.AccountId = :request.OwnerAccountId
                        AND RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_ACCOUNT_INDIVIDUAL
                ];
            }

            System.debug('account.size() = ' + accounts.size());
            List<MatchingPersonAccountAttributeDto> accountDtos = new List<MatchingPersonAccountAttributeDto>();
            for (Account account : accounts)
            {
                MatchingPersonAccountAttributeDto accountDto = new MatchingPersonAccountAttributeDto();
                accountDto.Id = account.Id;
                accountDto.PersonContactId = account.PersonContactId;
                accountDto.PersonName = account.Name;
                accountDto.PersonFirstName = account.FirstName;
                accountDto.PersonLastName = account.LastName;
                accountDto.PersonEmail = account.PersonEmail;
                accountDto.PersonPhoneMobile = account.PersonMobilePhone;
                accountDto.MatchScore = term.getPersonAccountMatchScore(
                        account.FirstName,
                        account.LastName,
                        account.PersonEmail,
                        account.PersonMobilePhone
                );
                if (accountDto.MatchScore <= MATCH_SCORE_THRESHOLD)
                {
                    accountDtos.add(accountDto);
                }
            }
            GetMatchingPersonAccountsResponseDto response = new GetMatchingPersonAccountsResponseDto();
            response.PersonAccounts = accountDtos;
            response.OrderPersonAccountsByMatchScore();
            return response;
        }
        catch (Exception ex)
        {
            GetMatchingPersonAccountsResponseDto response = new GetMatchingPersonAccountsResponseDto();
            response.addError(ex);
            return response;
        }
    }

    @AuraEnabled(Cacheable=true)
    public static GetMatchingOpportunitiesResponseDto getOpportunities(GetMatchingOpportunitiesRequestDto request)
    {
        List<Opportunity> opportunities =
        [
                SELECT
                        Id,
                        Name,
                        Primary_Model_Interest__r.Name,
                        Primary_Contact__r.Name,
                        Brand__r.Name,
                        Owner.Name,
                        CreatedDate
                FROM Opportunity
                WHERE Primary_Contact__c = :request.ContactId
                AND IsClosed = false
        ];
        
        List<MatchingOpportunityDto> opportunityDtos = new List<MatchingOpportunityDto>();
        for (Opportunity opportunity : opportunities)
        {
            MatchingOpportunityDto opportunityDto = new MatchingOpportunityDto();
            opportunityDto.Id = opportunity.Id;
            opportunityDto.OpportunityName = opportunity.Name;
            opportunityDto.VehicleBrand = opportunity.Brand__r.Name;
            opportunityDto.VehicleModel = opportunity.Primary_Model_Interest__r.Name;
            opportunityDto.PrimaryContact = opportunity.Primary_Contact__r.Name;
            opportunityDto.Owner = opportunity.Owner.Name;
            opportunityDto.CreatedDate = opportunity.CreatedDate.date();
            opportunityDtos.add(opportunityDto);
        }
        GetMatchingOpportunitiesResponseDto response = new GetMatchingOpportunitiesResponseDto();
        response.Opportunities = opportunityDtos;
        return response;
    }




}