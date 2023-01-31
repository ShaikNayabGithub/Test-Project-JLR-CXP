/**
 * Created by Nick on 1/11/2019.
 */

public with sharing class SalesMatchResourceDto extends BaseResourceDto {

    public SalesMatchResourceDto() {
        super();
        init();
    }

    private void init() {
        if (this.Attributes == null) {
            this.Attributes = new SalesMatchAttributesDto();
        }
    }

    public SalesMatchResourceDto(RDA__c rda) {
        this();
        this.Type = 'SalesMatch';
        this.Id = rda.Id;
        this.Attributes.WarrantyStartDate = rda.Warranty_Start_Date__c;
        this.Attributes.Title = rda.Contact__r.Title;
        this.Attributes.FirstName = rda.Contact__r.FirstName;
        this.Attributes.LastName = rda.Contact__r.LastName;
        this.Attributes.AddressLine1 = rda.Contact__r.MailingStreet;
        this.Attributes.AddressLine2 = rda.Contact__r.Title;
        this.Attributes.LocalityOfCustomer = rda.AU_Locality__r.Name;
        this.Attributes.State = rda.Contact__r.MailingState;
        this.Attributes.PostcodeOfCustomer = rda.Contact__r.MailingPostalCode;
        this.Attributes.WorkPhone = rda.Contact__r.OtherPhone;
        this.Attributes.HomePhone = rda.Contact__r.HomePhone;
        if (rda.Make__c == Constants.MAKE_NAME_JAGUAR)
        {
            this.Attributes.RetailDealerCode = rda.Opportunity__r.Retailer__r.Dealer_CI_Code__c;
        }
        else if (rda.Make__c == Constants.MAKE_NAME_LAND_ROVER)
        {
            this.Attributes.RetailDealerCode = rda.Opportunity__r.Retailer__r.Dealer_CI_Code_2__c;
        }
        this.Attributes.CustomerEmail = rda.Contact__r.Email;
        this.Attributes.SubmissionType = rda.Account__r.PersonTitle;
        this.Attributes.MobilePhone = rda.Contact__r.MobilePhone;
        this.Attributes.DescriptionGroupDescription = rda.Product_Name__c;
        this.Attributes.Nameplate = rda.Model__c;
        this.Attributes.RetailDealerName = rda.Opportunity__r.Retailer_Name__c;
        this.Attributes.RecordTypeName = rda.RecordType.Name;
        this.Attributes.Brand = rda.Asset__r.Brand__r.Name;
        this.Attributes.DealerCode1 = rda.Account__r.Dealer_CI_Code__c;
        this.Attributes.DealerCode2 = rda.Account__r.Dealer_CI_Code_2__c;
    }
    
    public SalesMatchResourceDto(Opportunity opportunity) {
        this();
        this.Type = 'SalesMatch2';
        this.Id = opportunity.Id;
        this.Attributes.FirstName = opportunity.Primary_Contact__r.FirstName;
        this.Attributes.LastName = opportunity.Primary_Contact__r.LastName;
    	this.Attributes.AddressLine1 = opportunity.Primary_Contact__r.MailingStreet;
   		this.Attributes.LocalityOfCustomer = opportunity.Primary_Contact__r.MailingCity;
    	this.Attributes.State = opportunity.Primary_Contact__r.MailingState;
    	this.Attributes.PostcodeOfCustomer = opportunity.Primary_Contact__r.MailingPostalCode;
    	this.Attributes.MobilePhone = opportunity.Primary_Contact__r.MobilePhone;
    	this.Attributes.CustomerEmail = opportunity.Primary_Contact__r.Email;
    	this.Attributes.CampaignName = opportunity.Campaign.Name;
    	this.Attributes.Source = opportunity.LeadSource;
    	this.Attributes.EnquiryType = opportunity.Enquiry_Type__c;
    	this.Attributes.OpportunityDate = opportunity.CreatedDate;
    }

    public SalesMatchAttributesDto Attributes { get; set; }
}