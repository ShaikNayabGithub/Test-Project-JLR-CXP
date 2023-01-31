/**
 * Created by caleb on 10/09/2019.
 */

// todo - update attributes when more about required fields are known
public with sharing class AssetAttributeDto extends AttributesDto
{
    public AssetAttributeDto()
    {

    }

    public AssetAttributeDto(Asset asset)
    {
        this();
        Id = asset.Id;
        VariantId = asset.Product2Id;
        Name = asset.Name;
        AccountId = asset.AccountId;
        Status = asset.Status;
        Product2Id = asset.Product2Id;
        Vin = asset.VIN__c;
        VehicleId = asset.Vehicle_ID__c;
        ExteriorColour = asset.Exterior_Colour__c;
        ExteriorColourGroup = asset.Exterior_Colour_Group__c;
        TrimBadge = asset.Product2.Specification_Pack_Alternative__c;
        InteriorColor = asset.Interior_Color__c;
        RegistrationNumber = asset.Registration_Number__c;
        AccountName = asset.Account.Name;
        MakeName = asset.Product2.Make__r.Name;
        ModelAlternative = asset.Product2.Model_Alternative__c;
        ProductCode = asset.Product2.ProductCode;
        ModelYearAlternative = asset.Product2.Model_Year_Alternative__c;
        SpecificationPackAlternative = asset.Product2.Specification_Pack_Alternative__c;
        Engine = asset.Product2.Engine__c;
        WheelBase = asset.Product2.Wheel_Base__c;
        BodyStyle = asset.Product2.Body_Style__c;
        Transmission = asset.Product2.Transmission__c;
        ModelProductCode = asset.Product2.Model__r.ProductCode;
    }

    @AuraEnabled
    public String Id {get; set;}

    @AuraEnabled
    public String AccountId {get; set;}

    @AuraEnabled
    public String VariantId {get; set;}

    @AuraEnabled
    public String Status {get; set;}

    @AuraEnabled
    public String Product2Id {get; set;}

    @AuraEnabled
    public String Vin {get; set;}

    @AuraEnabled
    public String VehicleId {get; set;}

    @AuraEnabled
    public String ExteriorColourGroup {get; set;}

    @AuraEnabled
    public String ExteriorColour {get; set;}

    @AuraEnabled
    public String InteriorColor {get; set;}

    @AuraEnabled
    public String RegistrationNumber {get; set;}

    @AuraEnabled
    public String AccountName {get; set;}

    @AuraEnabled
    public String MakeName {get; set;}

    @AuraEnabled
    public String ModelAlternative {get; set;}

    @AuraEnabled
    public String ProductCode {get; set;}

    @AuraEnabled
    public String ModelYearAlternative {get; set;}

    @AuraEnabled
    public String SpecificationPackAlternative {get; set;}

    @AuraEnabled
    public String Engine {get; set;}

    @AuraEnabled
    public String WheelBase {get; set;}

    @AuraEnabled
    public String BodyStyle {get; set;}

    @AuraEnabled
    public String TrimBadge {get; set;}

    @AuraEnabled
    public String Transmission {get; set;}

    @AuraEnabled
    public String ModelProductCode {get; set;}
}