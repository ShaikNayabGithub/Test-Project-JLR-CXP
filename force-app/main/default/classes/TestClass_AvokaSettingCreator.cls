public class TestClass_AvokaSettingCreator {
    public static void InsertBrandMapping(String formName, String brand)
    {
        AvokaFormMapping_Brand__c brandMapping = AvokaFormMapping_Brand__c.getInstance(formName);
        if(brandMapping != null) { return; }
        
        brandMapping = new AvokaFormMapping_Brand__c();
        brandMapping.Name = formName;
        brandMapping.Salesforce_Value__c = brand;
        insert brandMapping;
    }
    
    public static void InsertRecordTypeMapping(String formName, String recordType)
    {
        AvokaRequestTypeToLeadRecordType__c recordTypeMapping = AvokaRequestTypeToLeadRecordType__c.getInstance(formName);
        if(recordTypeMapping != null) { return; }
        
        recordTypeMapping = new AvokaRequestTypeToLeadRecordType__c();
        recordTypeMapping.Name = formName;
        recordTypeMapping.Lead_Record_Type__c = recordType;
        insert recordTypeMapping;
    }
    
    public static void InsertLocalMapping(String name, String currencyCode, String countryCode, String nscQueue)
    {
        AvokaFormMapping_Local__c localMapping = AvokaFormMapping_Local__c.getInstance(name);
        if(localMapping != null) { return; }
        
        localMapping = new AvokaFormMapping_Local__c();
        localMapping.Name = name;
        localMapping.Currency__c = currencyCode;
        localMapping.Country_ISO_Code__c = countryCode;
        localMapping.NSC_Queue__c = nscQueue;
        insert localMapping;
    }
}