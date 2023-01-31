@IsTest
public class CorporatePartnersControllerTest {


    /*
    @IsTest
    private static void  setOpportunityCorporatePartnerTest(){
    	//ARRANGE
        Id pricebookId = Test.getStandardPricebookId();
    	Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account corpPartner = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        corpPartner.NSC_Supported__c = true;
        update corpPartner;

        PricebookEntry vehPbe = new PricebookEntry();
        vehPbe.Pricebook2Id = pricebookId;
        vehPbe.Product2Id = ass.Derivative__c;
        vehPbe.UnitPrice = 0;
        insert vehPbe;

        TestClass_OfferBuilder.createCorporateOffersList(ass.Derivative__c, corpPartner.Id, 1);
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity();
        //Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook('Australia');

    	SetCorporatePartnerRequestDto request = new SetCorporatePartnerRequestDto();
        request.OpportunityId = opp.Id;
        request.CorporatePartnerId = corpPartner.Id;
        request.PricebookId = pricebookId;
      	SetCorporatePartnerResponseDto response =  null;
        
        //ACT
        Test.startTest();
        response = CorporatePartnersController.setOpportunityCorporatePartner(request);
        Test.stopTest();
        
        //ASSERT
        System.assertNotEquals(null, response);
    }
*/
    @IsTest
    private static void dtoTests(){
        GetPricebookEntryResponseDto dummy = new GetPricebookEntryResponseDto();
        dummy.PricebookEntry = new PricebookEntry();
        dummy.Errors = new List<ErrorDto>();

        SetCorporatePartnerResponseDto dto = new SetCorporatePartnerResponseDto();
        dto.OpportunityLineItemId = 'xxx';
        dto.PricebookEntryId = 'yyy';
        dto.ServicePlanId = 'zzz';

        SetServicePlanResponseDto resp = new SetServicePlanResponseDto();
        resp.OpportunityLineItemId = 'xxx';
        resp.Message = 'yyy';
    }

    @IsTest
    private static void  setOpportunityCorporatePartnerTest2(){
        //ARRANGE
        Id pricebookId = Test.getStandardPricebookId();
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account corpPartner = TestClass_AccountCreator.GenerateCorporateAccount();
        corpPartner.NSC_Supported__c = true;
        update corpPartner;

        List<Offers__c> offers = TestClass_OfferBuilder.createCorporateOffersList(ass.Derivative__c, corpPartner.Id, 1);
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity();


        SetCorporatePartnerRequestDto request = new SetCorporatePartnerRequestDto();
        request.OpportunityId = opp.Id;
        request.PricebookId = pricebookId;
        request.VariantId = ass.Derivative__c;
        SetCorporatePartnerResponseDto response =  null;

        //ACT
        Test.startTest();
        response = CorporatePartnersController.setOpportunityCorporatePartner(request);
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(null, response);
    }

}