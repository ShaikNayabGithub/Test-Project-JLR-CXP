/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 7/02/2020.
 */
@IsTest
public with sharing class ProductTransformerTest {


    @IsTest
    private static void TransformVariantFromProduct2Test(){
        //ARRANGE
        Product2 prod = TestClass_AssetBuilder.buildDerivativeAustralia();
        List<Product2> products = new List<Product2>{prod};

        //ACT
        Test.startTest();
        List<VariantResourceDto> resources = ProductTransformer.transformVariants(products);
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(NULL, resources);
    }

    @IsTest
    private static void TransformVariantFromProduct2Test1(){
        //ARRANGE
        // ARRANGE
        Opportunity opp  = TestClass_OpportunityCreator.generateOpportunity();
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        opp.Pricebook2Id = pb.Id;
        update opp;
        GetProductsRequestDto req = new GetProductsRequestDto();
        req.MaxResults = 10;

        String makeId = TestClass_AssetBuilder.generateVehicleSpecification('Land Rover');
        List<PricebookEntry> entries = new List<PricebookEntry>();
        for (Integer i = 0; i < 11; i++) {
            Id modelId = TestClass_AssetBuilder.generateModels('Model' + i, makeId);
            Product2 prod = TestClass_AssetBuilder.generateDerivative(modelId, makeId);
            PricebookEntry pbe = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(pb, prod);
            entries.add(pbe);
        }

        //ACT
        Test.startTest();
        List<VariantResourceDto> resources = ProductTransformer.transformVariants(entries);
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(NULL, resources);
    }
}