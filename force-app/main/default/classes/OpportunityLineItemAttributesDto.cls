/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/08/2019.
 */

global with sharing class OpportunityLineItemAttributesDto  extends AttributesDto{

    public OpportunityLineItemAttributesDto(){
        super();
        init();
    }

    private void init(){
        this.IsVehicle = false;
        this.IsServicePlan = false;
    }

    @AuraEnabled
    global String OpportunityId {get; set;}

    @AuraEnabled
    global Decimal Quantity {get; set;}

    @AuraEnabled
    global String  Product2Id {get; set;}

    @AuraEnabled
    global String  Pricebook2Id {get; set;}

    @AuraEnabled
    global Boolean IsVehicle {get; set;}

    @AuraEnabled
    global Boolean IsServicePlan {get; set;}

    @AuraEnabled
    global String ServicePlanName {get; set;}

    @AuraEnabled
    global String ServicePlanType {get; set;}

    @AuraEnabled
    global String ServicePlanId {get; set;}

    @AuraEnabled
    global String AssignmentType {get; set;}

    @AuraEnabled
    global Decimal TotalPrice {get; set;}

    @AuraEnabled
    global String PricebookEntryId {get; set;}

    @AuraEnabled
    global String Make {get; set;}

    @AuraEnabled
    global String Model {get; set;}

    @AuraEnabled
    global String Trim {get; set;}

    @AuraEnabled
    global String Engine {get; set;}

    @AuraEnabled
    global String ModelYear {get; set;}

    @AuraEnabled
    global String AssetId {get; set;}

    @AuraEnabled
    global String Vin {get; set;}

    @AuraEnabled
    global String ExteriorColour {get; set;}

    @AuraEnabled
    global String ProductDescription {get; set;}

}