/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 25/11/2019.
 */

public with sharing class ServicePlanResourceDto extends BaseResourceDto{

    public ServicePlanResourceDto(){
        super();
        init();
    }

    private void init(){
        this.Type = 'ServicePlan';

        if (this.Attributes == null){
            this.Attributes = new ServicePlanAttributeDto();
        }
    }

    public ServicePlanResourceDto(PricebookEntry pbe){
        this();
        this.Id = pbe.Product2Id;
        this.Attributes.PricebookEntryId = pbe.Id;
        this.Attributes.Name = pbe.Product2.Name;
        this.Attributes.ServicePlanName = pbe.Product2.Name;
        this.Attributes.ServicePlanType = Constants.SERVICE_PLAN_TYPE_RETAIL;
        this.Attributes.UnitPrice = String.valueOf(pbe.UnitPrice);
    }

    public ServicePlanResourceDto(OfferResourceDto offer) {
        this();
        this.Id = offer.Attributes.Product2Id;
        this.Attributes.Name = offer.Attributes.Name;
        this.Attributes.ServicePlanType = offer.Attributes.ServicePlanType;
        this.Attributes.ServicePlanName = offer.Attributes.ServicePlanName;
        this.Attributes.QantasPoints = offer.Attributes.QantasPoints;
        this.Attributes.DiscountAmount = offer.Attributes.DiscountAmount;
        this.Attributes.DiscountPercentage = offer.Attributes.DiscountPercentage;
        this.Attributes.DateStart = offer.Attributes.DateStart;
        this.Attributes.DateEnd = offer.Attributes.DateEnd;
        this.Attributes.MinimumPurchasePrice = offer.Attributes.MinimumPurchasePrice;
        this.Attributes.CorporatePartnerId = offer.Attributes.CorporatePartnerId;
        this.Attributes.CorporatePartnerName = offer.Attributes.CorporatePartnerName;

    }

    @AuraEnabled
    public ServicePlanAttributeDto Attributes {get; set;}
}