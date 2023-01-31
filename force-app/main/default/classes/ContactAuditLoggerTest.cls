/**
 * Created by caleb@argologic.com.au on 23/04/2021.
 */

@IsTest
public with sharing class ContactAuditLoggerTest
{
    @IsTest
    public static void ContactLoggerTest()
    {
        // ARRANGE
        Account a = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = '.';
        c.FirstName = '.';
        c.Email = 't@t.com';
        c.Country_ISO_Code__c = 'AU';
        insert c;
        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.ContactId = c.Id;
        o.Name = 'Test opp';
        o.StageName = 'Test Drive';
        o.CloseDate = Date.today().addDays(2);
        o.Primary_Contact__c = c.Id;
        insert o;

        Asset ass = TestClass_AssetBuilder.BuildVehicle();
        ass.Is_Price_Protected__c = true;
        insert ass;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = ass.Derivative__c;
        pbe.UnitPrice = 0;
        pbe.IsActive = true;
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Asset__c = ass.Id;
        oli.Product2Id = ass.Derivative__c;
        oli.OpportunityId = o.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 1;
        oli.TotalPrice = 0;
        insert oli;

        Constants.contactAfterUpdate = true;
        // ACT
        Test.startTest();
        c.FirstName = 'This is a change';
        c.LastName = 'This is a change';
        update c;
        Test.stopTest();
    }

    @IsTest
    public static void AccountLoggerTest()
    {
        // ARRANGE
        Account a = TestClass_AccountCreator.createPersonAccount_Australia();

        Opportunity o = new Opportunity();
        o.AccountId = a.Id;
        o.ContactId = a.PersonContactId;
        o.Name = 'Test opp';
        o.StageName = 'Test Drive';
        o.CloseDate = Date.today().addDays(2);
        o.Primary_Contact__c = a.PersonContactId;
        insert o;

        Asset ass = TestClass_AssetBuilder.BuildVehicle();
        ass.Is_Price_Protected__c = true;
        insert ass;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = ass.Derivative__c;
        pbe.UnitPrice = 0;
        pbe.IsActive = true;
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Asset__c = ass.Id;
        oli.Product2Id = ass.Derivative__c;
        oli.OpportunityId = o.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 1;
        oli.TotalPrice = 0;
        insert oli;

        // ACT
        Test.startTest();
        a.FirstName = '..';
        a.LastName = '..';
        update a;
        Test.stopTest();
    }
}