/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 22/09/2019.
 */
@IsTest 
public with sharing class TestClass_OpportunityCreator {

    public static Opportunity generateOpportunity(){
        Asset ass = TestClass_AssetBuilder.BuildVehicle();
        Account acc = TestClass_AccountCreator.createPersonAccount();
        return generateOpportunity(ass.Id, acc.Id);
    }


    public static Opportunity generateOpportunity(String assetId, String accId)
    {
        Opportunity opp = buildOpp(assetId, accId);
        insert opp;
        return opp;

    }

    public static Opportunity generateOpportunity(String assetId, String accId, Id primaryContactId)
    {
        Opportunity opp = buildOpp(assetId, accId);
        opp.Primary_Contact__c = primaryContactId;
        insert opp;
        return opp;

    }

    private static Opportunity buildOpp(String assetId, String accId) {
        Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                StageName = 'Save a Quote',
                CloseDate = Date.today().addDays(3),
                Budget__c = 100000,
                CurrencyIsoCode = 'JPY',
                Asset__c = assetId,
                AccountId = accId,
                Purchase_Type__c = 'New Vehicle'

        );
        return opp;
    }
    public static List<Opportunity> createOppList() {
        Account acc = TestClass_AccountCreator.createPersonAccount();
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++)
        {
            Opportunity opp = new Opportunity(
                    ContactId = acc.PersonContactId,
                    Name = 'Test' + i,
                    StageName = 'Negotiation',
                    CloseDate = Date.today().addDays(3),
                    Budget__c = 100000,
                    CurrencyIsoCode = 'JPY',
                    Country_ISO_Code__c = 'AU',
                    AccountId = acc.Id,
                    Purchase_Type__c = 'New Vehicle'
            );
            //Check RecordType
            System.debug('Account Id: ' + acc.Id);
            System.debug('Opp-RecordTypeName: ' + opp.Account.RecordType.Name);
            opps.add(opp);
        }
        insert opps;
        return opps;
    }

    public static List<Opportunity> createOppList_Australia(Integer count)
    {
        Account acc = TestClass_AccountCreator.createPersonAccount_Australia();
        List<Opportunity> opps = new List<Opportunity>();
        Campaign camp = new Campaign();
        camp.Name = 'MyCampaign';
        camp.CurrencyIsoCode = Constants.CURRENCY_CODE_AUD;
        camp.Market_ID__c = Constants.COUNTRY_CODE_AU;
        insert camp;

        for (Integer i = 0; i < count; i++)
        {
            Opportunity opp = new Opportunity(
                    ContactId = acc.PersonContactId,
                    Name = 'Test' + i,
                    StageName = 'Negotiation',
                    CloseDate = Date.today().addDays(3),
                    Budget__c = 100000,
                    CurrencyIsoCode = Constants.CURRENCY_CODE_AUD,
                    Country_ISO_Code__c = Constants.COUNTRY_CODE_AU,
                    AccountId = acc.Id,
                    Purchase_Type__c = 'New Vehicle'
            );
            opp.Lead_Created_Date_Time__c = DateTime.now();
            opp.Approved_By__c = UserInfo.getUserId();
            opp.CampaignId = camp.Id;
            //Check RecordType
            System.debug('Account Id: ' + acc.Id);
            System.debug('Opp-RecordTypeName: ' + opp.Account.RecordType.Name);
            opps.add(opp);

        }
        insert opps;
        return opps;
    }

    public static List<Opportunity> createOppList_Australia()
    {
        Account acc = TestClass_AccountCreator.createPersonAccount_Australia();
        List<Opportunity> opps = new List<Opportunity>();
        Campaign camp = new Campaign();
        camp.Name = 'MyCampaign';
        camp.CurrencyIsoCode = Constants.CURRENCY_CODE_AUD;
        camp.Market_ID__c = Constants.COUNTRY_CODE_AU;
        insert camp;

        for (Integer i = 0; i < 10; i++)
        {
            Opportunity opp = new Opportunity(
                    ContactId = acc.PersonContactId,
                    Name = 'Test' + i,
                    StageName = 'Negotiation',
                    CloseDate = Date.today().addDays(3),
                    Budget__c = 100000,
                    CurrencyIsoCode = Constants.CURRENCY_CODE_AUD,
                    Country_ISO_Code__c = Constants.COUNTRY_CODE_AU,
                    AccountId = acc.Id,
                    Purchase_Type__c = 'New Vehicle'
            );
            opp.Lead_Created_Date_Time__c = DateTime.now();
            opp.Approved_By__c = UserInfo.getUserId();
            opp.CampaignId = camp.Id;
            //Check RecordType
            System.debug('Account Id: ' + acc.Id);
            System.debug('Opp-RecordTypeName: ' + opp.Account.RecordType.Name);
            opps.add(opp);

        }
        insert opps;
        return opps;
    }
}