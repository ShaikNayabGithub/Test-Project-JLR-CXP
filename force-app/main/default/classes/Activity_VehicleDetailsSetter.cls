public class Activity_VehicleDetailsSetter {
    private static final String WHATID_FIELD = Task.WhatId.getDescribe().getName();
    private static final String VIN_FIELD = Task.VIN__c.getDescribe().getName();
    private static final String MODEL_YEAR_FIELD = Task.VIN_Model_Year__c.getDescribe().getName();
    private static final String BRAND_FIELD = Task.VIN_Brand__c.getDescribe().getName();
    private static final String MODEL_FIELD = Task.VIN_Model__c.getDescribe().getName();
    private static final String PRODUCT_NAME_FIELD = Task.VIN_Product_Name__c.getDescribe().getName();
    private static final String DERIVATIVE_NAME_FIELD = Task.VIN_Derivitive_Name__c.getDescribe().getName();
    private static final String LICENSE_PLATE_FIELD = Task.License_Plate__c.getDescribe().getName();
    private static final String VIN_NUMBER_FIELD = Task.VIN_number__c.getDescribe().getName();


    public void SetVehicleDetails(List<SObject> activities)
    {
        Set<String> whatIds = SObjectUtilities.GetFieldValues(activities, WHATID_FIELD);
        List<Asset> assets = [SELECT Id, VIN__c, Model_Year__c, Brand__r.Name, Model__r.Name, Derivative__r.Name, Registration_Number__c,
                Product2.Name FROM Asset WHERE Id IN: whatIds];
        Map<Id, Asset> assetsById = new Map<Id, Asset>(assets);

        for(SObject activity : activities) {
            Object whatId = activity.get(WHATID_FIELD);
            if(whatId == null) { continue; }
            Asset asset = assetsById.get((Id)whatId);
            if(asset == null) { continue; }
            activity.put(VIN_FIELD, asset.VIN__c);
            activity.put(MODEL_YEAR_FIELD, asset.Model_Year__c);
            if(asset.Brand__r != null) {
                activity.put(BRAND_FIELD, asset.Brand__r.Name);
            }
            if(asset.Model__r != null) {
                activity.put(MODEL_FIELD, asset.Model__r.Name); 
            }
            if(asset.Derivative__r != null) {
                activity.put(DERIVATIVE_NAME_FIELD, asset.Derivative__r.Name);
            }
            if(asset.Product2 != null) {
                activity.put(PRODUCT_NAME_FIELD, asset.Product2.Name);
            }
            if(asset.Registration_Number__c != null) {
                activity.put(LICENSE_PLATE_FIELD, asset.Registration_Number__c);
            }
            if(asset.id != null) {
                activity.put(VIN_NUMBER_FIELD, asset.id);
            }
        }
    }

    public void SetVehicleDetails(List<SObject> currentActivities, List<SObject> oldActivities)
    {
        List<SObject> activitiesWithModifiedWhat = SObjectUtilities.GetChanged(currentActivities, 
                oldActivities, new Set<String>{ WHATID_FIELD });
        this.SetVehicleDetails(activitiesWithModifiedWhat);
    }
}