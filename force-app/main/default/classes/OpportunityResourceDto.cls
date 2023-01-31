/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

@SuppressWarnings('ApexControlFlowStatementWithoutBraces')
global with sharing class OpportunityResourceDto extends BaseResourceDto {
    public static final String SYSTEM_NAME = 'CXP';
    private static final String VEHICLE_CONDITION_UNKNOWN = 'Unknown';

    private static final String VITAL_JLR_HEAD_OFFICE = 'JLR Head Office';
    private static final String VITAL_DEALER_WEBSITE = 'Dealer Website';
    private static final String CXP_DEALER_WEBSITE = 'Retailer Website';

    private static final String STATUS = 'Ongoing';
    private static final Boolean DO_DISTRIBUTE_TO_DEALER = true;

    @AuraEnabled
    global OpportunityAttributesDto Attributes { get; set; }

    global OpportunityResourceDto() {
        init();
    }

    global OpportunityResourceDto(Opportunity op) {
        this();
        this.Id = op.Id;
        this.Attributes = buildAttributes(op);
        System.debug('Opportunity Resource: = ' + JSON.serialize(this));
    }


    private void init() {
        this.Type = 'Opportunity';
        this.Attributes = new OpportunityAttributesDto();
    }

    private OpportunityAttributesDto buildAttributes(Opportunity op) {
        OpportunityAttributesDto atts = new OpportunityAttributesDto();

        atts.SystemName = SYSTEM_NAME;
        atts.OpportunityId = op.Id;
        atts.EnquiryType = op.Enquiry_Type__c;
        atts.LeadType = op.Type;
        atts.RequestDateTime = String.valueOf(op.CreatedDate);
        atts.BuyerNameTitle = op.Primary_Contact__r.Title;
        atts.BuyerNameFirst = op.Primary_Contact__r.FirstName;
        atts.BuyerNameLast = op.Primary_Contact__r.LastName;
        atts.IsMarketingPermitted = !(
                   op.Primary_Contact__r.Jaguar_Whitemail_Opt_Out__c
                || op.Primary_Contact__r.Jaguar_Email_Opt_Out__c
                || op.Primary_Contact__r.Jaguar_Phone_Opt_Out__c
                || op.Primary_Contact__r.Jaguar_SMS_Opt_Out__c
                || op.Primary_Contact__r.Land_Rover_Whitemail_Opt_Out__c
                || op.Primary_Contact__r.Land_Rover_Email_Opt_Out__c
                || op.Primary_Contact__r.Land_Rover_Phone_Opt_Out__c
                || op.Primary_Contact__r.Land_Rover_SMS_Opt_Out__c
        );
        if (op.Primary_Contact__r.MailingStreet != null)
        {

            // split apart different address lines
            String[] AddressLines = op.Primary_Contact__r.MailingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.Attributes.BuyerAddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.Attributes.BuyerAddressLine2 = AddressLines[1];
            if (AddressLines.size() > 2)
                this.Attributes.BuyerAddressLine3 = AddressLines[2];
            if (AddressLines.size() > 3)
                this.Attributes.BuyerAddressLine4 = AddressLines[3];
        }
        atts.BuyerAddressCity = op.Primary_Contact__r.MailingCity;
        atts.BuyerAddressState = op.Primary_Contact__r.MailingState;
        atts.BuyerAddressPostcode = op.Primary_Contact__r.MailingPostalCode;
        atts.BuyerPhoneMobile = op.Primary_Contact__r.MobilePhone;
        atts.BuyerPhoneHome = op.Primary_Contact__r.Phone;
        atts.BuyerEmailPersonal = op.Primary_Contact__r.Email;
        if (op.LeadSource == CXP_DEALER_WEBSITE)
        {
            atts.LeadSource = VITAL_DEALER_WEBSITE;
        }
        else
        {
            atts.LeadSource = VITAL_JLR_HEAD_OFFICE;
        }

        atts.CampaignName = op.Campaign.Name;
        atts.VehicleBrand = op.Brand__r.Name;
        atts.VehicleModel = op.Primary_Model_Interest__r.Name;
        atts.VehicleModelYear = op.Enquiry_Year__c;
        atts.VehicleCondition = op.Purchase_Type__c;
        atts.VehicleBodyStyle = op.Enquiry_Body_Type__c;
        atts.VehicleEngineType = op.Enquiry_Engine_Description__c;

        if (op.Brand__r.Name == Constants.MAKE_NAME_JAGUAR)
        {
            atts.DealerCode = op.Owner.Contact.Account.Dealer_CI_Code__c.substring(1);
        }
        else if (op.Brand__r.Name == Constants.MAKE_NAME_LAND_ROVER)
        {
            atts.DealerCode = op.Owner.Contact.Account.Dealer_CI_Code_2__c.substring(1);
        }

        atts.Status = STATUS;
        atts.DoDistributeToDealer = DO_DISTRIBUTE_TO_DEALER;
        if (op.Description != null)
        {
            atts.Comments = op.Description.replace('\\n', ' ');
        }
        atts.TradeInMake = op.Revised_Trade_in_Brand__c;
        atts.TradeInModel = op.Revised_Trade_in_Model__c;
        atts.TradeInOdometer = String.valueOf(op.Revised_Trade_in_Mileage__c);
        atts.TradeInPrice = String.valueOf(op.Revised_Trade_in_Value__c);
        atts.TradeInYearModel = op.Revised_Trade_in_Model_Year__c;

        return atts;
    }
}