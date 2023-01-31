/**
 * Created by caleb@argologic.com.au on 26/05/2021.
 */

@IsTest
public with sharing class OpportunityConversionControllerTest
{
    @IsTest
    public static void getConversionDataTest()
    {
        // ARRANGE
        Lead lead = TestClass_LeadCreator.CreateConvertableLead('Private');
        Account retailer = TestClass_AccountCreator.BuildRetailer();
        Account retailer2 = TestClass_AccountCreator.BuildRetailer();
        insert retailer2;
        retailer.ParentId = retailer2.Id;
        insert retailer;
        lead.Preferred_Retailer__c = retailer.Id;
        update lead;

        // ACT
        Test.startTest();
        OpportunityConversionController.getConversionData(lead.Id);
        Test.stopTest();

        // ASSERT

    }

    @IsTest
    public static void getAccountsOpportunitiesTest()
    {
        // ARRANGE
        Account pc = TestClass_AccountCreator.createPersonAccount_Australia();

        // ACT
        Test.startTest();
        OpportunityConversionController.getAccountsOpportunities(pc.Id);
        Test.stopTest();

        // ASSERT
    }

    @IsTest
    public static void ConvertLeadTest()
    {
        // ARRANGE
        Account pc = TestClass_AccountCreator.createPersonAccount_Australia();
        Lead lead = TestClass_LeadCreator.CreateConvertableLead('Private');
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        Account retailerChild = TestClass_AccountCreator.BuildRetailer();
        retailerChild.ParentId = retailer.Id;
        insert retailerChild;
        lead.Preferred_Retailer__c = retailerChild.Id;
        update lead;

        Test.startTest();
        Contact con = TestClass_ValidContactBuilder.Build(retailer);
        con.FirstName = 'Default User';
        con.LastName = 'Default User';
        update con;

        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u)
        {
            TestClass_UserCreator.CreateRetailerUser(con);
        }

        OpportunityConvertDataDto res = OpportunityConversionController.getConversionData(lead.Id);

        ConvertLeadDto req = new ConvertLeadDto();
        req.leadId = lead.Id;
        req.accountId = pc.Id;
        req.accountEmail = pc.personEmail;
        req.accountFirstName = pc.FirstName;
        req.accountLastName = pc.LastName;
        req.accountMobile = pc.PersonMobilePhone;
        req.opportunityName = 'test';

        // ACT

        OpportunityConversionController.ConvertLead(req);
        Test.stopTest();

        // ASSERT
    }

    @IsTest
    public static void ConvertLeadTest2()
    {
        // ARRANGE
        Lead lead = TestClass_LeadCreator.CreateConvertableLead('Private');
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        Account retailerChild = TestClass_AccountCreator.BuildRetailer();
        retailerChild.ParentId = retailer.Id;
        insert retailerChild;
        lead.Preferred_Retailer__c = retailerChild.Id;
        update lead;

        Test.startTest();
        Contact con = TestClass_ValidContactBuilder.Build(retailer);
        con.FirstName = 'Default User';
        con.LastName = 'Default User';
        update con;

        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u)
        {
            TestClass_UserCreator.CreateRetailerUser(con);
        }

        OpportunityConvertDataDto res = OpportunityConversionController.getConversionData(lead.Id);

        ConvertLeadDto req = new ConvertLeadDto();
        req.leadId = lead.Id;
        req.accountEmail = 't@t.com';
        req.accountFirstName = 'test';
        req.accountLastName = 'test';
        req.accountMobile = '0400000000';
        req.opportunityName = 'test';

        // ACT

        OpportunityConversionController.ConvertLead(req);
        Test.stopTest();

        // ASSERT
    }
}