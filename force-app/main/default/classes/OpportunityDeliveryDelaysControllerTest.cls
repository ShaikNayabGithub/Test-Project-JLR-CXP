/**
 * Created by caleb@argologic.com.au on 17/06/2021.
 */

@IsTest
public with sharing class OpportunityDeliveryDelaysControllerTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        Opportunity opp = TestClass_ValidOpportunityBuilder.opportunityWithLineItem();
        Vehicle_Specification__c vs = TestClass_VehicleSpecificationBuilder.BuildModel([SELECT Id FROM Vehicle_Specification__c LIMIT 1]);

        opp.Primary_Model_Interest__c = vs.Id;
        update opp;

        // ACT
        Test.startTest();
        List<OpportunityDeliveryDelayAttributeDto> res = OpportunityDeliveryDelaysService.get();
        Test.stopTest();

        System.assertEquals(1, res.size());
    }

    @IsTest
    public static void test2()
    {
        // ARRANGE
        Opportunity opp = TestClass_ValidOpportunityBuilder.opportunityWithLineItem();
        Vehicle_Specification__c vs = TestClass_VehicleSpecificationBuilder.BuildModel([SELECT Id FROM Vehicle_Specification__c LIMIT 1]);

        opp.Primary_Model_Interest__c = vs.Id;
        update opp;
        
        Test.startTest();
        List<OpportunityDeliveryDelayAttributeDto> res = OpportunityDeliveryDelaysService.get();
        List<String> req = new List<String>();
        for (OpportunityDeliveryDelayAttributeDto r : res)
        {
            req.add(r.OpportunityId);
        }

        // ACT

        OpportunityDeliveryDelaysService.post(req);
        Test.stopTest();

        System.assertEquals(1, res.size());
    }
}