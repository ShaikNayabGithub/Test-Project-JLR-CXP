@isTest
private class VME_BatchClassWBSMappingTransform_Test {
    
    public static Product2 product;
    public static Vehicle_Specification__c vehicle;
    
    public static List<VME_WBS_Mapping__c> listOfWBSMapping=new List<VME_WBS_Mapping__c>();

    @testSetup
    public static void dataSetup() {
        User usr = VME_TestDataUtilityClass.createSalesforceUser();
        Insert usr;
        System.runAs(usr){
        
        Id RecordTypeIdProduct = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        product=new Product2();
        product.Name='Test Product';
        product.CurrencyIsoCode='GBP';
        product.ProductCode='X7';
        product.isActive=true;
        insert product;
        
        vehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
        insert vehicle;
        
       // List<VME_WBS_Mapping__c> ls = Test.loadData(VME_WBS_Mapping__c.sObjectType, 'VME_WBS_Mapping_Test_Data');
       List<VME_WBS_Mapping__c> ls =VME_BatchClassWBSMappingTransformData.createBatchData();
       insert ls;
        }
        
        
    }
    public static testMethod void positiveScenario(){
        User usr = [SELECT Id from User WHERE Name='JLR ADMIN' AND Email='admin@jlrutil.comtest' LIMIT 1];
        System.runAs(usr){
            
            VME_BatchClassWBSMappingTransformation  wbsMappingObj= new VME_BatchClassWBSMappingTransformation();
            Test.startTest();        
            Database.executeBatch(wbsMappingObj);
            Test.stopTest();
        }
        
        List<Campaign> campaignList = [SELECT Id,Name,VME_QMSP_Code__c, VME_L1_Adjustment_Reason__c, VME_Actual_Spent__c, VME_Fiscal_Year__c, VME_Adjust_P_U_Amount__c, VME_Adjust_volume__c, VME_Adjust_Budget__c,  VME_Approved_Budget__c, VME_Approved_Volume__c, VME_Approved_P_U_Amount__c, VME_Planned_Volume__c, VME_Planned_Budget__c, VME_Planned_P_U_Amount__c FROM Campaign];
        System.debug('campaignList:::'+campaignList);
         Period quarterDetail = [SELECT Id, FiscalYearSettingsId, Type, StartDate, EndDate, SystemModstamp, IsForecastPeriod, QuarterLabel, PeriodLabel, Number, FullyQualifiedLabel FROM Period WHERE Type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
        System.assertEquals(true,campaignList[0].Name.Contains('V-20-IN02-'+quarterDetail.Number+'-X-X7'),'Checking for campaign name');
        
        List<VME_Schemes__c> vmeSchemeList = [SELECT Id, VME_Start_Date__c, VME_End_Date__c, VME_Campaign__c, VME_JLR_Share__c, VME_Parent_Scheme__c, VME_PU_Amount__c, VME_Verified__c, VME_Retailer__c, VME_Claims_Available__c, VME_Claims_Approved__c, VME_Total_Amount_Approved__c, VME_Total_Amount_Available__c, VME_InActive__c, VME_Revise_Check__c, VME_Consumed_Volume__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, VME_Total_VME__c, VME_Color_Code_Exterior__c, VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, VME_Retailer_Contribution__c, VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c, VME_Type__c FROM VME_Schemes__c];
        System.assertEquals(true,vmeSchemeList[0].VME_Level_3_Description__c.Contains('MY18 Jan - Sept Mfd Stock'),'Checking for scheme L3 Description');
        
        
    }
    
    
}