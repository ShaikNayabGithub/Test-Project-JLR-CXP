public without sharing class ProductsController {

    @AuraEnabled(Cacheable=true)
    public static GetProductsResponseDto getProducts(GetProductsRequestDto request){
        GetProductsResponseDto dto = new GetProductsResponseDto();
        dto.Products = getProductsList(request.MaxResults);
        System.debug(dto);
        return dto;
    }

    //todo - make private once dev finished
    public static List<Product2> getProductsList(Integer maxResults){
        List<Product2> products = [
                SELECT
                        Id,
                        Name,
                        ProductCode,
                        IsActive,
                        Make__c,
                        Make__r.Name,
                        Model__c,
                        Model__r.Name,
                        ToLabel(Body_Style__c),
                        ToLabel(Engine__c),
                        ToLabel(Wheel_Base__c),
                        ToLabel(Wheel_Driven__c),
                        ToLabel(Transmission__c),
                        Transmission_Alternative__c,
                        Specification_Pack_Alternative__c,
                        Power_Output_Alternative__c,
                        Engine_Type_Alternative__c,
                        ToLabel(VFACTS_Body_Style__c),
                        Product_Description__c,
                        Model_Year__c,
                        Doors__c,
                        Seats__c

                FROM Product2
                WHERE RecordType.DeveloperName = 'Derivative'
                LIMIT :maxResults
        ];
        return products;
    }


    // Make / Brand
    @AuraEnabled(Cacheable=true)
    public static List<Vehicle_Specification__c> getMakes() {
        return [
                //As Per Alex Nicholas
                SELECT Id,Name
                FROM Vehicle_Specification__c
                WHERE aop_JLR_Owned__c = TRUE
                ORDER BY Name ASC
        ];
    }

    @Future
    private static void updateInterestedBrand(Id opId, Id makeId) {
        Opportunity opp = new Opportunity(Id = opId);
        opp.Brand__c = makeId;
        // Required in case variant selector is repeated.
        update opp;
    }

    // Model
    @AuraEnabled(Cacheable=true)
    public static List<Vehicle_Specification__c> getModels()
    {
        return [
                SELECT Id, Name, Is_Australia__c, Make__c
                FROM Vehicle_Specification__c
                WHERE RecordType.Name = 'Model'
                AND Is_Australia__c = TRUE
                ORDER BY Name ASC
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Product2> getVariants2(string modelId)
    {
        Vehicle_Specification__c vsToMatch = [
                SELECT Id, Name
                FROM Vehicle_Specification__c
                WHERE Id = :modelId
                LIMIT 1
        ];

        Pricebook2 australianPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Australia'];
        return [
                SELECT
                        Id,
                        Name,
                        ProductCode,
                        Model_Alternative__c,
                        Service_Plan__c,
                        Make__c,
                        Model__c,
                        Body_Style__c,
                        BodyStyle_Alternative__c,
                        Engine__c,
                        Wheel_Base__c,
                        Wheel_Driven__c,
                        Transmission__c,
                        Transmission_Alternative__c,
                        Specification_Pack_Alternative__c,
                        Power_Output_Alternative__c,
                        Product_Description__c,
                        Engine_Type_Alternative__c,
                        VFACTS_Body_Style__c,
                        Model_Year__c,
                        Model_Year_Alternative_CXP__c,
                        Doors__c,
                        Seats__c
                FROM Product2
                WHERE RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT
                AND Model_Alternative__c = :vsToMatch.Name
                AND Id IN (
                        SELECT
                            Product2Id
                        FROM PricebookEntry
                        WHERE Pricebook2Id = :australianPricebook.Id
                        AND IsDeleted = FALSE
                        AND IsActive = TRUE
                )
                ORDER BY Name
        ];
    }

    @AuraEnabled
    public static void setModel(string opportunityId, string modelId)
    {
        Opportunity opp = new Opportunity();
        opp.Id = opportunityId;
        opp.Primary_Model_Interest__c = modelId;
        update opp;

        // delete varient olis
        List<OpportunityLineItem> varientOlis = [
                SELECT
                        Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
        ];
        delete varientOlis;
    }

    @AuraEnabled
    public static void setMakeAndModel(string opportunityId, string modelId, string makeId)
    {
        Opportunity opp = new Opportunity();
        opp.Id = opportunityId;
        opp.Brand__c = makeId;
        opp.Primary_Model_Interest__c = modelId;
        update opp;

        // delete varient olis
        List<OpportunityLineItem> varientOlis = [
                SELECT
                        Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
        ];
        delete varientOlis;
    }

    @AuraEnabled
    public static void setMake(string opportunityId, string makeId)
    {
        Opportunity opp = new Opportunity();
        opp.Id = opportunityId;
        opp.Brand__c = makeId;
        opp.Primary_Model_Interest__c = null;
        update opp;

        // delete varient olis
        List<OpportunityLineItem> varientOlis = [
                SELECT
                        Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
        ];
        delete varientOlis;
    }

    @AuraEnabled
    public static void setVariant(string opportunityId, string variantId)
    {
        // delete existing variant olis
        List<OpportunityLineItem> varientOlis = [
                SELECT
                        Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
        ];
        delete varientOlis;

        if (variantId == null) return; // if we are removing the variant we just have to delete the olis

        List<string> types = new List<string>
        {
                Constants.SERVICE_PLAN_TYPE_COMPLIMENTARY,
                Constants.SERVICE_PLAN_TYPE_CORPORATE
        };
        List<Offers__c> offers = [
                SELECT
                        Id,
                        Name,
                        Derivative_Product2Id__c,
                        Derivative_Product2Id__r.Service_Plan__c,
                        Service_Plan_Product2Id__r.Name,
                        Discount__c,
                        Corporate_Partner__c,
                        Corporate_Partner__r.Name,
                        Discount_Percent__c,
                        Eligible_Sale_Types__c,
                        Qantas_Points__c,
                        Service_Plan_Product2Id__c,
                        Minimum_Purchase_Price__c,
                        Type__c,
                        Make__c,
                        IsActive__c,
                        End_Date__c,
                        Start_Date__c
                FROM Offers__c
                WHERE Derivative_Product2Id__c = :variantId
                AND Type__c IN :types
                AND (End_Date__c > TODAY OR End_Date__c = NULL)
                AND Start_Date__c < TODAY
                AND IsActive__c = TRUE
                ORDER BY Corporate_Partner__r.Name, Name
        ];

        Opportunity opp = [
                SELECT Corporate_Partner_Account__c
                FROM Opportunity
                WHERE Id = :opportunityId
        ];

        OpportunityLineItem servicePlanOli;
        for (Offers__c offer : offers)
        {
            if (offer.Type__c == Constants.SERVICE_PLAN_TYPE_CORPORATE
                    && offer.Corporate_Partner__c == opp.Corporate_Partner_Account__c)
            {
                servicePlanOli = new OpportunityLineItem();
                servicePlanOli.Product2Id = offer.Derivative_Product2Id__r.Service_Plan__c;
                servicePlanOli.OpportunityId = opportunityId;
                servicePlanOli.Assignment_Type__c = offer.Type__c;
                servicePlanOli.TotalPrice = 0;
                servicePlanOli.Quantity = 1;
            }
            if (servicePlanOli == null && offer.Type__c == Constants.SERVICE_PLAN_TYPE_COMPLIMENTARY)
            {
                servicePlanOli = new OpportunityLineItem();
                servicePlanOli.Product2Id = offer.Derivative_Product2Id__r.Service_Plan__c;
                servicePlanOli.OpportunityId = opportunityId;
                servicePlanOli.Assignment_Type__c = offer.Type__c;
                servicePlanOli.TotalPrice = 0;
                servicePlanOli.Quantity = 1;
            }
        }

        OpportunityLineItem variantOli = new OpportunityLineItem();
        variantOli.Product2Id = variantId;
        variantOli.OpportunityId = opportunityId;
        variantOli.TotalPrice = 0;
        variantOli.Quantity = 1;


        List<OpportunityLineItem> olisToInsert;
        if (servicePlanOli != null)
        {
            olisToInsert = new List<OpportunityLineItem> {servicePlanOli, variantOli};
        }
        else
        {
            olisToInsert = new List<OpportunityLineItem> {variantOli};
        }

        // populate pbe's
        List<string> productIds = new List<String>();
        for (OpportunityLineItem oli : olisToInsert) productIds.add(oli.Product2Id);

        Pricebook2 australianPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Australia'];
        List<PricebookEntry> pbes = [
                SELECT Id, Product2Id
                FROM PricebookEntry
                WHERE Product2Id IN :productIds
                AND Pricebook2Id = :australianPricebook.Id
        ];

        // generate pbe map
        Map<Id, PricebookEntry> prodToPbeMap = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : pbes)
        {
            prodToPbeMap.put(pbe.Product2Id, pbe);
        }

        // set PriceBookEntry
        for (OpportunityLineItem oli : olisToInsert)
        {
            if (prodToPbeMap.containsKey(oli.Product2Id))
            {
                oli.PricebookEntryId = prodToPbeMap.get(oli.Product2Id).Id;
            }
        }

        insert olisToInsert;
    }



    /**
    private static List<SimpleResourceDto> getPicklistVals(Schema.DescribeFieldResult fieldResult) {
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        List<SimpleResourceDto> dtos = new List<SimpleResourceDto>();
        for (Schema.PicklistEntry f : picklistEntries) {
            SimpleResourceDto dto = new SimpleResourceDto();
            dto.Attributes.Name = f.getLabel();
            dto.Id = f.getValue();
            dtos.add(dto);
        }
        return dtos;
    }

    **/
}