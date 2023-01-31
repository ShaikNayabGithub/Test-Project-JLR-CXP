/**
 * Created by caleb on 19/09/2019.
 */

@IsTest
public with sharing class Op2maControllerTest
{
    @IsTest
    public static List<Lead> generateLeads()
    {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 10; i++)
        {
            Lead lead = new Lead();
            lead.FirstName = 'Test';
            lead.LastName = 'Test' + i;
            lead.Purchase_Type__c = 'New Vehicle';
            lead.Email = 'test@test.com';
            lead.Enquiry_Type__c = 'Find & Price Enquiry';
            lead.Country_ISO_Code__c = 'AU';
            lead.LeadSource = 'OEM Web & Digital';
            lead.Concierge_Status__c = OP2MAController.CONCIERGE_STATUS_READY;
            lead.Do_Send_To_Vital__c = true;
            Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Lead.getRecordTypeInfosByName();
            lead.RecordTypeId = recordTypes.get('Generic').getRecordTypeId();
            leads.add(lead);
        }
        insert leads;
        return leads;
    }

    @IsTest
    public static List<Opportunity> generateOpportunities()
    {
        List<Opportunity> opps = TestClass_OpportunityCreator.createOppList_Australia(1);
        for (Opportunity o : opps)
        {
            o.StageName = Op2maController.OPPORTUNITY_STAGE_LOST;
            o.Agency_Loss_Type__c = 'Brand Image';
            o.Agency_Loss_Description__c = 'Test';
            o.Agency_Loss_Category__c = 'Experience';
            o.Country_ISO_Code__c = 'AU';
            o.Do_Send_To_Vital__c = true;
            o.LeadSource = 'OEM Web & Digital';
            o.Brand__c = TestClass_VehicleSpecificationBuilder.BuildLandRoverMake().Id;
            Account a = TestClass_AccountCreator.CreateRetailer();
            Account parentRetailer = TestClass_AccountCreator.CreateRetailer();
            a.ParentId = parentRetailer.Id;
            //a.Primary_Account__c = TestClass_AccountCreator.GenerateCorporateAccount().Id;
            update a;
            Contact c = TestClass_ValidContactBuilder.Build(parentRetailer);

            User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
            System.runAs (thisUser)
            {
                o.OwnerId = TestClass_UserCreator.CreateRetailerUser(c).Id;
            }

            o.Date_Lost__c = Date.today().addDays(-1);
        }
        update opps;
        return opps;
    }

    @IsTest
    public static void getLostOpportunitiesTest()
    {
        // ARRANGE
        generateOpportunities();
        GetLostOpportunitiesRequestDto request = new GetLostOpportunitiesRequestDto();

        // ACT
        Test.startTest();
        GetLostOpportunitiesResponseDto response = OP2MAController.getLostOpportunities(request);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.Data);
        System.assertEquals(1, response.Data.size());
        System.assertNotEquals(null, response.Data[0]);
    }

    @IsTest
    public static void updateLostOpportunitiesTest()
    {
        // ARRANGE
        generateOpportunities();
        // simulates the request that would usually run before an update request
        GetLostOpportunitiesRequestDto getRequest = new GetLostOpportunitiesRequestDto();
        GetLostOpportunitiesResponseDto getResponse = OP2MAController.getLostOpportunities(getRequest);

        List<String> opportunitiesToUpdate = new List<String>();
        for (OpportunityLostDataDto o : getResponse.Data)
        {
            opportunitiesToUpdate.add(o.Id);
        }
        UpdateLostOpportunitiesRequestDto request = new UpdateLostOpportunitiesRequestDto();
        request.OpportunityIds = opportunitiesToUpdate;

        // ACT
        Test.startTest();
        UpdateLostOpportunitiesResponseDto response = OP2MAController.updateLostOpportunities(request);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, response);
        System.assertEquals(true, response.IsSuccess);
        List<Opportunity> oppsToCheck = [SELECT Id, Sent_to_lost_opportunities__c FROM Opportunity];
        System.assertEquals(1, oppsToCheck.size());
        System.assertEquals(true, oppsToCheck[0].Sent_to_lost_opportunities__c);
    }

    @IsTest
    public static void getConciergeLeadsTest()
    {
        // ARRANGE
        generateLeads();
        GetLeadsRequestDto request = new GetLeadsRequestDto();

        // ACT
        Test.startTest();
        GetLeadsResponseDto response = OP2MAController.getConciergeLeads(request);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.Data);
        System.assertEquals(10, response.Data.size());
        System.assertNotEquals(null, response.Data[0]);
    }

    @IsTest
    public static void updateConciergeLeadsTest()
    {
        // ARRANGE
        generateLeads();
        GetLeadsRequestDto getRequest = new GetLeadsRequestDto();
        GetLeadsResponseDto getResponse = OP2MAController.getConciergeLeads(getRequest);
        List<String> leadsToUpdate = new List<String>();
        for (LeadConciergeDataDto l : getResponse.Data)
        {
            leadsToUpdate.add(l.Id);
        }

        UpdateConciergeLeadsRequestDto request = new UpdateConciergeLeadsRequestDto();
        request.LeadIds = leadsToUpdate;

        // ACT
        Test.startTest();
        UpdateConciergeLeadsResponseDto response = OP2MAController.updateConciergeLeads(request);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, response);
        System.assertEquals(true, response.IsSuccess);
        List<Lead> leadsToCheck = [SELECT Id, Concierge_Status__c FROM Lead];
        System.assertEquals(10, leadsToCheck.size());
        System.assertEquals(OP2MAController.CONCIERGE_STATUS_SENT, leadsToCheck[0].Concierge_Status__c);

    }
}