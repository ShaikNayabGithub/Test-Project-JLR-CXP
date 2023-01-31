/**
 * Created by caleb on 16/10/2019.
 */

public with sharing class GetOpportunityAttributeDto
{
    public GetOpportunityAttributeDto(Opportunity opp)
    {
        this.AccountId = opp.AccountId;
        this.AccountType = opp.Account.Type;
        this.SaleType = opp.Sale_Type__c;
        this.ContactId = opp.Account.PersonContact.Id;
        this.ContactNameFirst = opp.Account.PersonFirstNameLocal;
        this.ContactNameLast = opp.Account.PersonLastNameLocal;
        this.ContactPhoneMobile = opp.Account.PersonMobilePhone;
        this.ContactPhoneWork = opp.Account.Phone;
        this.ContactPhoneHome = opp.Account.PersonHomePhone;
        if (opp.Account.BillingStreet != null)
        {
            String[] AddressLines = opp.Account.BillingStreet.split('\n');
            if (AddressLines.size() > 0)
                this.ContactAddressLine1 = AddressLines[0];
            if (AddressLines.size() > 1)
                this.ContactAddressLine2 = AddressLines[1];
        }
        this.ContactAddressCity = opp.Account.BillingCity;
        this.ContactAddressState = opp.Account.BillingState;
        this.ContactAddressPostcode = opp.Account.BillingPostalCode;
        this.ContactAddressCountry = opp.Account.BillingCountry;
        this.VehicleMake = opp.Brand__r.Name;
        this.VehicleModel = opp.Primary_Model_Interest__r.Name;
        this.VehicleDerivative = opp.Derivative__r.Name;
        this.VehicleVin = opp.VIN__c;
        this.DealerId = opp.Retailer__c;
        this.DealerName = opp.Retailer_Name__c;
        this.SalespersonId = opp.OwnerId;
        this.SalespersonDmsId = opp.Owner.DMS_ID__c;
        this.SalespersonNameFirst = opp.Owner.FirstName;
        this.SalespersonNameLast = opp.Owner.LastName;
        this.SalespersonEmail = opp.Owner.Email;
    }

    public String AccountId {get;set;}
    public String AccountType {get;set;}
    public String SaleType {get;set;}
    public String ContactId {get;set;}
    public String ContactNameFirst {get;set;}
    public String ContactNameLast {get;set;}
    public String ContactEmail {get;set;}
    public String ContactPhoneMobile {get;set;}
    public String ContactPhoneWork {get;set;}
    public String ContactPhoneHome {get;set;}
    public String ContactAddressLine1 {get;set;}
    public String ContactAddressLine2 {get;set;}
    public String ContactAddressCity {get;set;}
    public String ContactAddressState {get;set;}
    public String ContactAddressPostcode {get;set;}
    public String ContactAddressCountry {get;set;}
    public String VehicleMake {get;set;}
    public String VehicleModel {get;set;}
    public String VehicleDerivative {get;set;}
    public String VehicleVin {get;set;}
    public String DealerId {get;set;}
    public String DealerName {get;set;}
    public String SalespersonId {get;set;}
    public String SalespersonDmsId {get;set;}
    public String SalespersonNameFirst {get;set;}
    public String SalespersonNameLast {get;set;}
    public String SalespersonEmail {get;set;}
}