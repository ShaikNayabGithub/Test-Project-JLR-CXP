/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class VariantAttributesDto extends AttributesDto{

    @AuraEnabled
    global String ProductCode {get; set;}

    //Make
    @AuraEnabled
    global String Make {get; set;}

    //Model
    @AuraEnabled
    global String Model {get; set;}


    @AuraEnabled
    global String Pricebook2Id {get; set;}

    @AuraEnabled
    global String PricebookEntryId {get; set;}

    @AuraEnabled
    global String ServicePlanId {get; set;}

    @AuraEnabled
    global String Engine {get; set;}

    @AuraEnabled
    global String Transmission {get; set;}

    @AuraEnabled
    global String TrimBadge {get; set;}

    @AuraEnabled
    global String BodyStyle {get; set;}

    @AuraEnabled
    global String ModelYear {get; set;}

}