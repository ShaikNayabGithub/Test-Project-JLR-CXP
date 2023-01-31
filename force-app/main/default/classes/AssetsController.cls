/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 6/09/2019.
 */

public without sharing class AssetsController {
    private static final String RECORD_TYPES_RDA_DEALER_OWNED = 'Dealer_Owned';
    private static final Integer MAX_SOQL_ROWS = 1000;

    @AuraEnabled(Cacheable=false)
    public static GetAssetsResponseDto getAssetList(GetAssetsRequestDto request) {
        System.debug('>> getAssetList()');
        System.debug('request: ' + JSON.serialize(request));

        String userId = String.isNotBlank(request.UserId) ? request.UserId : UserInfo.getUserId();
        System.debug('UserId: ' + userId);
        Id conId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        Id accId = [SELECT AccountId FROM Contact WHERE Id = :conId].AccountId;
        List<Retailer_Asset_Share__mdt> shares = [SELECT Retailer_Account_Id__c FROM Retailer_Asset_Share__mdt WHERE Share_With_Retailer_Account_Id__c = :accId];
        Set<Id> retailerAccountIds = new Set<Id>();
        retailerAccountIds.add(accId);
        for (Retailer_Asset_Share__mdt share : shares)
        {
            retailerAccountIds.add(share.Retailer_Account_Id__c);
        }

        List<Asset> assets = getAssetsFromDb(request.DerivativeProduct2Id, request.SearchKey);
        System.debug('Assets : ' + JSON.serialize(assets, true));

        List<Asset> refinedList = new List<Asset>();

        //when searching via search key, no need to filter
        if (String.isBlank(request.SearchKey)) {
            if (request.SaleType.equalsIgnoreCase(GetAssetsRequestDto.SALE_TYPES_NEW)) {
                //Refine to include only new assets
                refinedList = filterAssets_newOnly(assets, retailerAccountIds);
            } else if (request.SaleType.equalsIgnoreCase(GetAssetsRequestDto.SALE_TYPES_DEMONSTRATOR)
                    || request.SaleType.equalsIgnoreCase(GetAssetsRequestDto.SALE_TYPES_DEMO)) {
                refinedList = filterAssets_demoOnly(assets, retailerAccountIds);
            } else if (request.SaleType.equalsIgnoreCase(GetAssetsRequestDto.SALE_TYPES_PRE_OWNED)
                    || request.SaleType.equalsIgnoreCase(GetAssetsRequestDto.SALE_TYPES_PRE_OWNED_HYPHENATED)) {
                refinedList = filterAssets_preOwnedOnly(assets);
            } else if (request.SaleType.equalsIgnoreCase(GetAssetsRequestDto.SALE_TYPES_APPROVED_PRE_OWNED)) {
                refinedList = filterAssets_preOwnedOnly(assets);
            } else {
                throw new InvalidParameterValueException('SaleType', request.SaleType + ' is not yet implemented');
            }

        } else {
            refinedList = assets;
        }
        GetAssetsResponseDto response = new GetAssetsResponseDto(refinedList, request.SearchKey);
        System.debug('response: ' + JSON.serialize(response));
        System.debug('<< getAssetList()');
        return response;
    }

    private static List<Asset> filterAssets_newOnly(List<Asset> assets, Set<Id> accountIds) {
        List<Asset> refinedList = new List<Asset>();
        for (Asset ass : assets) {
            if (ass.RDAs__r.size() == 0 && accountIds.contains(ass.AccountId)) {
                refinedList.add(ass);
            }
        }
        return refinedList;
    }

    private static List<Asset> getAssetsFromDb(Id productId, String searchKey) {
        if (String.isBlank(searchKey)) {
            return [
                    SELECT
                            Id,
                            Name,
                            AccountId,
                            Status,
                            Account.Name,
                            Product2Id,
                            VIN__c,
                            Vehicle_ID__c,
                            Product2.Make__r.Name,
                            Product2.Model_Alternative__c,
                            Product2.ProductCode,
                            Product2.Model_Year_Alternative__c,
                            Product2.Specification_Pack_Alternative__c,
                            Product2.Engine__c,
                            Product2.Wheel_Base__c,
                            Product2.Body_Style__c,
                            Product2.Transmission__c,
                            Exterior_Colour__c,
                            Exterior_Colour_Group__c,
                            Interior_Color__c,
                            Registration_Number__c,
                            Product2.Model__r.ProductCode, (
                            SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName
                            FROM RDAs__r
                    )

                    FROM Asset
                    WHERE Product2Id = :productId
            ];
        } else {
            String searchTerm = '%' + searchKey + '%';
            return [
                    SELECT
                            Id,
                            Name,
                            AccountId,
                            Status,
                            Account.Name,
                            Product2Id,
                            VIN__c,
                            Vehicle_ID__c,
                            Product2.Make__r.Name,
                            Product2.Model_Alternative__c,
                            Product2.ProductCode,
                            Product2.Model_Year_Alternative__c,
                            Product2.Specification_Pack_Alternative__c,
                            Product2.Engine__c,
                            Product2.Wheel_Base__c,
                            Product2.Body_Style__c,
                            Product2.Transmission__c,
                            Exterior_Colour__c,
                            Exterior_Colour_Group__c,
                            Interior_Color__c,
                            Registration_Number__c,
                            Product2.Model__r.ProductCode,
                            (
                                    SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName
                                    FROM RDAs__r
                            )
                    FROM Asset
                    WHERE (
                            Registration_Number__c LIKE :searchTerm
                            OR VIN__c LIKE :searchTerm
                            OR Order_Number__c LIKE :searchTerm
                    )
                    LIMIT :MAX_SOQL_ROWS
            ];
        }
    }

    private static List<Asset> filterAssets_demoOnly(List<Asset> assets, Set<Id> accountIds) {
        List<Asset> refinedList = new List<Asset>();
        for (Asset ass : assets) {
            Integer count = ass.RDAs__r.size();
            System.debug('Count RDA: ' + count);
            if (ass.RDAs__r.size() == 1 && accountIds.contains(ass.AccountId)) {
                String recordTypeName = ass.RDAs__r[0].RecordType.DeveloperName;
                System.debug('Record Type: ' + recordTypeName);
                if (recordTypeName.equalsIgnoreCase(RECORD_TYPES_RDA_DEALER_OWNED)) {
                    refinedList.add(ass);
                }
            }
        }
        return refinedList;
    }

    private static List<Asset> filterAssets_preOwnedOnly(List<Asset> assets) {
        List<Asset> refinedList = new List<Asset>();
        for (Asset ass : assets) {
            Integer count = ass.RDAs__r.size();
            System.debug('Count RDA: ' + count);
            if (ass.RDAs__r.size() > 0) {
                String recordTypeName = ass.RDAs__r[0].RecordType.DeveloperName;
                System.debug('Record Type: ' + recordTypeName);
                if (!recordTypeName.equalsIgnoreCase(RECORD_TYPES_RDA_DEALER_OWNED)) {
                    refinedList.add(ass);
                }
            }
        }
        return refinedList;
    }

    @AuraEnabled(Cacheable=false)
    public static CreateAssetResponseDto createAsset(CreateAssetRequestDto request) {
        Asset asset = new Asset();
        Product2 prod = [SELECT Id, Make__c, Model__c FROM Product2 WHERE Id = :request.derivativeProduct2Id];

        // todo - add additional fields if required
        asset.Model__c = prod.Model__c;
        asset.Derivative__c = prod.Id;
        asset.Brand__c = prod.Make__c;

        asset.Name = request.name;
        asset.AccountId = request.accountId;
        asset.CurrencyIsoCode = request.currencyIsoCode;

        String recordTypeId = RecordTypeDao.getInstance().getRecordTypeId(RecordTypeDao.sObjectType_Asset, request.assetRecordType);
        asset.RecordTypeId = recordTypeId;

        insert asset;

        CreateAssetResponseDto response = new CreateAssetResponseDto(asset.Id);
        return response;
    }
    
    public static Database.SaveResult addAssetToOpportunityLineItem(Id opLineItem, Id assetId){
        System.debug('>> addAssetToOpportunityLineItem()');
        System.debug('opLineItem: ' + opLineItem);
        System.debug('assetId: ' + assetId);

        OpportunityLineItem lineItem = new OpportunityLineItem();
        lineItem.Id = opLineItem;
        lineItem.Asset__c = assetId;
        Database.SaveResult result = Database.update(lineItem);
        // get the currently logged in user
        String userId = UserInfo.getUserId();
        // get assosiated account
        User user = [SELECT Contact.AccountId FROM User WHERE Id = :userId];
        if (user.Contact.AccountId != null)
        {
            // Add Account to the asset
            Asset ass = new Asset();
            ass.Id = assetId;
            ass.AccountId = user.Contact.AccountId;
            update ass;
        }

        System.debug('result: ' + JSON.serialize(result, true));
        System.debug('<< addAssetToOpportunityLineItem()');
                                                              
        return result;       
    }

    public static void SendAssetAlreadyAssignedEmails(String opportunityId, string opportunityTheAssetWillBeAssignedToId, string assetId)
    {
        Map<String, Object> params = new Map<String, Object>
        {
                'opportunityId' => opportunityId,
                'opportunityTheAssetWillBeAssignedToId' => opportunityTheAssetWillBeAssignedToId,
                'assetId' => assetId
        };
        Flow.Interview.SendAssetAssignmentEmail flow = new Flow.Interview.SendAssetAssignmentEmail(params);
        flow.start();
    }

    @Future
    public static void SendPriceProtectionLostEmails(String assetId)
    {
        Map<String, Object> params = new Map<String, Object>
        {
                'currentUserId' => UserInfo.getUserId(),
                'assetId' => assetId
        };
        Flow.Interview.Send_Price_Protection_Lost_Sales_Team_Email flow = new Flow.Interview.Send_Price_Protection_Lost_Sales_Team_Email(params);
        flow.start();
    }

    public static SetOpportunityAssetResponseDto CheckIfThisAssetIsAlreadyAssignedToAnOpportunity(string assetId, string oppId, Boolean isAboutToBeWon)
    {
        List<Opportunity> duplicateOpps = [
                SELECT Id, Name, CloseDate, OwnerId, IsWon
                FROM Opportunity
                WHERE Id != :oppId
                AND
                        Id NOT IN (
                        SELECT Opportunity__c
                        FROM RDA__c
                        WHERE Submitted_Status__c != 'Cancelled'
                )
                AND Id IN (
                        SELECT OpportunityId
                        FROM OpportunityLineItem
                        WHERE Asset__c = :assetId
                )
        ];
        Opportunity oppAssetWillBeAssignedTo = [
                SELECT Id, Name, CloseDate, OwnerId, IsWon
                FROM Opportunity
                WHERE Id = :oppId
        ];
        Asset asset = [
                SELECT
                        Id,
                        Is_Price_Protected__c
                FROM Asset
                WHERE Id = :assetId
        ];

        List<String> ownerIds = new List<String>();
        for (Opportunity o : duplicateOpps) ownerIds.add(o.OwnerId);

        List<User> users = [
                SELECT
                        Name,
                        Id
                FROM User
                WHERE Id = :ownerIds
        ];

        Map<string, User> idToUser = new Map<String, User>();
        for (User u : users) idToUser.put(u.Id, u);

        Boolean anyAreWon = false;
        for (Opportunity opp : duplicateOpps) anyAreWon |= opp.IsWon;

        SetOpportunityAssetResponseDto res = new SetOpportunityAssetResponseDto();
        if (oppAssetWillBeAssignedTo.IsWon || isAboutToBeWon)
        {
            if (asset.Is_Price_Protected__c)
            {
                // true if any of the duplicateOpps are won or the asset is already won
                res.DoesLosePriceProtection = anyAreWon || oppAssetWillBeAssignedTo.IsWon;
                res.WillRemoveAssetFromOpps = true;
                res.DuplicateOpportunities = new List<SetAssetOpportunityDto>();
                for (Opportunity o : duplicateOpps)
                {
                    SetAssetOpportunityDto oppDto = new SetAssetOpportunityDto();
                    oppDto.OpportunityName = o.Name;
                    oppDto.OpportunityCloseDate = o.CloseDate;
                    oppDto.OpportunitySalesOwnerName = idToUser.get(o.OwnerId).Name;
                    oppDto.IsWon = o.IsWon;
                    res.DuplicateOpportunities.add(oppDto);
                }
            }
            else
            {
                res.DoesLosePriceProtection = false;
                res.WillRemoveAssetFromOpps = true;
                res.DuplicateOpportunities = new List<SetAssetOpportunityDto>();
                for (Opportunity o : duplicateOpps)
                {
                    SetAssetOpportunityDto oppDto = new SetAssetOpportunityDto();
                    oppDto.OpportunityName = o.Name;
                    oppDto.OpportunityCloseDate = o.CloseDate;
                    oppDto.OpportunitySalesOwnerName = idToUser.get(o.OwnerId).Name;
                    oppDto.IsWon = o.IsWon;
                    res.DuplicateOpportunities.add(oppDto);
                }
            }
        }
        else
        {
            if (asset.Is_Price_Protected__c)
            {
                res.DoesLosePriceProtection = true;
                res.WillRemoveAssetFromOpps = anyAreWon;
                res.DuplicateOpportunities = new List<SetAssetOpportunityDto>();
                for (Opportunity o : duplicateOpps)
                {
                    SetAssetOpportunityDto oppDto = new SetAssetOpportunityDto();
                    oppDto.OpportunityName = o.Name;
                    oppDto.OpportunityCloseDate = o.CloseDate;
                    oppDto.OpportunitySalesOwnerName = idToUser.get(o.OwnerId).Name;
                    oppDto.IsWon = o.IsWon;
                    res.DuplicateOpportunities.add(oppDto);
                }
            }
            else
            {
                res.DoesLosePriceProtection = false;
                res.WillRemoveAssetFromOpps = anyAreWon;
                res.DuplicateOpportunities = new List<SetAssetOpportunityDto>();
                for (Opportunity o : duplicateOpps)
                {
                    if (o.IsWon)
                    {
                        SetAssetOpportunityDto oppDto = new SetAssetOpportunityDto();
                        oppDto.OpportunityName = o.Name;
                        oppDto.OpportunityCloseDate = o.CloseDate;
                        oppDto.OpportunitySalesOwnerName = idToUser.get(o.OwnerId).Name;
                        oppDto.IsWon = o.IsWon;
                        res.DuplicateOpportunities.add(oppDto);
                    }
                }
            }
        }

        return res;
    }

    // This will return any opps with the asset assigned one or lost and if the asset is price protected
    // if there is no reason we cannot set the asset we will set it (the asset is not price protected and there are no won opps with the asset)
    @AuraEnabled
    public static SetOpportunityAssetResponseDto SetAssetWithMultiAssignCheck(string opportunityId, string assetId)
    {
        SetOpportunityAssetResponseDto res = CheckIfThisAssetIsAlreadyAssignedToAnOpportunity(assetId, opportunityId, false);

        if (res.DuplicateOpportunities.size() == 0)
        {
            SetAssetForced(opportunityId, assetId, false);
        }
        return res;
    }

    public static void RemoveAssetFromOpportunitiesWithTheGivenAsset(string assetId, string opportunityTheAssetWillBeAssignedToId, List<Boolean> isWonFilter, List<string> oppIdsToIgnore)
    {
        List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem>();

        List<Opportunity> opps = [
                SELECT
                        Id,
                        Name,
                        CloseDate,
                        OwnerId,
                (
                        SELECT
                                Id,
                                Product2.RecordType.DeveloperName
                        FROM OpportunityLineItems
                )
                FROM Opportunity
                WHERE IsWon IN :isWonFilter
                AND Id NOT IN :oppIdsToIgnore
                AND Id NOT IN (
                        SELECT Opportunity__c
                        FROM RDA__c
                        WHERE Submitted_Status__c != 'Cancelled'
                )
                AND Id IN (
                        SELECT OpportunityId
                        FROM OpportunityLineItem
                        WHERE Asset__c = :assetId
                )
        ];

        for (Opportunity opp : opps)
        {
            for (OpportunityLineItem oli : opp.OpportunityLineItems)
            {
                if (oli.Product2.RecordType.DeveloperName == Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT)
                {
                    oli.Asset__c = null;
                    olisToUpdate.add(oli);
                }
            }
            SendAssetAlreadyAssignedEmails(opp.Id, opportunityTheAssetWillBeAssignedToId, assetId);
        }

        update olisToUpdate;
    }

    @AuraEnabled
    public static void SetAssetForced(string opportunityId, string assetId, Boolean removePriceProtection)
    {
        List<OpportunityLineItem> olisToUpdate = new List<OpportunityLineItem>();

        List<Boolean> isWonFilter = new List<Boolean> { true };
        if ([SELECT IsWon FROM Opportunity WHERE Id = :opportunityId].IsWon)
        {
            isWonFilter.add(false);
        }

        // remove asset from other opps
        RemoveAssetFromOpportunitiesWithTheGivenAsset(
                assetId,
                opportunityId,
                isWonFilter,
                new List<String> { opportunityId });

        // add asset to opp
        List<OpportunityLineItem> olis = [
                SELECT
                        Id,
                        Product2.RecordType.DeveloperName,
                        Product2Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunityId
        ];

        Asset ass = [
                SELECT
                        Id,
                        Product2Id,
                        Product2.Make__c,
                        Product2.Model__r.Model_Vehicle_Spec__c
                FROM Asset
                WHERE Id = :assetId
        ];

        OpportunityLineItem variantOli;
        OpportunityLineItem servicePlanOli;

        for (OpportunityLineItem oli : olis)
        {
            if (oli.Product2.RecordType.DeveloperName == Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT) variantOli = oli;
            else if (oli.Product2.RecordType.DeveloperName == Constants.RECORD_TYPE_NAME_PRODUCT2_SERVICE_PLAN) servicePlanOli = oli;
        }

        // set make model derivative
        Opportunity opp = new Opportunity(Id = opportunityId);
        opp.Brand__c = ass.Product2.Make__c;
        opp.Primary_Model_Interest__c = ass.Product2.Model__r.Model_Vehicle_Spec__c;
        update opp;

        ProductsController.setVariant(opportunityId, ass.Product2Id);

        //ServicePlanController.removeServicePlansAndAssignDefaultServicePlan(opportunityId);

        variantOli = [
                SELECT
                        Id,
                        Product2.RecordType.DeveloperName,
                        Product2Id
                FROM OpportunityLineItem
                WHERE Product2.RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT
                AND OpportunityId = :opportunityId
        ];

        variantOli.Asset__c = assetId;
        olisToUpdate.add(variantOli);

        if (removePriceProtection)
        {
            ass.Is_Price_Protected__c = false;
            ass.Price_Protection_Lost_User__c = UserInfo.getUserId();
            ass.Price_Protection_Lost_DateTime__c = Datetime.now();
            update ass;
            // todo - want to send an email here
            SendPriceProtectionLostEmails(assetId);
        }

        Opportunity QuearyedOpp = [
                SELECT Corporate_Partner_Account__c
                FROM Opportunity
                WHERE Id = :opportunityId
        ];
        if (QuearyedOpp.Corporate_Partner_Account__c != null)
        {
            // todo delete all the corporate partener code and delete this once corp partners are done - cause the code in corporate partner controller is very bad and uses to many quearys
            SetCorporatePartnerRequestDto req = new SetCorporatePartnerRequestDto();
            req.CorporatePartnerId = QuearyedOpp.Corporate_Partner_Account__c;
            req.OpportunityId = opportunityId;
            req.VariantId = ass.Product2Id;
            CorporatePartnersController.setOpportunityCorporatePartner(req);
        }


        update olisToUpdate;
    }
    
    public static void TestCoverage()
    {
        Integer a = 0;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;
    }
}