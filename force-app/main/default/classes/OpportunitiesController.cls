//noinspection SpellCheckingInspection

@SuppressWarnings('ApexIllegalAssignment')
global with sharing class OpportunitiesController {

    private static final String PRICEBOOK2_NAME = 'Australia';

    private static final List<String> buildDefaultOfferTypeNames = new List<String>{
            Constants.SERVICE_PLAN_TYPE_COMPLIMENTARY,
            Constants.SERVICE_PLAN_TYPE_CORPORATE
    };
    private static final String SALE_TYPE_NEW = 'New';
    private static final String SALE_TYPE_DEMONSTRATOR = 'Demonstrator';
    private static final String SALE_TYPE_DEMO = 'Demo';
    private static final String SALE_TYPE_PREOWNED = 'Pre_Owned';
    private static final String SALE_TYPE_APPROVED_PRE_OWNED = 'Approved_Pre_Owned';

    private static final String PURCHASE_TYPE_NEW = 'New Vehicle';
    private static final String PURCHASE_TYPE_USED = 'Used Vehicle';

    public static final String OPPORTUNITY_STAGE_LOST = 'Lost';
    public static final String OPPORTUNITY_STAGE_WON = 'Won';
    public static final String OPPORTUNITY_STAGE_Handover_RDA = 'Handover & RDA';

    @AuraEnabled (Cacheable=true)
    public static List<SaleDto> getSaleTypes() {
        Schema.DescribeFieldResult fieldResult = Opportunity.Sale_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        List<SaleDto> dtos = new List<SaleDto>();
        for (Schema.PicklistEntry f : picklistEntries) {
            SaleDto dto = new SaleDto();
            dto.Attributes.Name = f.getLabel();
            dto.Attributes.Name = f.getLabel();
            dto.Id = f.getValue();
            dtos.add(dto);
        }
        return dtos;
    }

    @AuraEnabled
    public static SyncOpportunityToDmsResponseDto sendOpportunityToDms(SyncOpportunityToDmsRequestDto request) {
        SyncOpportunityToDmsResponseDto response = new SyncOpportunityToDmsResponseDto();
        try {
            if (String.isBlank(request.OpportunityId)) {
                NullRequiredFieldException ex = new NullRequiredFieldException();
                ex.setMessage('OpportunityId is required');
                throw ex;
            }
            GetNidasuOpportunityRequestDto sendNidasuOpportunityRequestDto = new GetNidasuOpportunityRequestDto();
            sendNidasuOpportunityRequestDto.OpportunityId = request.OpportunityId;
            String result = NidasuOpportunityController.sendOpportunity(sendNidasuOpportunityRequestDto);
            response.Message = result;
        } catch (Exception ex) {
            response.addError(ex);
        }
        return response;
    }


    @AuraEnabled
    public static SetOpportunityAssetResponseDto setAsset(SetOpportunityAssetRequestDto request) {
        System.debug('>> setAsset()');
        System.debug('request : ' + JSON.serialize(request, true));
        SetOpportunityAssetResponseDto response = new SetOpportunityAssetResponseDto();
        try {
            GetOpportunityLineItemsResponseDto existingItemsResponse = getExistingItems(Id.valueOf(request.OpportunityId));
            System.debug('ExistingItems: ' + JSON.serialize(existingItemsResponse, true));
            for (OpportunityLineItemResourceDto resource : existingItemsResponse.Data) {
                response.AddInfo('oli.id = ' + resource.Id);
                if (resource.Attributes.IsVehicle) {
                    System.debug('This resource is a vehicle: ' + JSON.serialize(resource, true));
                    Database.SaveResult result = null;
                    try {
                        result = AssetsController.addAssetToOpportunityLineItem(resource.Id, request.AssetId);
                    } catch (Exception assetAddEx) {
                        response.addError(assetAddEx);
                    }
                    if (result != null && !result.isSuccess()) {
                        System.debug('Error updating line item with asset: ' + JSON.serialize(result, true));
                        response.addErrors(result.errors);
                    }
                }
                else if (resource.Attributes.IsServicePlan && ServicePlanController.hasExistingServicePlan(request.AssetId))
                {
                    response.AddInfo('delete oli.id = ' + resource.Id);
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.Id = resource.Id;
                    delete oli;
                }
            }
            return response;
        } catch (Exception ex) {
            response.addError(ex);
        }
        System.debug('<< setAsset()');
        System.debug('response : ' + JSON.serialize(response, true));
        return response;
    }

    @AuraEnabled(Cacheable=false)
    public static GetOpportunityMilestonesResponseDto getMilestones(GetOpportunityMilestonesRequestDto request) {
        GetOpportunityMilestonesResponseDto response = new GetOpportunityMilestonesResponseDto();

        Flow.Interview flow = new Flow.Interview.Opportunity_Get_Milestones (new Map<String, Object>{
                'recordId' => request.OpportunityId,
                'recordTypeIdMilestoneEvent' => Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Milestone_Event').getRecordTypeId(),
                'recordTypeIdMilestoneTask' => Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Milestone_Task').getRecordTypeId()
        });
        flow.start();


        //Qualified
        Boolean isQualifiedComplete = (Boolean) flow.getVariableValue('isQualifiedComplete');
        Boolean isQualifiedInProgress = (Boolean) flow.getVariableValue('isQualifiedInProgress');
        String qualifiedId = (Id) flow.getVariableValue('qualifiedId');

        //TestDrive
        Boolean isTestDriveComplete = (Boolean) flow.getVariableValue('isTestDriveComplete');
        Boolean isTestDriveInProgress = (Boolean) flow.getVariableValue('isTestDriveInProgress');
        String testDriveId = (Id) flow.getVariableValue('testDriveId');

        //VehicleSelection
        Boolean isVehicleSelectionComplete = (Boolean) flow.getVariableValue('isVehicleSelectionComplete');
        Boolean isVehicleSelectionInProgress = (Boolean) flow.getVariableValue('isVehicleSelectionInProgress');
        String vehicleSelectionId = (Id) flow.getVariableValue('vehicleSelectionId');

        //Appraisal
        Boolean isAppraisalComplete = (Boolean) flow.getVariableValue('isAppraisalComplete');
        Boolean isAppraisalInProgress = (Boolean) flow.getVariableValue('isAppraisalInProgress');
        String appraisalId = (Id) flow.getVariableValue('appraisalId');

        //Negotiation
        Boolean isNegotiationComplete = (Boolean) flow.getVariableValue('isNegotiationComplete');
        Boolean isNegotiationInProgress = (Boolean) flow.getVariableValue('isNegotiationInProgress');
        String negotiationId = (Id) flow.getVariableValue('negotiationId');
        System.debug('negotiationId = ' + negotiationId);

        //Order Taken
        Boolean isOrderTakenComplete = (Boolean) flow.getVariableValue('isOrderTakenComplete');
        Boolean isOrderTakenInProgress = (Boolean) flow.getVariableValue('isOrderTakenInProgress');
        String orderTakenId = (Id) flow.getVariableValue('orderTakenId');

        //Handover
        Boolean isHandoverComplete = (Boolean) flow.getVariableValue('isHandoverComplete');
        Boolean isHandoverInProgress = (Boolean) flow.getVariableValue('isHandoverInProgress');
        String handoverId = (Id) flow.getVariableValue('handoverId');


        //System.debug(dto);


        //Qualified
        if (isQualifiedComplete) {
            response.IsQualificationComplete = true;
        } else if (isQualifiedInProgress) {
            response.IsQualificationInProgress = true;
        }
        response.QualificationId = qualifiedId;

        //Test Drive
        if (isTestDriveComplete) {
            response.IsTestDriveComplete = true;
        } else if (isTestDriveInProgress) {
            response.IsTestDriveInProgress = true;
        }
        response.TestDriveId = testDriveId;

        //Vehicle Selection
        if (isVehicleSelectionComplete) {
            response.IsVehicleSelectionComplete = true;
        } else if (isVehicleSelectionInProgress) {
            response.IsVehicleSelectionInProgress = true;
        }
        response.VehicleSelectionId = vehicleSelectionId;

        //Appraisal
        if (isAppraisalComplete) {
            response.IsAppraisalComplete = true;
        } else if (isAppraisalInProgress) {
            response.IsAppraisalInProgress = true;
        }
        response.AppraisalId = appraisalId;

        //Negotiation
        if (isNegotiationComplete) {
            response.IsNegotiationComplete = true;
        } else if (isNegotiationInProgress) {
            response.IsNegotiationInProgress = true;
        }
        response.NegotiationId = negotiationId;

        //Order Taken
        if (isOrderTakenComplete) {
            response.IsOrderTakenComplete = true;
        } else if (isOrderTakenInProgress) {
            response.IsOrderTakenInProgress = true;
        }
        response.OrderTakenId = orderTakenId;

        //Handover
        if (isHandoverComplete) {
            response.IsHandoverComplete = true;
        } else if (isHandoverInProgress) {
            response.IsHandoverInProgress = true;
        }
        response.HandoverId = handoverId;

        return response;
    }

    @AuraEnabled(Cacheable=false)
    public static GetOpportunityDataResponseDto getOpportunityData(string oppId)
    {
        List<Opportunity> opps = [
                SELECT
                        Id,
                        Name,
                        Status__c,
                        AccountId,
                        Account.LastName,
                        Account.Name,
                        Account.IsPersonAccount,
                        CloseDate,
                        Initial_Sale_Type__c,
                        Pricebook2Id,
                        StageName,
                        (
                              SELECT
                                      Id,
                                      Name
                              FROM RDAs__r
                              WHERE Submitted_Status__c != 'Cancelled'
                        ),
                        Corporate_Partner_Account__c,
                        Corporate_Partner_Account__r.Name,
                        Primary_Contact__r.MobilePhone,
                        Primary_Contact__r.Name,
                        Primary_Contact__r.Email,
                        Primary_Contact__c,
                        Primary_Model_Interest__c,
                        Primary_Model_Interest__r.Name,
                        Brand__c,
                        Brand__r.Name,
                        LeadSource,
                        Enquiry_Type__c,
                        IsClosed,
                        Sale_Type__c
                FROM Opportunity
                WHERE Id = :oppId
        ];
        if (opps.size() == 0) throw new JlrCustomException('No Opportunity With the given Id');
        Opportunity opp = opps[0];

        // get both vehicle and service plan olid
        List<OpportunityLineItem> olis = [
                SELECT
                        Id,
                        Product2Id,
                        Product2.Product_Description__c,
                        Product2.Name,
                        Assignment_Type__c,
                        Asset__c,
                        Product2.RecordType.DeveloperName,
                        Product2.Engine_Type_Alternative__c,
                        Product2.Model_Year__c,
                        Asset__r.VIN__c,
                        Asset__r.Name,
                        Asset__r.Is_Ex_demo__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :oppId
                AND (Product2.RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_PRODUCT2_SERVICE_PLAN
                OR Product2.RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT)
        ];



        GetOpportunityDataResponseDto res = new GetOpportunityDataResponseDto();
        // opp Info
        res.OpportunityId = opp.Id;
        res.OpportunityName = opp.Name;
        res.OpportunityStage = opp.StageName;
        res.OpportunityClosedDate = opp.CloseDate;
        res.OpportunityLeadSource = opp.LeadSource;
        res.OpportunityEnquiryType = opp.Enquiry_Type__c;
        res.OpportunitySaleType = opp.Sale_Type__c;
        res.OpportunityInitialSaleType = opp.Initial_Sale_Type__c?.replace('_', ' ');
        res.OpportunityIsClosed = opp.IsClosed;

        res.MakeName = opp.Brand__r.Name;
        res.MakeId = opp.Brand__c;
        res.ModelName = opp.Primary_Model_Interest__r.Name;
        res.ModelId = opp.Primary_Model_Interest__c;

        // account contact Info
        res.IsPersonAccount = opp.Account.IsPersonAccount;
        res.AccountName = opp.Account.Name;
        res.AccountId = opp.AccountId;
        res.ContactName = opp.Primary_Contact__r.Name;
        res.ContactId = opp.Primary_Contact__c;
        res.Mobile = opp.Primary_Contact__r.MobilePhone;
        res.Email = opp.Primary_Contact__r.Email;

        res.Pricebook2Id = opp.Pricebook2Id;

        if (opp.RDAs__r.size() > 0)
        {
            res.OpportunityHasBeenRdad = true;
            res.RdaName = opp.RDAs__r[0].Name;
            res.RdaId = opp.RDAs__r[0].Id;
        }
        else
        {
            res.OpportunityHasBeenRdad = false;
        }

        if (opp.Corporate_Partner_Account__c != null)
        {
            res.HasCorporatePartner = true;
            res.CorporatePartnerId = opp.Corporate_Partner_Account__c;
            res.CorporatePartnerName = opp.Corporate_Partner_Account__r.Name;
        }

        res.HasServicePlan = false;
        // set derivative and service plan
        for (OpportunityLineItem oli : olis)
        {
            if (oli.Product2.RecordType.DeveloperName == Constants.RECORD_TYPE_NAME_PRODUCT2_SERVICE_PLAN)
            {
                res.HasServicePlan = true;
                res.ServicePlanType = oli.Assignment_Type__c;
                res.ServicePlanId = oli.Product2Id;
                res.ServicePlanName = oli.Product2.Name;
            }
            else
            {
                // set service plan if not already set
                if (!res.HasServicePlan)
                {
                    List<Service_Plan_Contract__c> servicePlanContracts = [
                            SELECT
                                    Id,
                                    Service_Plan_Product__r.Name,
                                    Service_Plan_Product__c
                            FROM Service_Plan_Contract__c
                            WHERE Vehicle_Id__c = :oli.Asset__c
                    ];
                    if (servicePlanContracts.size() > 0)
                    {
                        res.HasServicePlan = true;
                        res.ServicePlanType = 'Existing';
                        res.ServicePlanId = servicePlanContracts[0].Service_Plan_Product__c;
                        res.ServicePlanName = servicePlanContracts[0].Service_Plan_Product__r.Name;
                    }
                }
                // set derivative info
                res.DerivativeName = oli.Product2.Product_Description__c;
                res.DerivativeId = oli.Product2Id;
                res.DerivativeEngine = oli.Product2.Engine_Type_Alternative__c;
                res.DerivativeModelYear = oli.Product2.Model_Year__c;

                if (oli.Asset__c != null)
                {
                    res.HasAsset = true;
                    res.AssetId = oli.Asset__c;
                    res.AssetName = oli.Asset__r.Name;
                    res.Isexdemo = oli.Asset__r.Is_Ex_demo__c;
                    System.debug('Exdemo value :' +  res.Isexdemo);
                }
            }
        }

        Affinity_Program_Status__mdt ps = [
                SELECT Id, Affinity_Disabled__c, Disabled_Message__c
                FROM Affinity_Program_Status__mdt
                LIMIT 1
        ];
        if (ps != null)
        {
            res.CorporateEligibilityEnabled = !ps.Affinity_Disabled__c;
            res.CorporateEligibilityMessage = ps.Disabled_Message__c;
        }


        return res;
    }


    @AuraEnabled(Cacheable=false)
    public static SetVariantResponseDto setVariant(SetVariantRequestDto request) {
        System.debug('>> setVariant(request)');
        System.debug('request.VariantId : ' + request.VariantId);
        System.debug('request.Opportunity : ' + request.OpportunityId);
        System.debug('request.Pricebook2Id: ' + request.PricebookId);
        System.debug('request.PricebookEntryId :' + request.PricebookEntryId);
        System.debug('request.TypeNames :' + JSON.serialize(request.TypeNames));


        if (ListUtils.isNullOrEmpty(request.TypeNames)) {
            request.TypeNames = buildDefaultOfferTypeNames;
        }
        SetVariantResponseDto response = new SetVariantResponseDto();
        try {
            //Get a list of existing Opportunity Products
            GetOpportunityLineItemsResponseDto existingItems = getExistingItems(request.OpportunityId);
            System.debug('Existing Item Count = ' + existingItems.Data.size());

            //Delete any existing vehicle and service plans from the Opportunity Product List
            deleteVariantRelatedLineItems(existingItems, true, true);

            //Insert the newly selected variant into the list of Opportunity Products
            CreateOpportunityLineItemRequestDto createRequest = buildLineItemRequestDto(request);

            //Todo: Optimize code to reduce database queries.
            //Corporate
            //Does Opportunity have Corporate Partner?
            String corporatePartnerId = request.CorporatePartnerId;
            if (String.isBlank(corporatePartnerId)) {
                corporatePartnerId = getCorporatePartnerIdForOpportunity(request.OpportunityId);
            }

            Boolean servicePlanAdded = false;
            if (String.isNotBlank(corporatePartnerId)) {
                GetPricebookEntryResponseDto pbeResponse = OffersController.getCorporateServicePlanPbe(request.VariantId, request.PricebookId);
                if (pbeResponse.IsSuccess) {
                    if (pbeResponse.PricebookEntry != null) {
                        PricebookEntry pbe = pbeResponse.PricebookEntry;
                        SetServicePlanRequestDto requestDto = new SetServicePlanRequestDto();
                        requestDto.OpportunityId = request.OpportunityId;
                        requestDto.ServicePlanId = pbe.Product2Id;
                        requestDto.PricebookEntryId = pbe.Id;
                        requestDto.ServicePlanType = Constants.SERVICE_PLAN_TYPE_CORPORATE;
                        SetServicePlanResponseDto responseDto = OpportunitiesController.setServicePlan(requestDto);
                        if (responseDto.IsSuccess && String.isNotBlank(responseDto.OpportunityLineItemId)) {
                            servicePlanAdded = true;
                            System.debug('A service plan has been added for the corporate partner. OLI: ' + responseDto.OpportunityLineItemId);
                        }
                    } else {
                        response.Errors.addAll(pbeResponse.Errors);
                    }

                }
            }
            if (!servicePlanAdded) {
                //Complimentary
                Offers__c complimentaryPlan = OffersController.getComplimentaryServicePlanOffer(request.VariantId);
                if (complimentaryPlan != null) {
                    System.debug('Complimentary Plan Found');
                    List<OpportunityLineItemResourceDto> lineItemResources = OffersController.buildOpportunityLineItemResourceDto(
                            new List<Offers__c>{
                                    complimentaryPlan
                            },
                            Id.valueOf(request.OpportunityId),
                            Id.valueOf(request.PricebookId)
                    );
                    createRequest.addItems(
                            lineItemResources
                    );


                } else {
                    System.debug('No Complimentary Plan Found');
                }
            }

            CreateOpportunityLineItemResponseDto createResponse = OpportunityLineItemsController.create(createRequest);
            existingItems = getExistingItems(request.OpportunityId);
            response = new SetVariantResponseDto(existingItems);
        } catch (Exception ex) {
            response.addErrors(ex);
        }
        System.debug('Response: ' + JSON.serialize(response));
        System.debug('<< setVariant()');
        return response;
    }

    private static Id getCorporatePartnerIdForOpportunity(String opportunityId) {
        List<Opportunity> opps = [SELECT Corporate_Partner_Account__c FROM Opportunity WHERE Id = :opportunityId];
        if (opps.size() >= 1)
        {
            return opps[0].Corporate_Partner_Account__c;
        }
        return null;
    }

    private static GetOpportunityLineItemsResponseDto getExistingItems(Id opportunityId) {
        GetOpportunityLineItemsRequestDto existingRequest = new GetOpportunityLineItemsRequestDto();
        existingRequest.OpportunityId = opportunityId;
        GetOpportunityLineItemsResponseDto existingItems = OpportunityLineItemsController.get(existingRequest);
        return existingItems;
    }

    @AuraEnabled(Cacheable=false)
    public static SetServicePlanResponseDto setServicePlan(SetServicePlanRequestDto request) {
        SetServicePlanResponseDto response = new SetServicePlanResponseDto();
        try {
            System.debug('>> setServicePlan(request: ' + request + ')');
            GetOpportunityLineItemsResponseDto existingItems = getExistingItems(request.OpportunityId);
            //Delete any existing service plans from the Opportunity Product List
            deleteVariantRelatedLineItems(existingItems, false, true);
            CreateOpportunityLineItemRequestDto createRequest = buildLineItemRequestDto(request);
            CreateOpportunityLineItemResponseDto createResponse = OpportunityLineItemsController.create(createRequest);
            if (createResponse.Data == null  || createResponse.Data.size() == 0 || createResponse.Data.size() > 1) {
                throw new JlrCustomException('CreateOpportunityLineItemResponseDto.Data should not be null');
            }

            response.OpportunityLineItemId = createResponse.Data[0].Id;
            response.Message = JSON.serialize(createResponse);
        } catch (Exception ex) {
            System.debug('Error' + ex.getStackTraceString());
            response.addError(ex);
        }
        System.debug('<< setServicePlan()');
        return response;
    }

    private static CreateOpportunityLineItemRequestDto buildLineItemRequestDto(SetVariantRequestDto request) {
        if (String.isBlank(request.PricebookId)) {
            InvalidParameterValueException ex = new InvalidParameterValueException('PricebookId', 'null or empty');
            throw ex;
        }

        if (String.isBlank(request.PricebookEntryId)) {


            //need to get PricebookEntryId
            try {
                PricebookEntry pbe = [
                        SELECT Id
                        FROM PricebookEntry
                        WHERE Product2Id = :request.VariantId
                        AND Pricebook2Id = :request.PricebookId
                        AND IsActive = TRUE
                        AND IsDeleted = FALSE
                        LIMIT 1
                ];
                request.PricebookEntryId = pbe.Id;
            } catch (Exception ex) {
                throw new JlrCustomException('Vehicle has no Active Australian Pricebook Entry');
            }
        }

        request.Qty = 1;
//Calculate Price
        request.TotalPrice = calculateTotalPrice(request.PricebookEntryId, request.Qty);
        return new CreateOpportunityLineItemRequestDto(request);
    }

    private static CreateOpportunityLineItemRequestDto buildLineItemRequestDto(SetServicePlanRequestDto request) {

        request.TotalPrice = calculateTotalPrice(request.PricebookEntryId, 1);
        CreateOpportunityLineItemRequestDto createRequest = new CreateOpportunityLineItemRequestDto(request);
        return createRequest;
    }

    private static void deleteVariantRelatedLineItems(
            GetOpportunityLineItemsResponseDto existingItems,
            Boolean doDeleteVehicles,
            Boolean doDeleteServicePlans
    ) {
        System.debug('>> deleteVariantRelatedLineItems()');
        System.debug('ExistingItems: ' + JSON.serialize(existingItems));
        System.debug('DoDeleteVehicles: ' + doDeleteVehicles);
        System.debug('DoDeleteServicePlans: ' + doDeleteServicePlans);
        DeleteOpportunityLineItemRequestDto deleteRequest = new DeleteOpportunityLineItemRequestDto();
        for (OpportunityLineItemResourceDto item : existingItems.Data) {
            if ((item.Attributes.IsVehicle && doDeleteVehicles) || (item.Attributes.IsServicePlan && doDeleteServicePlans)) {
                System.debug('Delete: ' + item.Id);
                deleteRequest.addItem(Id.valueOf(item.Id));
            }
        }
        DeleteOpportunityLineItemResponseDto deleteResponse = OpportunityLineItemsController.remove(deleteRequest);
        System.debug('DeleteResponse :' + JSON.serialize(deleteResponse));
    }


    @AuraEnabled(Cacheable=false)
    public static GetServicePlansResponseDto getServicePlans(GetServicePlansRequestDto request) {
        System.debug('>> GetServicePlans(request : ' + JSON.serialize(request) + ')');
        // Create a list of Service Plan Ids
        GetOffersRequestDto offersRequest = null;
        if (request.ServicePlanId == null)
        {
            // if we do not yet know the service plan for this varient we have to find it
            request.ServicePlanId = [SELECT Id, Service_Plan__c FROM Product2 WHERE Id = :request.VariantId].Service_Plan__c;
        }

        if (String.isBlank(request.CorporatePartnerId) && String.isNotBlank(request.OpportunityId)) {
            request.CorporatePartnerId = getCorporatePartnerIdForOpportunity(request.OpportunityId);
        }
        if (String.isNotBlank(request.CorporatePartnerId)) {
            offersRequest = new GetOffersRequestDto(Id.valueOf(request.ServicePlanId), request.TypeNames, request.CorporatePartnerId);
        } else {
            offersRequest = new GetOffersRequestDto(Id.valueOf(request.ServicePlanId), request.TypeNames);
        }


        List<OfferResourceDto> offers = (getOffers(offersRequest)).Data;
        System.debug('*** Offers Count: ' + offers.size());

        // select pbes as that is how retail plans are stored
        List<PricebookEntry> entries = new List<PricebookEntry>();
        if (new Set<String>(request.TypeNames).contains(Constants.SERVICE_PLAN_TYPE_RETAIL))
        {
            entries = [
                    SELECT
                            Id,
                            UnitPrice,
                            Product2.Name,
                            Product2.Service_Plan_Type__c,
                            Product2.Service_Plan_Description__c
                    FROM
                            PricebookEntry
                    WHERE
                    Product2Id = :request.ServicePlanId
                    AND
                    Pricebook2Id = :request.Pricebook2Id
                    AND IsActive = TRUE
                    AND IsDeleted = FALSE
            ];
        }

        GetServicePlansResponseDto res = new GetServicePlansResponseDto(offers, entries);
        for (ServicePlanResourceDto resource : res.Data) {
            resource.Attributes.OpportunityId = request.OpportunityId;
        }
        System.debug('response : ' + JSON.serialize(res));
        System.debug('<< GetServicePlans()');
        return res;
    }

    public static GetOffersResponseDto getOffers(GetOffersRequestDto request) {
        System.debug('>> getOffers()');
        System.debug('request: ' + JSON.serialize(request));
        GetOffersResponseDto response = OffersController.get(request);
        System.debug('response: ' + JSON.serialize(response));
        return response;
    }

    private static Decimal calculateTotalPrice(Id pricebookEntryId, Decimal qty) {
        List<PricebookEntry> entries = [
                SELECT Id, Name, Price_Excluding_GST__c, UnitPrice
                FROM PricebookEntry
                WHERE Id = :pricebookEntryId
                LIMIT 1
        ];

        Decimal total = 1;
        if (ListUtils.isNotNullOrEmpty(entries)) {
            PricebookEntry entry = entries[0];
            if (entry.Price_Excluding_GST__c != null) {
                total = entry.Price_Excluding_GST__c * qty;
            } else if (entry.UnitPrice != null) {
                total = entry.UnitPrice * qty;
            }
        }
        return total;
    }

    @AuraEnabled
    public static UpdateOpportunityResponseDto updateOpportunity(UpdateOpportunityRequestDto request) {
        UpdateOpportunityResponseDto response = new UpdateOpportunityResponseDto();
        try {
            if (String.isBlank(request.OpportunityId)) {
                NullRequiredFieldException ex = new NullRequiredFieldException();
                ex.setMessage('OpportunityId cannot be null');
                throw ex;
            }

            Opportunity op = new Opportunity();
            op.Id = request.OpportunityId;
//Sale Types
            String saleType = request.SaleType;
            if (isSaleTypeNew(saleType)) {
                op.Sale_Type__c = SALE_TYPE_NEW;
                op.Purchase_Type__c = PURCHASE_TYPE_NEW;
            } else if (isSaleTypeDemo(saleType)) {
                op.Sale_Type__c = SALE_TYPE_DEMONSTRATOR;
                op.Purchase_Type__c = PURCHASE_TYPE_USED;
            } else if (isSaleTypePreOwned(saleType)
                    ) {
                op.Sale_Type__c = SALE_TYPE_PREOWNED;
                op.Purchase_Type__c = PURCHASE_TYPE_USED;
            } else if (isSaleTypeApo(saleType)) {
                op.Sale_Type__c = SALE_TYPE_APPROVED_PRE_OWNED;
                op.Purchase_Type__c = PURCHASE_TYPE_USED;
            } else {
                InvalidParameterValueException ex = new InvalidParameterValueException('SaleType', saleType);
                throw ex;
            }
            update op;

        } catch (Exception ex) {
            response.addError(ex);
        }
        return response;
    }

    private static Boolean isSaleTypeNew(String saleType) {
        return saleType.equalsIgnoreCase(SALE_TYPE_NEW);
    }

    private static Boolean isSaleTypeApo(String saleType) {
        return saleType.equalsIgnoreCase('Apo')
                || saleType.equalsIgnoreCase('Approved Pre Owned')
                || saleType.equalsIgnoreCase(SALE_TYPE_APPROVED_PRE_OWNED)
                || saleType.equalsIgnoreCase('Approved Pre Owned');

    }

    private static Boolean isSaleTypePreOwned(String saleType) {
        return saleType.equalsIgnoreCase('PreOwned')
                || saleType.equalsIgnoreCase('Pre-Owned')
                || saleType.equalsIgnoreCase('Pre Owned')
                || saleType.equalsIgnoreCase(SALE_TYPE_PREOWNED);
    }

    private static Boolean isSaleTypeDemo(String saleType) {
        return saleType.equalsIgnoreCase(SALE_TYPE_DEMONSTRATOR)
                || saleType.equalsIgnoreCase(SALE_TYPE_DEMO);
    }

    @AuraEnabled
    public static CreateOpportunityResponseDto create(CreateOpportunityRequestDto request) {
        CreateOpportunityResponseDto response = new CreateOpportunityResponseDto();
        try {

            String flowName = 'Opportunity_Create_Australia';
            Map<String, Object> objectMap = new Map<String, Object>{
                    'varActivityDescription' => request.ActivityDescription,
                    'varActivityType' => request.ActivityType,
                    'varCampaignId' => request.CampaignId,
                    'varCompanyName' => request.Company,
                    'varDoSetReminderDate' => request.DoSetReminder,
                    'varDueDate' => request.DueDate,
                    'varEmail' => request.Email,
                    'varEventDateTimeEnd' => request.EventDateTimeEnd,
                    'varEventDateTimeStart' => request.EventDateTimeStart,
                    'varIsQualified' => request.IsOpportunityQualified,
                    'varNameFirst' => request.NameFirst,
                    'varNameLast' => request.NameLast,
                    'varPhoneMobile' => request.PhoneMobile,
                    'varPricebookId' => request.PricebookId,
                    'varRecordTypeIdCorporate' => String.valueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId()),
                    'varRecordTypeIdIndividual' => String.valueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId()),
                    'varRecordTypeIdMilestoneEvent' => String.valueOf(Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Milestone_Event').getRecordTypeId()),
                    'varRecordTypeIdMilestoneTask' => String.valueOf(Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Milestone_Task').getRecordTypeId()),
                    'varRelatedMilestoneId' => request.RelatedMilestoneId,
                    'varRelatedMilestoneName' => request.RelatedMilestoneName,
                    'varReminderDateTime' => request.ReminderDateTime,
                    'varSource' => request.LeadSource,
                    'varExistingAccountId' => request.existingAccountId,
                    'varExistingContactId' => request.existingContactId,
                    'varMakeId' => request.MakeId,
                    'varModelId' => request.ModelId,
                    'varEnquiryType' => request.EnquiryType,
                    'varInitialSalesType' => request.InitialSalesType
            };
            System.debug('objectMap: ' + JSON.serialize(objectMap));
            Flow.Interview flow = new Flow.Interview.Opportunity_Quick_Create_Australia_AutoLaunched(objectMap);
            flow.start();
            response.OpportunityId = (String) flow.getVariableValue('varOpportunityId');

        } catch (Exception ex) {
            response.addError(ex);
        }
        return response;
    }

//todo - refactor
    @AuraEnabled
    public static Id getPricebook2Id() {
        String searchString = '%' + PRICEBOOK2_NAME + '%';
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name LIKE :searchString];
        return pb.Id;
    }

    @AuraEnabled
