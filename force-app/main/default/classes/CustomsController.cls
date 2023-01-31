public with sharing class CustomsController {
    // Class originally covered Customs Logistics process,
    // Extended to Cover Wholesale (using same getAssets method) and PDI Requests
    // Extended to Permissions for these requests

    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssets(){

        List<Asset> assetRecords = [
            SELECT 
                Id, Name,VIN__c,Model_Text__c,Account_Local__c, Order_Number__c, Engine_Variant__c, Model_Year__c, 
                Homologation_Completion_Status__c, Remarks__c, Sale_Type_Code__c,
                Customs_Clearance_Status__c, Custom_Clearance_Completion_Date__c, Custom_Clearance_Receipt_Date__c, Custom_Clearance_Request_Date__c, 
                Order_Type__c, Expected_Wholesale_Activation_Date__c, Wholesale_Activation_Date__c, Wholesale_Activation_Status__c, Wholesale_Settlement_Date__c,
                PDI_Completion_request_date__c, Arrival_Date__c, ETA__c,
                (SELECT Id, Name, ProductCode FROM ChildAssets WHERE RecordType.DeveloperName = 'Vehicle_Option' ORDER BY Name ASC)
                 
            FROM Asset
            WHERE RecordType.DeveloperName = 'Vehicle' 
            AND Handover_Date__c = null AND Arrival_Date__c != null
            ORDER BY LastModifiedDate DESC
        ];

        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, assetRecords);


        return securityDecision.getRecords();
    }

    @AuraEnabled
    public static string submitCustoms(String jsonData){
        List<Asset> assetsToUpdate = (List<Asset>) JSON.deserialize(jsonData, List<Asset>.class);

        customsControllerResponseWrapper ccrw = new customsControllerResponseWrapper();

        
        try {
            update assetsToUpdate;
            ccrw.message = 'Success';
            ccrw.statusCode = 200;
        } catch (Exception e) {
            ccrw.message = e.getMessage();
            ccrw.statusCode = 500;
        }

        return JSON.serialize(ccrw);
    }

    private class customsControllerResponseWrapper {
        public String message;
        public Integer statusCode;
        public userPermissions permissions;
    }

    private class userPermissions {
        public Boolean hasWholesaleRetailerActionsUser;
        public Boolean hasWholesaleFinancePartnerActionsUser;
        public Boolean hasWholesaleNscActionsUser;

        public Boolean hasPdiRequestRetailerActionsUser;
        public Boolean hasPdiRequestAgencyActionsUser;
        public Boolean hasPdiRequestNscActionsUser;

        public Boolean hasCustomsClearanceRetailerActionsUser;
        public Boolean hasCustomsClearanceAgencyActionsUser;
        public Boolean hasCustomsClearanceNscActionsUser;
    }


    @AuraEnabled(cacheable=true)
    public static List<PDI_Request__c> getPdiRequests(){
        return [
            SELECT 
                Id, CreatedDate, Requested_Completion_Date__c, Request_Submitted_Date__c, PDI_Status__c, Remark__c, 
                Requested_Delivery_Date__c, Requesting_User__c, Delivery_Location__c, Delivery_Location__r.Delivery_Location__c, 
                Delivery_Location__r.Delivery_Address__c, Vehicle__c, Vehicle__r.Brand__r.Name, Vehicle__r.Model__r.Name, 
                Vehicle__r.Retailer_Account_Name__c, Requesting_User__r.Name, Vehicle__r.VIN__c, Vehicle__r.Order_Number__c,
                WHS_Status__c, Customs_Status__c, Vehicle__r.Arrival_Date__c

            FROM PDI_Request__c
            WHERE Vehicle__r.Handover_Date__c = null AND Vehicle__r.Arrival_Date__c != null
        ];
    }

    @AuraEnabled
    public static string submitPdi(String jsonData){
        
        List<PDI_Request__c> assetsToUpdate = (List<PDI_Request__c>) JSON.deserialize(jsonData, List<PDI_Request__c>.class);

        customsControllerResponseWrapper ccrw = new customsControllerResponseWrapper();

        
        try {
            update assetsToUpdate;
            ccrw.message = 'Success';
            ccrw.statusCode = 200;
        } catch (Exception e) {
            ccrw.message = e.getMessage();
            ccrw.statusCode = 500;
        }

        return JSON.serialize(ccrw);
    }

    @AuraEnabled(cacheable=true)
    public static String getUserPermissions(){
        customsControllerResponseWrapper ccrw = new customsControllerResponseWrapper();
        userPermissions perms = new userPermissions();
        perms.hasWholesaleRetailerActionsUser = FeatureManagement.checkPermission('Wholesale_Retail_Actions_User');
        perms.hasWholesaleFinancePartnerActionsUser = FeatureManagement.checkPermission('Wholesale_Finance_Partner_Actions_User');
        perms.hasWholesaleNscActionsUser = FeatureManagement.checkPermission('Wholesale_NSC_Actions_User');
        
        perms.hasPdiRequestRetailerActionsUser = FeatureManagement.checkPermission('PDI_Request_Retail_Actions_User');
        perms.hasPdiRequestAgencyActionsUser = FeatureManagement.checkPermission('PDI_Request_Agency_Actions_User');
        perms.hasPdiRequestNscActionsUser = FeatureManagement.checkPermission('PDI_Request_NSC_Actions_User');

        perms.hasCustomsClearanceRetailerActionsUser = FeatureManagement.checkPermission('Customs_Clearance_Retail_Actions_User');
        perms.hasCustomsClearanceAgencyActionsUser = FeatureManagement.checkPermission('Customs_Clearance_Agency_Actions_User');
        perms.hasCustomsClearanceNscActionsUser = FeatureManagement.checkPermission('Customs_Clearance_NSC_Actions_User');

        ccrw.permissions = perms;
        return JSON.serialize(ccrw);

    }
}