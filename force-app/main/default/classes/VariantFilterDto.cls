/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/10/2019.
 */

public with sharing class VariantFilterDto {

    @AuraEnabled
    public String MakeId {get; set;}

    @AuraEnabled
    public String ModelId {get; set;}

    @AuraEnabled
    public String ModelYear {get; set;}

    @AuraEnabled
    public String BodyStyleId {get; set;}

    @AuraEnabled
    public String TrimBadgeId {get; set;}

    @AuraEnabled
    public String EngineTypeId {get; set;}

    @AuraEnabled
    public String TransmissionId {get; set;}

    @AuraEnabled
    public String NumberOfDoors {get; set;}

    @AuraEnabled
    public String NumberOfSeats {get; set;}


    public Map<String, String> toMap(){
        Map<String, String> filters = new Map<String, String>();

        //Make
        filters = addProperty(filters, Product2.Make__c.getDescribe().getName(), this.MakeId);

        //Model
        filters = addProperty(filters, Product2.Model__c.getDescribe().getName(), this.ModelId);

        //Model Year
        filters = addProperty(filters, Product2.Model_Year__c.getDescribe().getName(), this.ModelYear);

        //BodyStyle
        filters = addProperty(filters, Product2.Body_Style__c.getDescribe().getName(), this.BodyStyleId);

        //Trim Badge
        filters = addProperty(filters, Product2.Specification_Pack_Alternative__c.getDescribe().getName(), this.TrimBadgeId);

        //Engine
        filters = addProperty(filters, Product2.Engine_Type_Alternative__c.getDescribe().getName(), this.EngineTypeId);

        //Transmission
        filters = addProperty(filters, Product2.Transmission_Alternative__c.getDescribe().getName(), this.TransmissionId );

        //Doors
        filters = addProperty(filters, Product2.Doors__c.getDescribe().getName(), this.NumberOfDoors);

        //Seats
        filters = addProperty(filters, Product2.Seats__c.getDescribe().getName(), this.NumberOfSeats);

        return filters;
    }

    private Map<String, String> addProperty(Map<String, String> filters, String key, String val) {
        if (String.isNotBlank(val)) {
            filters.put(key, val);
        }
        return filters;

    }

}