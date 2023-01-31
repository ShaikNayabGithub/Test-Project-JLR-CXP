/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 21/10/2019.
 */

public with sharing class WelcomePackResourceDto  extends BaseResourceDto {

    public WelcomePackResourceDto(Task task, Contact con, Asset ass, List<Role__c> roles)
    {
        super();
        init();

        this.Id = task.Id;
        this.Type = 'WelcomePack';

        if (con == null) {
            throw new InvalidFieldReferenceException('Contact is null');
        }

        if (con.MailingStreet != null) {

            // split apart different address lines
            String[] AddressLines = con.MailingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.Attributes.AddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.Attributes.AddressLine2 = AddressLines[1];
            this.Attributes.AddressCountry = con.MailingCountry;
            this.Attributes.AddressPostCode = con.MailingPostalCode;
            this.Attributes.AddressState = con.MailingState;
            this.Attributes.AddressSuburb = con.MailingCity;
        }
        else if (con.Account.BillingStreet != null)
        {
            // split apart different address lines
            String[] AddressLines = con.Account.BillingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.Attributes.AddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.Attributes.AddressLine2 = AddressLines[1];
            this.Attributes.AddressCountry = con.Account.BillingCountry;
            this.Attributes.AddressPostCode = con.Account.BillingPostalCode;
            this.Attributes.AddressState = con.Account.BillingState;
            this.Attributes.AddressSuburb = con.Account.BillingCity;
        }

        this.Attributes.ContactCompanyName = (con.IsPersonAccount) ? null : con.Account.Name;
        this.Attributes.ContactEmail = con.Email;
        this.Attributes.ContactId = con.Id;
        this.Attributes.ContactNameFirst = con.FirstName;
        this.Attributes.ContactNameLast =  con.LastName;
        this.Attributes.ContactPhoneHome = con.HomePhone;
        this.Attributes.ContactPhoneMobile = con.MobilePhone;
        this.Attributes.ContactDateOfBirth = String.valueOf(con.Birthdate);
        this.Attributes.ContactTitle = con.Salutation;
        // if there is an asset related to this contact that is not there currently owned asset they have had a previous jlr vehicle
        this.Attributes.PreviousJlrVehicle = false;
        for (Role__c r : roles)
        {
            this.Attributes.PreviousJlrVehicle |= r.Vehicle__c != ass.Id;
        }
        this.Attributes.PreviousJlrVehicle = this.Attributes.PreviousJlrVehicle ? true : null;

        this.Attributes.VehicleDateWarrantyExpire = String.valueOf(ass.Warranty_End_Date__c);
        this.Attributes.VehicleDateWarrantyStart = String.valueOf(ass.Warranty_Start_Date__c);
        this.Attributes.VehicleDerivative = ass.Derivative__r.Name;
        this.Attributes.VehicleIdentificationNumber = ass.VIN__c;
        this.Attributes.VehicleRegistrationNumber = ass.Registration_Number__c;
        this.Attributes.VehicleMake = ass.Brand__r.Name;
        this.Attributes.VehicleModel = ass.Model__r.Model_Alternative__c;
        this.Attributes.ContactPhoneWork = con.Phone;
        this.Attributes.VehicleModelDetail = ass.Derivative__r.Name;
    }
    
    public WelcomePackResourceDto(){
        super();
        init();
    }

    private void init(){
        if (this.Attributes == null){
            this.Attributes = new WelcomePackAttributeDto();
        }
    }
    public WelcomePackAttributeDto Attributes {get; set;}

}