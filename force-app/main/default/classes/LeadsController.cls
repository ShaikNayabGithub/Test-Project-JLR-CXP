/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 6/09/2019.
 */

public with sharing class LeadsController
{
    public static final string DS_TYPE_NEW = 'NEW';
    public static final string CXP_TYPE_NEW = 'New Vehicle';
    public static final string CXP_TYPE_USED = 'Used Vehicle';
    public static final string RECORD_TYPE_NAME = 'Streamlined_Lead_Process';

    public static final string REQUEST_TYPE_DEALER = 'DEALER';
    public static final string REQUEST_TYPE_OEM = 'OEM';

    public static final string SOURCE_TYPE_DEALER = 'Retailer Website';
    public static final string SOURCE_TYPE_OEM = 'OEM Web & Digital';

    public static final string LEAD_SALE_TYPE = 'New';

    public static CreateLeadResponseDto create(CreateLeadRequestDto request)
    {
        Lead lead = new Lead();
        LeadAttributesDto attributes = request.Data.Attributes;

        // set external id
        lead.External_Id__c = attributes.ExternalId;

        // Set personal info
        lead.Title = attributes.ProspectTitle;
        lead.FirstName = attributes.ProspectNameFirst;
        lead.LastName = attributes.ProspectNameLast;
        lead.Company = null; // hard coded to null as we always want a person account

        lead.Street = attributes.ProspectAddressLine1 + '\n' + attributes.ProspectAddressLine2;
        lead.City = attributes.ProspectAddressSuburb;
        lead.State = attributes.ProspectAddressState;
        lead.PostalCode = attributes.ProspectAddressPostcode;

        lead.Email = attributes.ProspectEmail;
        lead.Phone = attributes.ProspectPhoneWork;
        lead.MobilePhone = attributes.ProspectPhoneMobile;
        lead.Other_Phone__c = attributes.ProspectPhoneHome;

        // Trade in info
        lead.Trade_In__c = String.isNotEmpty(attributes.TradeInMake);
        lead.Trade_In_Brand__c = attributes.TradeInMake;
        lead.Trade_in_Model__c = attributes.TradeInModel;
        lead.Trade_in_Model_Year__c = String.ValueOf(attributes.TradeInYear);
        lead.Mileage__c = attributes.TradeInOdometer;
        lead.Trade_in_Color__c = attributes.TradeInColor;

        // deposit info
        lead.Deposit_Status__c = attributes.DepositStatus;
        lead.Deposit_Transaction_Id__c = attributes.DepositTransactionId;
        lead.Deposit_Reservation_Amount__c = attributes.DepositReservationAmount;

        // Item info
        List<Vehicle_Specification__c> makes = [
                SELECT Id
                FROM Vehicle_Specification__c
                WHERE Name LIKE :attributes.ItemMake AND RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_VEHICLE_SPECIFICATION_MAKE LIMIT 1
        ];
        if (makes.size() >= 1) lead.Brand__c = makes[0].Id;
        List<Vehicle_Specification__c> models = [
                SELECT Id
                FROM Vehicle_Specification__c
                WHERE Name LIKE :attributes.ItemModel
                AND RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_VEHICLE_SPECIFICATION_MODEL
                AND Is_Australia__c = TRUE
                LIMIT 1
        ];
        if (models.size() >= 1) lead.Primary_Model_Interest__c = models[0].Id;
        lead.Enquiry_Stock_Number__c = attributes.ItemStockNumber;
        lead.Enquiry_Series__c = attributes.ItemSeries;
        lead.Enquiry_Year__c = String.valueOf(attributes.ItemYear);
        lead.Enquiry_Price__c = attributes.ItemPrice;
        lead.Enquiry_Registration_Number__c = attributes.ItemRegistrationNumber;
        lead.Enquiry_Engine_Description__c = attributes.ItemEngineDescription;
        lead.Transmission__c = attributes.ItemTransmission;
        lead.Enquiry_Colour__c = attributes.ItemColour;
        lead.Enquiry_Body_Type__c = attributes.ItemBodyType;
        lead.Enquiry_Fuel_Type__c = attributes.ItemFuelType;
        lead.Enquiry_Odometer__c = attributes.ItemOdometer;
        lead.Enquiry_Url__c = attributes.ItemDetailsUrl;
        lead.Enquiry_VIN__c = attributes.ItemVehicleIdentificationNumber;
        lead.Sale_Type__c = LEAD_SALE_TYPE; // hard coded to New as per alex
        if (string.isNotBlank(attributes.ProspectPreferredTestDriveDate))
            lead.Test_Drive_Preferred_Date_Time__c = JlrDateParser.parseStringAsDatetime(attributes.ProspectPreferredTestDriveDate);

        if (!String.IsEmpty(attributes.DealerCode))
        {
            // can now accept 4 or 5 digit codes
            String dealerCode5digit = attributes.DealerCode.leftPad(5, '0');
            List<Account> retailers = [
                    SELECT Id
                    FROM Account
                    WHERE (Dealer_CI_Code__c = :dealerCode5digit OR Dealer_CI_Code_2__c = :dealerCode5digit) AND ParentId != NULL
                    LIMIT 1
            ];
            if (retailers.size() == 1)
            {
                lead.Preferred_Retailer__c = retailers[0].Id;
            }
            else
            {
                System.debug('No Dealer Found');
            }
        }

        // Other
        if (attributes.LeadType == DS_TYPE_NEW || string.isNotBlank(attributes.LeadType))
        {
            lead.Purchase_Type__c = CXP_TYPE_NEW;
        }
        else
        {
            lead.Purchase_Type__c = CXP_TYPE_USED;
        }

        lead.JLR_Dealer_Id__c = attributes.SellerIdentifier;
        lead.Enquiry_Type__c = getEnquiryTypeMapped(attributes.ItemType);

        lead.Description = attributes.Comments;
        lead.Enquiry_Request_Type__c = attributes.RequestType;
        if (attributes.RequestType == REQUEST_TYPE_DEALER)
        {
            lead.LeadSource = SOURCE_TYPE_DEALER;
        }
        else if (attributes.RequestType == REQUEST_TYPE_OEM)
        {
            lead.LeadSource = SOURCE_TYPE_OEM;
        }

        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        lead.RecordTypeId = recordTypes.get(RECORD_TYPE_NAME).getRecordTypeId();

        System.debug('Debug = ' + lead.Enquiry_Type__c);
        if (lead.External_Id__c != null)
        {
            List<Lead> leads = [
                    SELECT Id, ConvertedOpportunityId
                    FROM Lead
                    WHERE External_Id__c = :lead.External_Id__c AND IsConverted = TRUE
            ];
            if (leads.size() == 0)
            {
                upsert lead External_Id__c;
            }
            else
            {
                Opportunity opp = new Opportunity();
                opp.Id = leads[0].ConvertedOpportunityId;
                opp.Deposit_Status__c = attributes.DepositStatus;
                opp.Deposit_Transaction_Id__c = attributes.DepositTransactionId;
                opp.Deposit_Reservation_Amount__c = attributes.DepositReservationAmount;
                opp.External_Id__c = attributes.ExternalId;
                update opp;
            }
        }
        else
        {
            insert lead;
        }

        CreateLeadResponseDto response = new CreateLeadResponseDto();
        response.Data = request.Data;
        response.Data.Id = lead.Id;
        return response;
    }

    public static final string DEFAULT_ENQUIRY_TYPE = 'Find & Price Enquiry';
    public static final Map<String, String> ENQUIRY_TYPE_MAP = new Map<String, String>
    {
            'KMI' => 'KMI',
            'BROCHURE' => 'Brochure Request',
            'TD' => 'Test Drive Request',
            'Approved Pre-owned' => 'Approved Pre-owned',
            'Approved Used Vehicle' => 'Approved Used Vehicle',
            'Brochure Request' => 'Brochure Request',
            'e-Brochure' => 'e-Brochure',
            'Find & Price Enquiry' => 'Find & Price Enquiry',
            'Generic' => 'Generic',
            'JLR Event' => 'JLR Event',
            'Mobile Lead' => 'Mobile Lead',
            'Find & Price - Deposit' => 'Find & Price - Deposit',
            'Online Reservation' => 'Online Reservation',
            'Personalised Brochure Request' => 'Personalised Brochure Request',
            'Resurrected Lead' => 'Resurrected Lead',
            'Test Drive Request' => 'Test Drive Request',
            'Vehicle Configuration' => 'Vehicle Configuration',
            'Fleet and Business Enquiry' => 'Fleet and Business Enquiry'
    };

    private static String getEnquiryTypeMapped(string enquiryType)
    {
        if (string.isBlank(enquiryType) || !ENQUIRY_TYPE_MAP.containsKey(enquiryType))
        {
            return DEFAULT_ENQUIRY_TYPE;
        }
        else
        {
            return ENQUIRY_TYPE_MAP.get(enquiryType);
        }
    }
}