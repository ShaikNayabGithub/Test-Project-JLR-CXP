/**
 * Created by caleb@argologic.com.au on 30/10/2019.
 */

public with sharing class NidasuOpportunityResourceDto extends BaseResourceDto
{
    private static final String RESOURCE_TYPE = 'Opportunity';
    private static final List<String> MANDITORY_FIELDS = new List<String> { };
    private static final String ACCOUNT_TYPE_INDIVIDUAL = 'INDIVIDUAL';
    private static final String ACCOUNT_TYPE_CORPORATE = 'BUSINESS';

    public NidasuOpportunityResourceDto(Opportunity opp)
    {
        this.Id = opp.Id;
        this.Type = RESOURCE_TYPE;

        this.Attributes = new NidasuOpportunityAttributeDto();
        this.Attributes.AccountId = opp.AccountId;
        if (opp.Account.IsPersonAccount)
        {
            this.Attributes.AccountType = ACCOUNT_TYPE_INDIVIDUAL;
        }
        else
        {
            this.Attributes.AccountType = ACCOUNT_TYPE_CORPORATE;
        }
        this.Attributes.SaleType = 'PRIVATE';

        this.Attributes.ContactId = opp.Primary_Contact__r.Id;
        this.Attributes.ContactNameFirst = opp.Primary_Contact__r.FirstName;
        this.Attributes.ContactNameLast = opp.Primary_Contact__r.LastName;
        this.Attributes.ContactPhoneMobile = opp.Primary_Contact__r.MobilePhone;
        this.Attributes.ContactPhoneWork = opp.Primary_Contact__r.Phone;
        this.Attributes.ContactPhoneHome = opp.Primary_Contact__r.HomePhone;
        this.Attributes.ContactEmail = opp.Primary_Contact__r.Email;
        if (opp.Primary_Contact__r.MailingStreet != null)
        {
            String[] AddressLines = opp.Primary_Contact__r.MailingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.Attributes.ContactAddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.Attributes.ContactAddressLine2 = AddressLines[1];

            this.Attributes.ContactAddressCity = opp.Primary_Contact__r.MailingCity;
            this.Attributes.ContactAddressState = opp.Primary_Contact__r.MailingState;
            this.Attributes.ContactAddressPostcode = opp.Primary_Contact__r.MailingPostalCode;
            this.Attributes.ContactAddressCountry = opp.Primary_Contact__r.MailingCountry;
        }
        else if (opp.Account.BillingStreet != null)
        {
            String[] AddressLines = opp.Account.BillingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.Attributes.ContactAddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.Attributes.ContactAddressLine2 = AddressLines[1];

            this.Attributes.ContactAddressCity = opp.Account.BillingCity;
            this.Attributes.ContactAddressState = opp.Account.BillingState;
            this.Attributes.ContactAddressPostcode = opp.Account.BillingPostalCode;
            this.Attributes.ContactAddressCountry = opp.Account.BillingCountry;
        }

        if (opp.OpportunityLineItems.size() > 0)
        {
            // get the make model and derivative info from the line item if possible
            this.Attributes.VehicleDerivative = opp.OpportunityLineItems[0].Product2.Name;
            this.Attributes.VehicleModel = opp.OpportunityLineItems[0].Product2.Model__r.Name;
            this.Attributes.VehicleMake = opp.OpportunityLineItems[0].Product2.Make__r.Name;
        }
        else if (opp.Brand__r.Name != null && opp.Primary_Model_Interest__r.Name != null)
        {
            this.Attributes.VehicleMake = opp.Brand__r.Name;
            this.Attributes.VehicleModel = opp.Primary_Model_Interest__r.Name;
        }
        this.Attributes.VehicleVin = opp.VIN__c;
        this.Attributes.DealerId = opp.Owner.Contact.AccountId;
        this.Attributes.DealerName = opp.Retailer_Name__c;
        this.Attributes.SalespersonId = opp.OwnerId;
        this.Attributes.SalespersonDmsId = opp.Owner.DMS_ID__c;
        this.Attributes.SalespersonNameFirst = opp.Owner.FirstName;
        this.Attributes.SalespersonNameLast = opp.Owner.LastName;
        this.Attributes.SalespersonEmail = opp.Owner.Email;

        List<String> missingFields = JSONManditoryFieldValidator.getMissingFields(this.Attributes, MANDITORY_FIELDS);

        if (missingFields.size() > 0)
        {
            throw new MissingRequiredFieldException(missingFields);
        }
    }
    
    public NidasuOpportunityAttributeDto Attributes {get; set;}
}