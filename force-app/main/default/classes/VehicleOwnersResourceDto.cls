/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/10/2019.
 */

/*
todo - mapping for
    BuyerType
    DealerName
    UpdateType
    --update schema with changes
 */

global with sharing class VehicleOwnersResourceDto extends BaseResourceDto {

    private static final String RESOURCE_TYPE = 'VehicleOwner';
    global VehicleOwnersResourceDto()
    {
        super();
        init();
    }

    global VehicleOwnersResourceDto(Role__c role, Datetime startDatetime)
    {
        this();
        // get asset and contact
        Asset asset = role.Vehicle__r;
        Account acc = role.Account__r;
        Contact con = role.Contact__r;

        this.Id = asset.Id;
        this.Attributes.OwnerType = acc.IsPersonAccount ? 'Individual' : 'Corporate';

        this.Attributes.Name = asset.Name;
        this.Attributes.VehicleProductCode = asset.ProductCode;
        this.Attributes.VehicleIdentificationNumber = asset.VIN__c;
        this.Attributes.VehicleMake = asset.Brand__r.Name;
        this.Attributes.VehicleModel = asset.Derivative__r.Model_Alternative__c;
        this.Attributes.VehicleGroupDescription = asset.Derivative__r.Product_Description__c;
        this.Attributes.VehicleDateWarrantyStart = String.valueOf(asset.Warranty_Start_Date__c);
        this.Attributes.VehicleDateRegistrationStart = String.valueOf(asset.Vehicle_Initial_Registration_Date__c);
        this.Attributes.VehicleRegistrationNumber = asset.Registration_Number__c;

        this.Attributes.OwnerNameFirst = con.FirstName;
        this.Attributes.OwnerNameLast = con.LastName;
        this.Attributes.OwnerNameCompany = acc.IsPersonAccount ? null : con.Account.Name;
        this.Attributes.OwnerTitle = con.Title;
        if (acc.IsPersonAccount && acc.BillingStreet != null)
        {
            String[] AddressLines = acc.BillingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.Attributes.OwnerAddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.Attributes.OwnerAddressLine2 = AddressLines[1];
            this.Attributes.OwnerAddressSuburb = acc.BillingCity;
            this.Attributes.OwnerAddressState = acc.BillingState;
            this.Attributes.OwnerAddressPostcode = acc.BillingPostalCode;
        }
        else if (acc.IsPersonAccount && acc.ShippingStreet != null)
        {
            String[] AddressLines = acc.ShippingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.Attributes.OwnerAddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.Attributes.OwnerAddressLine2 = AddressLines[1];
            this.Attributes.OwnerAddressSuburb = acc.ShippingCity;
            this.Attributes.OwnerAddressState = acc.ShippingState;
            this.Attributes.OwnerAddressPostcode = acc.ShippingPostalCode;
        }
        else if (!acc.IsPersonAccount && con.MailingStreet != null)
        {
            String[] AddressLines = con.MailingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.Attributes.OwnerAddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.Attributes.OwnerAddressLine2 = AddressLines[1];
            this.Attributes.OwnerAddressSuburb = con.MailingCity;
            this.Attributes.OwnerAddressState = con.MailingState;
            this.Attributes.OwnerAddressPostcode = con.MailingPostalCode;
        }
        else if (!acc.IsPersonAccount && con.Account.BillingStreet != null)
        {
            String[] AddressLines = con.Account.BillingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.Attributes.OwnerAddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.Attributes.OwnerAddressLine2 = AddressLines[1];
            this.Attributes.OwnerAddressSuburb = con.Account.BillingCity;
            this.Attributes.OwnerAddressState = con.Account.BillingState;
            this.Attributes.OwnerAddressPostcode = con.Account.BillingPostalCode;
        }

        this.Attributes.OwnerPhoneWork = acc.Phone;
        this.Attributes.OwnerPhoneHome = con.HomePhone;
        this.Attributes.OwnerPhoneMobile = con.MobilePhone;
        this.Attributes.OwnerEmail = con.Email != null ? con.Email : (con.Email2__c != null ? con.Email2__c : con.Email3__c);

        if (asset.Brand__r.Name == Constants.MAKE_NAME_JAGUAR)
        {
            this.Attributes.DealerCode = con.Retailer__r.Dealer_CI_Code__c;
        }
        else if (asset.Brand__r.Name == Constants.MAKE_NAME_LAND_ROVER)
        {
            this.Attributes.DealerCode = con.Retailer__r.Dealer_CI_Code_2__c;
        }
        this.Attributes.EmailOptOut = con.HasOptedOutOfEmail;
        this.Attributes.DirectMailOptOut = con.Direct_Mail_Opt_Out__c;
    }

    private void init()
    {
        this.Type = RESOURCE_TYPE;
        if (this.Attributes == null)
        {
            this.Attributes = new VehicleOwnerAttributesDto();
        }
    }

    @AuraEnabled
    global VehicleOwnerAttributesDto Attributes {get; set;}
}