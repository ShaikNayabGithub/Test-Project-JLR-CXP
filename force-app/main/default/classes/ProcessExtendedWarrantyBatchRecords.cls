public with sharing class ProcessExtendedWarrantyBatchRecords implements Database.Batchable<sObject>, Schedulable{
    
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new ProcessExtendedWarrantyBatchRecords());
     }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(System.Label.Extended_Warranty_Query);
    }

    public void execute(Database.BatchableContext bc, List<Extended_Warranty_Staging__c> records){
        // process each batch of records
        map<String, Extended_Warranty__c> mapOfKeyToListOfExtendedWarranty = 
            new map<String, Extended_Warranty__c>();
        for(Extended_Warranty_Staging__c extended : records){
            mapOfKeyToListOfExtendedWarranty.put(extended.Policy_Number__c, returnExtendedWarrantyRecord(extended));            
        }


        if(mapOfKeyToListOfExtendedWarranty.size() > 0){
            upsert mapOfKeyToListOfExtendedWarranty.values() Policy_Number__c;
        }

    
    }
    public void finish(Database.BatchableContext bc){
        delete [SELECT Id FROM Extended_Warranty_Staging__c LIMIT 9999];
    }

    public static Extended_Warranty__c returnExtendedWarrantyRecord(Extended_Warranty_Staging__c staging){
        return new Extended_Warranty__c(
            Business_Partner_Name__c = staging.Business_Partner_Name__c,
            Code__c = staging.Code__c,
            Country__c = staging.Country__c,
            Country_NW__c = staging.Country_NW__c,
            Coverage1__c = staging.Coverage1__c,
            End_Date__c = staging.End_Date__c,
            IPT__c = staging.IPT__c,
            Manufacturer_Account_Number__c = staging.Manufacturer_Account_Number__c,
            Mileage_at_Purchase__c = staging.Mileage_at_Purchase__c,
            Mileage_Coverage_NW__c = staging.Mileage_Coverage_NW__c,
            Net_Cost__c = staging.Net_Cost__c,
            Policy_Count__c = staging.Policy_Count__c,
            Policy_Duration__c = staging.Policy_Duration__c,
            Policy_Number__c = staging.Policy_Number__c,
            Product_Name__c = staging.Product_Name__c,
            Program_Name__c = staging.Program_Name__c,
            Provider__c = staging.Provider__c,
            Purchase_Date__c = staging.Purchase_Date__c,
            Sales_Person_Initials__c = staging.Sales_Person_Initials__c,
            Retailer_Name__c = staging.Retailer_Name__c,
            Start_Date__c = staging.Start_Date__c,
            Status__c = staging.Status__c,
            Total_Cost__c = staging.Total_Cost__c,
            VAT__c = staging.VAT__c,
            Vehicle_Model__c = staging.Vehicle_Model__c,
            VIN__c = staging.VIN__c);

    }

}