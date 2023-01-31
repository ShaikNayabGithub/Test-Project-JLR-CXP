/**
 * Created by caleb@argologic.com.au on 17/03/2021.
 */

public with sharing class OpportunityConversionController
{
    @AuraEnabled
    public static OpportunityConvertDataDto getConversionData(string leadId)
    {
        OpportunityConvertDataDto res = new OpportunityConvertDataDto();

        Lead lead = [
                SELECT FirstName, LastName, Email, MobilePhone, Preferred_Retailer__r.ParentId, IsConverted FROM Lead WHERE Id = :leadId
        ];

        if (lead.Preferred_Retailer__r.ParentId == null)
        {
            throw new JlrCustomException('Preferred retailer must be selected and valid before converting');
        }

        if (lead.IsConverted == true)
        {
            throw new JlrCustomException('Lead is already converted');
        }

        res.leadFirstName = lead.FirstName;
        res.leadLastName = lead.LastName;
        res.leadEmail = lead.Email;
        res.leadPhoneMobile = lead.MobilePhone;
        res.opportunityName = lead.FirstName + ' '
                + lead.LastName + ' '
                + Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('d MMMM yyyy');

        GetMatchingPersonAccountsRequestDto requestDto = new GetMatchingPersonAccountsRequestDto();
        requestDto.PersonNameFirst = lead.FirstName;
        requestDto.PersonNameLast = lead.LastName;
        requestDto.PersonEmail = lead.Email;
        requestDto.PersonPhoneMobile = lead.MobilePhone;
        requestDto.OwnerAccountId = lead.Preferred_Retailer__r.ParentId;

        GetMatchingPersonAccountsResponseDto responseDto = OpportunityMatchController.getPersonAccounts(requestDto);

        res.MatchingPersonAccounts = responseDto.PersonAccounts;

        return res;
    }

    @AuraEnabled
    public static List<GetAccountsOpportunitiesDto> getAccountsOpportunities(string accountId)
    {
        List<Opportunity> opps = [
                SELECT Id, Name, Primary_Model_Interest__r.Name, Brand__r.Name
                FROM Opportunity
                WHERE AccountId = :accountId
                AND StageName != 'Lost'
        ];

        List<GetAccountsOpportunitiesDto> res = new List<GetAccountsOpportunitiesDto>();
        for (Opportunity opp : opps)
        {
            GetAccountsOpportunitiesDto oppDto = new GetAccountsOpportunitiesDto();
            oppDto.Id = opp.Id;
            oppDto.Name = opp.Name;
            oppDto.Make = opp.Brand__r.Name;
            oppDto.Model = opp.Primary_Model_Interest__r.Name;
            res.add(oppDto);
        }
        return res;
    }

    public class GetAccountsOpportunitiesDto
    {
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string Model;
        @AuraEnabled
        public string Make;
    }

    @AuraEnabled
    public static void ConvertLead(ConvertLeadDto req)
    {
        Lead leadToBeConverted = [
                SELECT Preferred_Retailer__c
                FROM Lead
                WHERE Id = :req.leadId
        ];

        Account ChildRetailerAccount = [
                SELECT ParentId
                FROM Account
                WHERE Id = :leadToBeConverted.Preferred_Retailer__c
        ];

        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(req.leadId);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1]; // todo - check this is right
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setOwnerId(getDefaultUser(ChildRetailerAccount).Id);

        if (req.accountId != null)
        {
            lc.setAccountId(req.accountId);
        }
        else
        {
            Account acc = new Account();
            acc.FirstName = req.accountFirstName;
            acc.LastName = req.accountLastName;
            acc.PersonEmail = req.accountEmail;
            acc.PersonMobilePhone = req.accountMobile;
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
            acc.RecordTypeId = recordTypes.get('Individual').getRecordTypeId();
            lc.setAccountId(req.accountId);
        }

        if (req.opportunityId != null)
        {
            lc.setOpportunityId(req.opportunityId);
        }
        else
        {
            lc.setOpportunityName(req.opportunityName);
        }

        // attempt to fix too many quearys
        RecordSharer.DisableRecordSharing = true;
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        if (!lcr.isSuccess())
        {
            throw new JlrCustomException('Lead Conversion Failed ):');
        }

    }

    private static User getDefaultUser(Account childRetailerAccount)
    {
        System.debug('childRetailerAccount.ParentId = ' + childRetailerAccount.ParentId);
        List<User> defaultUsers = [
                SELECT Id
                FROM User
                WHERE Contact.AccountId = :childRetailerAccount.ParentId
                AND Contact.Name LIKE '%Default User%'
        ];
        if (defaultUsers.size() >= 1) return defaultUsers[0];
        throw new JlrCustomException('No Default user found');
    }

}