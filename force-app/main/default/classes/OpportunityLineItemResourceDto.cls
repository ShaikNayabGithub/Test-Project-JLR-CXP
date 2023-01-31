/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/08/2019.
 */

global with sharing class OpportunityLineItemResourceDto extends BaseResourceDto {

    private void init() {
        if (this.Attributes == null) {
            this.Attributes = new OpportunityLineItemAttributesDto();
        }
    }

    global OpportunityLineItemResourceDto() {
        init();
    }

    global OpportunityLineItemResourceDto(OpportunityLineItem item) {
        this();
        this.Id = item.Id;
        this.Attributes.OpportunityId = item.OpportunityId;
        this.Attributes.Name = item.Product_Derivative_Hidden__c;
        this.Attributes.Quantity = item.Quantity;
        this.Attributes.Product2Id = item.Product2Id;
        this.Attributes.Pricebook2Id = item.PricebookEntry.Pricebook2Id;
        if (item.Product2.RecordType.DeveloperName == Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT) {
            //this is a car
            //Todo - Might need a better source for this product description - Grant Millgate
            this.Attributes.Name = item.Product2.Product_Description__c;
            this.Attributes.IsVehicle = true;
            this.Attributes.Make = item.Product_Brand_Hidden__c;
            this.Attributes.Model = item.Product2.Model_Alternative__c;
            this.Attributes.Trim = item.Product2.Specification_Pack_Alternative__c;
            this.Attributes.Engine = item.Product2.Engine_Type_Alternative__c;
            this.Attributes.ModelYear = item.Product2.Model_Year__c;
            this.Attributes.ServicePlanId = item.Product2.Service_Plan__c;

            //Todo - Might need a better source for this product description - Grant Millgate
            this.Attributes.ProductDescription = customizeProductDescription(item.Product2.Product_Description__c);

            if (item.Asset__c != null){
                this.Attributes.AssetId = item.Asset__c;
                this.Attributes.Vin = item.Asset__r.Name;
                this.Attributes.ExteriorColour = item.Asset__r.Exterior_Colour__c;
            }
        }
        if (item.Product2.RecordType.DeveloperName == Constants.RECORD_TYPE_NAME_PRODUCT2_SERVICE_PLAN) {
            //this is a service plan
            this.Attributes.IsServicePlan = true;
            this.Attributes.ServicePlanName = item.Product2.Name;
            this.Attributes.ServicePlanType = item.Assignment_Type__c;

        }

    }

    private String customizeProductDescription(String item) {
        if (String.isBlank(item)){
            return '';
        }
        if (!item.contains(',')){
            return item;
        }
        return item.substring(0, item.indexOf(','));
    }

    @AuraEnabled
    global OpportunityLineItemAttributesDto Attributes { get; set; }

}