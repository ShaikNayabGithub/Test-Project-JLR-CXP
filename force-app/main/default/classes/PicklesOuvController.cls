/**
 * Created by Nick on 16/10/2019.
 */

public with sharing class PicklesOuvController {

    private static final String ASSET_ROLE_RETAILER_OWNER = 'Retailer_Owner_ex_OUV';
    private static final String RETAILER_OWNER_RECORDTYPE_ID = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get(ASSET_ROLE_RETAILER_OWNER).getRecordTypeId();
    public static final String RECORD_TYPE_RETAILER = 'Retailer';
    public static final Set<String> VALID_PREV_OUV_OWNERS = new Set<String>{'OUV - 09992 - 09991', 'Jaguar Landrover Australia', 'Jaguar Land Rover Australia Pl', 'Jaguar Land Rover Australia'};
    public static final String PREVIOUS_OWNER_ROLE = 'Previous Owner';
    public static final String RECORD_TYPE_OUV = 'OUV';


    public static GetPicklesOuvResponseDto getAssets(GetPicklesOUVRequestDto request) {
        List<Role__c> roles = [
                SELECT
                        Vehicle__r.Id,
                        Vehicle__r.VIN__c,
                        Vehicle__r.Brand__r.Name,
                        Account__r.Dealer_CI_Code__c,
                        Account__r.Dealer_CI_Code_2__c
                FROM Role__c
                WHERE RecordTypeId = :RETAILER_OWNER_RECORDTYPE_ID
                AND (
                        (Account__r.Dealer_CI_Code__c != NULL AND Vehicle__r.Brand__r.Name = :Constants.MAKE_NAME_JAGUAR)
                    OR
                        (Account__r.Dealer_CI_Code_2__c != NULL AND Vehicle__r.Brand__r.Name = :Constants.MAKE_NAME_LAND_ROVER)
                )
                AND Account__r.Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
        ];
        return new GetPicklesOuvResponseDto(roles);
    }
}