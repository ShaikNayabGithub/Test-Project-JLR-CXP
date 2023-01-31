/**
 * Created by caleb on 3/09/2019.
 */

@isTest
public with sharing class OpportunityLineItemsControllerTest
{
    private static CreateOpportunityLineItemRequestDto generateCreateLineItemDto()
    {
        // Create an OpportunityLineItemAttributesDto's for every Opportunity
        // Set up SObjects
        TestClass_OpportunityCreator.createOppList();
        List<Opportunity> opps = [SELECT Id From Opportunity];
        Product2 derivative = TestClass_AssetBuilder.buildDerivative();

        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = derivative.Id,
                UnitPrice = 10000, CurrencyIsoCode = 'JPY', IsActive = true);
        insert standardPrice;

        // Setup Dto
        List<OpportunityLineItemResourceDto> resourceDtos = new List<OpportunityLineItemResourceDto>();
        for (Opportunity opp : opps)
        {

            OpportunityLineItemAttributesDto attributeDto = new OpportunityLineItemAttributesDto();
            attributeDto.OpportunityId = opp.Id;
            attributeDto.Quantity = 1;
            attributeDto.Product2Id = derivative.Id;
            attributeDto.IsVehicle = true;
            attributeDto.IsServicePlan = true;
            attributeDto.TotalPrice = 20000;
            attributeDto.PricebookEntryId = standardPrice.Id;

            OpportunityLineItemResourceDto resourceDto = new OpportunityLineItemResourceDto();
            resourceDto.Attributes = attributeDto;
            resourceDtos.add(resourceDto);
        }
        CreateOpportunityLineItemRequestDto req = new CreateOpportunityLineItemRequestDto();
        req.Data = resourceDtos;
        return req;
    }

    @isTest
    public static void createTest()
    {
        // ARRANGE
        CreateOpportunityLineItemRequestDto req = generateCreateLineItemDto();

        // ACT
        Test.startTest();
        CreateOpportunityLineItemResponseDto res = OpportunityLineItemsController.create(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertEquals(10, [SELECT Id FROM OpportunityLineItem].size());
    }

    @IsTest
    public static void removeTest()
    {
        // ARRANGE
        CreateOpportunityLineItemRequestDto createRequest = generateCreateLineItemDto();
        OpportunityLineItemsController.create(createRequest);
        OpportunityLineItem ItemToDelete = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        SimpleResourceDto resourceDto = new SimpleResourceDto();
        resourceDto.Id = ItemToDelete.Id;
        DeleteOpportunityLineItemRequestDto req = new DeleteOpportunityLineItemRequestDto();
        req.Data = new List<SimpleResourceDto>{resourceDto};

        // ACT
        Test.startTest();
        DeleteOpportunityLineItemResponseDto res = OpportunityLineItemsController.remove(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertEquals(9, [SELECT Id FROM OpportunityLineItem].size());
    }


    @IsTest
    public static void deleteAllTest()
    {
        // ARRANGE
        CreateOpportunityLineItemRequestDto createRequest = generateCreateLineItemDto();
        OpportunityLineItemsController.create(createRequest);

        DeleteOpportunityLineItemsRequestDto request = new DeleteOpportunityLineItemsRequestDto();
        request.OpportunityId = createRequest.Data[0].Attributes.OpportunityId;
        // ACT
        Test.startTest();
        DeleteOpportunityLineItemsResponseDto res = OpportunityLineItemsController.deleteAll(request);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertEquals(9, [SELECT Id FROM OpportunityLineItem].size());
    }

    @IsTest
    public static void getTest()
    {
        // ARRANGE
        CreateOpportunityLineItemRequestDto createRequest = generateCreateLineItemDto();
        OpportunityLineItemsController.create(createRequest);
        GetOpportunityLineItemsRequestDto req = new GetOpportunityLineItemsRequestDto();
        req.OpportunityId = [SELECT Id From Opportunity WHERE Name = 'Test0'].Id;
        String lineItemId = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :req.OpportunityId].Id;

        // ACT
        Test.startTest();
        GetOpportunityLineItemsResponseDto res = OpportunityLineItemsController.get(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        System.assertEquals(1, res.Data.size()); // only one opp has name Test0
        System.assertEquals(lineItemId, res.Data[0].Id);
    }
}