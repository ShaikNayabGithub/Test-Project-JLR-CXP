/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/11/2019.
 */

public with sharing class RetailDeliveryController {

    public static GetRetailDeliveryAdvicesResponseDto getRetailDeliveryAdvices(GetRetailDeliveryAdvicesRequestDto request) {
        Date dateStart;
        if (Test.isRunningTest()) dateStart = Date.today().addMonths(1);
        else dateStart = Date.today();
        return new GetRetailDeliveryAdvicesResponseDto(buildResource(dateStart));
    }

    // the number of moths ago that need to be sent to potentate
    public static List<Integer> SURVEY_MONTHS = new List<Integer> {-1, -3, -13, -37, -61};
    public static Date MIN_CREATED_DATE = Date.newInstance(2016, 06, 01);
    public static string NEW_RETAIL_RECORD_TYPE_DEV_NAME = 'New_Retail';
    public static string SUBMITED_STATUS_COMPLETED = 'Completed';
    public static List<Integer> FORBIDDEN_BUYER_TYPES = new List<Integer> { 59 };

    public static List<RetailDeliveryResourceDto> buildResource(Date dateStart)
    {
        Date currentMonthStart = Date.newInstance(dateStart.year(), dateStart.month(), 1);
        Date nextMonthStart = Date.newInstance(dateStart.year(), dateStart.month() + 1, 1);
        List<List<Date>> dateRanges = new List<List<Date>>();
        for (Integer i : SURVEY_MONTHS)
        {
            dateRanges.add(new List<Date> {currentMonthStart.addMonths(i), nextMonthStart.addMonths(i)});
            System.debug(String.valueOf(currentMonthStart.addMonths(i)) + ' - ' + String.valueOf(nextMonthStart.addMonths(i)));
        }
        List<RDA__c> advices = [
                SELECT Id, Handover_Date__c,
                        Account__r.Name,
                        Contact__r.Salutation,
                        Contact__r.FirstName,
                        Contact__r.LastName,
                        Contact__c,
                        Contact__r.MailingStreet,
                        Contact__r.MailingState,
                        Account__r.BillingStreet,
                        Account__r.BillingState,
                        AU_Locality_City__c,
                        AU_Locality_Postcode__c,
                        AU_Locality_State__c,
                        Contact__r.MobilePhone,
                        Contact__r.Email,
                        Registration_Number__c,
                        Asset_VIN__c,
                        Asset__r.Brand__r.Name,
                        Asset__r.Product2.Product_Description__c,
                        Asset__r.Product2.ProductCode,
                        Dealership__r.Name,
                        Make__c,
                        Buyer_Type_Number__c,
                        Buyer_Type__c,
                        Marketing_Indicator__c,
                        Dealer_Code__c,
                        OwnerId,
                        CreatedById
                FROM RDA__c
                WHERE (
                        (Handover_Date__c >= :dateRanges[0][0] AND Handover_Date__c < :dateRanges[0][1])
                    OR (Handover_Date__c >= :dateRanges[1][0] AND Handover_Date__c < :dateRanges[1][1])
                    OR (Handover_Date__c >= :dateRanges[2][0] AND Handover_Date__c < :dateRanges[2][1])
                    OR (Handover_Date__c >= :dateRanges[3][0] AND Handover_Date__c < :dateRanges[3][1])
                    OR (Handover_Date__c >= :dateRanges[4][0] AND Handover_Date__c < :dateRanges[4][1])
                )
                AND CreatedDate >= :MIN_CREATED_DATE
                AND RecordType.DeveloperName = :NEW_RETAIL_RECORD_TYPE_DEV_NAME
                AND Country__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
                AND Buyer_Type_Number__c NOT IN :FORBIDDEN_BUYER_TYPES
                AND Submitted_Status__c = :SUBMITED_STATUS_COMPLETED
        ];

        Map<String, String> dealerCodeToRetailerNameMap = getDealerCodeTORetailerNameMap(advices);

        List<RetailDeliveryResourceDto> resources = new List<RetailDeliveryResourceDto>();

        for (RDA__c advice : advices)
        {
            RetailDeliveryAttributeDto dto = new RetailDeliveryAttributeDto();
            dto.HandoverDate = advice.Handover_Date__c;
            if (advice.Account__r.Name != null) dto.AccountName = advice.Account__r.Name;
            dto.Title = advice.Contact__r.Salutation;
            dto.FirstName = advice.Contact__r.FirstName;
            dto.LastName = advice.Contact__r.LastName;
            dto.ContactID = advice.Contact__c;

            if (advice.Account__r.BillingStreet != null)
            {
                dto.BillingStreet = advice.Account__r.BillingStreet;
                dto.BillingStateProvince = parseState(advice.Account__r.BillingState);
            }
            else if (advice.Contact__r.MailingStreet != null)
            {
                dto.BillingStreet = advice.Contact__r.MailingStreet;
                dto.BillingStateProvince = parseState(advice.Contact__r.MailingState);
            }
            else
            {
                dto.BillingStateProvince = parseState(advice.AU_Locality_State__c);
            }
            dto.LocalityOfCustomer = advice.AU_Locality_City__c;
            dto.PostcodeOfCustomer = advice.AU_Locality_Postcode__c;
            dto.Mobile = advice.Contact__r.MobilePhone;
            if (advice.Marketing_Indicator__c)
            {
                dto.Email = advice.Contact__r.Email;
            }
            dto.RegistrationNumber = advice.Registration_Number__c;
            dto.Vin = advice.Asset_VIN__c;
            dto.DescriptionGroupDescription = advice.Asset__r.Product2.Product_Description__c;
            dto.DescriptionGroupId = advice.Asset__r.Product2.ProductCode;
            dto.RetailDealerName = advice.Dealership__r.Name == null
                    ? (dealerCodeToRetailerNameMap.containsKey(advice.Dealer_Code__c)
                            ? dealerCodeToRetailerNameMap.get(advice.Dealer_Code__c)
                            : '')
                    : advice.Dealership__r.Name;
            dto.Brand = advice.Make__c;
            dto.BuyerTypeNumber = String.valueOf(advice.Buyer_Type_Number__c);
            dto.BuyerTypeDescription = advice.Buyer_Type__c;
            dto.MarketingIndicator = advice.Marketing_Indicator__c ? 'Y' : 'N';
            dto.RetailDealerCode = advice.Dealer_Code__c;
            RetailDeliveryResourceDto resource = new RetailDeliveryResourceDto(dto);
            resources.add(resource);
        }
        return resources;
    }

    public static string parseState(String state)
    {
        if (state == null) return '';

        if (state.equalsIgnoreCase('NSW')) return 'NSW';
        if (state.equalsIgnoreCase('VIC')) return 'VIC';
        if (state.equalsIgnoreCase('QLD')) return 'QLD';
        if (state.equalsIgnoreCase('SA')) return 'SA';
        if (state.equalsIgnoreCase('WA')) return 'WA';
        if (state.equalsIgnoreCase('TAS')) return 'TAS';
        if (state.equalsIgnoreCase('ACT')) return 'ACT';
        if (state.equalsIgnoreCase('NT')) return 'NT';

        if (state.containsIgnoreCase('New')
                && state.containsIgnoreCase('South')
                && state.containsIgnoreCase('Wales')) return 'NSW';
        if (state.containsIgnoreCase('Victoria')) return 'VIC';
        if (state.containsIgnoreCase('Queensland')) return 'QLD';
        if (state.containsIgnoreCase('South')
                && state.containsIgnoreCase('Australia')) return 'SA';
        if (state.containsIgnoreCase('Western')
                && state.containsIgnoreCase('Australia')) return 'WA';
        if (state.containsIgnoreCase('Tasmania')) return 'TAS';
        if (state.containsIgnoreCase('Australian')
                && state.containsIgnoreCase('Capital')
                && state.containsIgnoreCase('Territory')) return 'ACT';
        if (state.containsIgnoreCase('Northern')
                && state.containsIgnoreCase('Territory')) return 'NT';
        return '';
    }

    public static Map<String, String> getDealerCodeTORetailerNameMap(List<RDA__c> rdas)
    {
        List<String> dealerCodesJag = new List<String>();
        List<String> dealerCodesLR = new List<String>();
        for (RDA__c rda : rdas)
        {
            if (rda.Asset__r.Brand__r.Name == Constants.MAKE_NAME_JAGUAR)
            {
                dealerCodesJag.add(rda.Dealer_Code__c);
            }
            else if (rda.Asset__r.Brand__r.Name == Constants.MAKE_NAME_LAND_ROVER)
            {
                dealerCodesLR.add(rda.Dealer_Code__c);
            }
        }

        List<Account> dealersJaguar = [
                SELECT Id, ParentId, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Name
                FROM Account
                WHERE Dealer_CI_Code__c IN :dealerCodesJag AND Dealer_CI_Code_2__c = NULL AND ParentId != NULL
        ];

        List<Account> dealersLandRover = [
                SELECT Id, ParentId, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Name
                FROM Account
                WHERE Dealer_CI_Code__c = NULL AND Dealer_CI_Code_2__c IN :dealerCodesLR AND ParentId != NULL
        ];

        Map<string, String> dealerCodeTORetailerNameMap = new Map<String, String>();
        for (Account acc : dealersJaguar)
        {
            dealerCodeTORetailerNameMap.put(acc.Dealer_CI_Code__c, acc.Name);
        }
        for (Account acc : dealersLandRover)
        {
            dealerCodeTORetailerNameMap.put(acc.Dealer_CI_Code_2__c, acc.Name);
        }
        return dealerCodeTORetailerNameMap;
    }

}