// note: cannot have two methods both named closeMilestoneOpportunity
    public static CloseOpportunityResponseDto closeMilestoneOpportunity(CloseOpportunityRequestDto request)
    {
        Opportunity opp;
        if (String.isNotEmpty(request.OpportunityId))
        {
            opp = [
                    SELECT
                            Id,
                    (
                            SELECT Asset__c
                            FROM OpportunityLineItems
                            WHERE Product2.RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT
                    )
                    FROM Opportunity
                    WHERE Id = :request.OpportunityId
            ];
        }
        else
        {
            throw new JlrCustomException('OpportunityId Cannot be Null');
        }

        if (opp.OpportunityLineItems.size() > 0 && opp.OpportunityLineItems[0].Asset__c != null)
        {
            // if the asset on the opp you are trying to close is already assigned to another won opportunity give you the option to remove it from the won opportunity and assign it to this one
            SetOpportunityAssetResponseDto setOppAssetRes = AssetsController.CheckIfThisAssetIsAlreadyAssignedToAnOpportunity(
                    opp.OpportunityLineItems[0].Asset__c,
                    opp.Id,
                    true
            );

            if (setOppAssetRes.DuplicateOpportunities.size() > 0)
            {
                CloseOpportunityResponseDto res = new CloseOpportunityResponseDto();
                res.DuplicateOpportunities = setOppAssetRes.DuplicateOpportunities;
                return res;
            }
        }

        return ForceCloseMilestoneOpportunity(request);
    }

    @AuraEnabled
    public static CloseOpportunityResponseDto ForceCloseMilestoneOpportunity(CloseOpportunityRequestDto request)
    {
        CloseOpportunityResponseDto response = new CloseOpportunityResponseDto();

        Opportunity opp;
        if (String.isNotEmpty(request.OpportunityId))
        {
            opp = [
                    SELECT
                            Id,
                            Primary_Contact__r.Id,
                            Primary_Contact__r.Email,
                    (
                            SELECT Asset__c
                            FROM OpportunityLineItems
                            WHERE Product2.RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT
                    )
                    FROM Opportunity
                    WHERE Id = :request.OpportunityId
            ];
        }
        else
        {
            throw new JlrCustomException('OpportunityId Cannot be Null');
        }
        if (request.OpportunityStage.equalsIgnoreCase(OPPORTUNITY_STAGE_LOST))
        {
            opp.Retailer_Loss_Description__c = request.LostDescription;
            opp.Retailer_Loss_Type__c = request.LostReason;
            opp.StageName = OPPORTUNITY_STAGE_LOST;
        }
        else if (request.OpportunityStage.equalsIgnoreCase(OPPORTUNITY_STAGE_WON))
        {
            opp.Handover_Date__c = JlrDateParser.parseStringAsDate(request.PlanedHandoverDate);
            opp.StageName = OPPORTUNITY_STAGE_Handover_RDA;

            if (opp.OpportunityLineItems.size() > 0 && opp.OpportunityLineItems[0].Asset__c != null)
            {
                AssetsController.RemoveAssetFromOpportunitiesWithTheGivenAsset(
                        opp.OpportunityLineItems[0].Asset__c,
                        opp.Id,
                        new List<Boolean> { true, false },
                        new List<String> { opp.Id });
            }
        }
        opp.Always_Allow_Stage_Change__c = true;
        update opp;

        // update contact email if specified
        if (String.isNotBlank(request.OpportunityEmail))
        {
            opp.Primary_Contact__r.Email = request.OpportunityEmail;
            update opp.Primary_Contact__r;
        }

        return response;
    }


    @AuraEnabled
    public static GetOpportunityInfoResponseDto GetMilestoneOpportunityInfo(GetOpportunityInfoRequestDto request) {
        GetOpportunityInfoResponseDto response = new GetOpportunityInfoResponseDto();
        try {
            List<Opportunity> opps = [
                    SELECT
                            Id,
                            AccountId,
                            IsClosed,
                    (
                            SELECT
                                    Id,
                                    Asset__c
                            FROM OpportunityLineItems
                            WHERE Product2.RecordTypeId = :Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').recordTypeId
                    )
                    FROM Opportunity
                    WHERE Id = :request.OpportunityId
            ];

            if (opps.size() < 1) {
                throw new JlrCustomException('Opportunity not found');
            }
            Opportunity opp = opps[0];

            response.HasDerivativeSelected = opp.OpportunityLineItems.size() > 0;
            response.HasAssetSelected = opp.OpportunityLineItems.size() > 0 && opp.OpportunityLineItems[0].Asset__c != null;
            response.AccountId = opp.AccountId;
            response.IsClosed = opp.IsClosed;
        } catch (Exception ex) {
            response.addError(ex);
        }
        return response;
    }

    @AuraEnabled
    public static void deleteOpportunityProduct(DeleteOpportunityProductDto request)
    {
        string servicePlanRecordType = Schema.SObjectType.Product2
                .getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId();
        string derivativeRecordType = Schema.SObjectType.Product2
                .getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();

        List<OpportunityLineItem> olis = [
                SELECT
                        Id,
                        Product2.RecordTypeId,
                        Assignment_Type__c
                FROM OpportunityLineItem WHERE OpportunityId = :request.OpportunityId
        ];

        Set<OpportunityLineItem> toDelete = new Set<OpportunityLineItem>();
        Set<OpportunityLineItem> toUpdate = new Set<OpportunityLineItem>();

        if (request.DoDeleteServicePlan)
        {
            for (OpportunityLineItem oli : olis)
            {
                if (oli.Product2.RecordTypeId == servicePlanRecordType)
                {
                    toDelete.add(oli);
                    if (oli.Assignment_Type__c != Constants.SERVICE_PLAN_TYPE_CORPORATE)
                    {
                        // as per JB-34 we never delete corporate service plans
                    }
                    //ServicePlanController.removeServicePlansAndAssignDefaultServicePlan(request.OpportunityId);
                }
            }
        }

        if (request.DoDeleteAsset)
        {
            for (OpportunityLineItem oli : olis)
            {
                if (oli.Product2.RecordTypeId == derivativeRecordType)
                {
                    oli.Asset__c = null;
                    toUpdate.add(oli);
                }
            }
        }

        if (request.DoDeleteProduct)
        {
            for (OpportunityLineItem oli : olis)
            {
                if (oli.Product2.RecordTypeId == derivativeRecordType)
                {
                    toUpdate.remove(oli);
                    toDelete.add(oli);
                }
            }
        }
        update new List<OpportunityLineItem>(toUpdate);
        delete new List<OpportunityLineItem>(toDelete);
    }
}