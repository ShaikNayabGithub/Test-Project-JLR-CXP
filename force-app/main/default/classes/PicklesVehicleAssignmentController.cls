/**
 * Created by Ethan Sargent on 30/10/19.
 */

public without sharing class PicklesVehicleAssignmentController {

    private static final string ASSET_ROLE_RETAILER_OWNER = 'Retailer Owner (ex OUV)';
    private static final string ASSET_ROLE_RECORD_TYPE_RETAILER_OWNER = 'Retailer_Owner_ex_OUV';

    @AuraEnabled(Cacheable=true)
    public static List<PicklesVehicleRequestDto> getAssetsAssignedToHeadOffice(String SearchKey, String MakeKey){
        String HeadOfficeAccount = Constants.HEAD_OFFICE_ACCOUNT_NAME;
        String OUVRecordTypeID = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('OUV').getRecordTypeId();
        List<Asset> assets = new List<Asset>();
        if (String.isNotBlank(SearchKey)) {
            String SoqlSearchKey = '%' + SearchKey + '%';
            assets = [
                    SELECT
                            Id,
                            Name,
                            VIN__c,
                            Handover_Date__c,
                            Brand__r.Name,
                            Product2.Name,
                            Registration_Number__c,
                            Common_Sale_Type__c, (
                            SELECT
                                    Id
                            FROM RDAs__r
                            WHERE RecordTypeId = :OUVRecordTypeID
                            AND Account__r.Name = :HeadOfficeAccount
                            AND Submitted_Status__c = 'Completed'
                    )
                    FROM Asset
                    WHERE Account.Name = :HeadOfficeAccount
                    AND (VIN__c LIKE :SoqlSearchKey
                            OR Registration_Number__c LIKE :SoqlSearchKey)
            ];
        } else {
            assets = [
                    SELECT
                            Id,
                            Name,
                            VIN__c,
                            Handover_Date__c,
                            Brand__r.Name,
                            Product2.Name,
                            Registration_Number__c,
                            Common_Sale_Type__c, (
                            SELECT
                                    Id
                            FROM RDAs__r
                            WHERE RecordTypeId = :OUVRecordTypeID
                            AND Account__r.Name = :HeadOfficeAccount
                            AND Submitted_Status__c = 'Completed'
                    )
                    FROM Asset
                    WHERE Account.Name = :HeadOfficeAccount
            ];
        }
        System.debug('Assets size: ' + assets.size());

        List<PicklesVehicleRequestDto> assignmentDtos = new List<PicklesVehicleRequestDto>();

        Integer i = 0;
        for (Asset asset: assets) {
            // Filter out any assets without an OUV RDA
            if (asset.RDAs__r.size() < 1) {
                System.debug('Skipping asset ' + i);
                i++;
                continue;
            }

            System.debug('Adding asset ' + i);
            PicklesVehicleRequestDto currentDto = new PicklesVehicleRequestDto(asset);
            assignmentDtos.add(currentDto);

        }
        System.debug('size of dto: ' + assignmentDtos.size());
        return assignmentDtos;
    }

    @AuraEnabled
    public static Boolean reassignAssets(PicklesAssignmentRequestDto request) {

        List<Asset> assets = [SELECT Id, AccountId FROM Asset WHERE Id IN :request.assetIds];
        List<Role__c> newAssetRoles = new List<Role__c>();
        for (Asset asset: assets) {
            asset.AccountId = (Id) request.dealerId;
            asset.Last_Date_Change_of_Ownership__c = Datetime.now().date();
            newAssetRoles.add(addOwnership(asset, (Id) request.dealerId));
        }
        try {
            insert newAssetRoles;
            update assets;
        } catch (DmlException e) {
            System.debug(e);
            return false;
        }
        return true;
    }

    @AuraEnabled
    public static PicklesDealerResponseDto getDealersFromSearchKey(PicklesDealerRequestDto requestDto){
        PicklesDealerResponseDto DealerResponse = new PicklesDealerResponseDto();
        if (String.isBlank(requestDto.dealerSearchKey)) {
            DealerResponse.dealers = null;
            return DealerResponse;
        } else {
            String nameSearchString = '%' + requestDto.dealerSearchKey + '%';

			system.debug(requestDto.dealerSearchKey);
            List<Account> dealers = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'Retailer' AND Name LIKE :nameSearchString AND Queue_ID__c != NULL LIMIT 10];
            for (Account dealer: dealers) {
                PicklesDealerDetailsDto dealerDetailsDto = new PicklesDealerDetailsDto();
                dealerDetailsDto.Name = dealer.Name;
                dealerDetailsDto.Id = dealer.Id;
                DealerResponse.dealers.add(dealerDetailsDto);
            }

            return DealerResponse;
        }


    }

    private static Role__c addOwnership(Asset asset, Id newAccountId)
    {
        // adds a new current owner role to the asset
        Role__c role = new Role__c();
        role.Account__c = newAccountId;
        role.Vehicle__c = asset.Id;
        role.Role__c = ASSET_ROLE_RETAILER_OWNER;
        role.CurrencyIsoCode = Constants.CURRENCY_CODE_AUD;
        role.RecordTypeId = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get(ASSET_ROLE_RECORD_TYPE_RETAILER_OWNER).recordTypeId;
        return role;
    }
}