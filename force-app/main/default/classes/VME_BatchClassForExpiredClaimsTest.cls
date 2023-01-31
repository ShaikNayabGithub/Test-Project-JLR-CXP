/******************************************************************************************
*  Name        : VME_BatchClassForExpiredClaimsTest
*  
*  Company     : Marlabs 
*    
*  Purpose     : Test class to update Expired Claims- Batch
* 
*  Developer   : Tejashree J
*
*  Created Date: 07/08/2019 
*
*  Modified : 
----------------------------------------------------------------------
*/
@isTest
private class VME_BatchClassForExpiredClaimsTest {
    public static Account ac;
    public static Product2 prod;
    public static Vehicle_Specification__c brand;
    public static VME_Campaign__c vmeCampaign;
    public static Asset vin;
    public static VME_Schemes__c scheme;
    public static VME_Claims__c claim;
    public static VME_Claims__c claim2;
    
    @testSetup
    public static void initialize() {
        ac = new Account(name = 'Test Partner Account'); 
        ac.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();
        insert ac;
        brand = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar Test');
        insert brand;
        List<Asset> vinList = new List<Asset>();
        vin = VME_TestDataUtilityClass.createVIN();
        vin.AccountId = ac.Id;
        vin.Brand__c = brand.Id;
        vin.VME_Retail_Date__c = System.today();
        vin.RecordTypeId=Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
        vin.Retailer_Name__c = ac.Id;
        vinList.add(vin);
        insert vinList;
        prod = new Product2();
        prod = VME_TestDataUtilityClass.CreateModelProduct('XJ', '5000341196', 'XE');
        insert prod;
        Campaign qmspRec = new Campaign();
        qmspRec = VME_TestDataUtilityClass.init_QMSP_Record();
        qmspRec.QMSP_Model__c = prod.Id;
        qmspRec.VME_Brand__c = brand.Id;
        insert qmspRec;
        List<VME_Campaign__c> vmeCampaignList = new List<VME_Campaign__c>();
        vmeCampaign = VME_TestDataUtilityClass.vme_Camp_init();
        vmeCampaign.QMSP_Campaign__c = qmspRec.Id;
        vmeCampaign.VME_Brand__c = brand.Id;
        vmeCampaign.VME_Model__c = prod.Id;
        vmeCampaign.VME_Category__c = 'Retail Non-Finance';
        vmeCampaign.VME_Sub_Category__c = 'Cash Programmes';
        vmeCampaignList.add(vmeCampaign);
        insert vmeCampaignList;
        List < VME_Schemes__c > schemeListToInsert= new List < VME_Schemes__c >(); 
        scheme = VME_TestDataUtilityClass.vme_Schemes_Init(Date.Today(),Date.Today().addDays(15),70,12400,'Parent','Others','');
        scheme.VME_Campaign__c = vmeCampaign.Id;
        scheme.VME_Level_3_Description__c = 'MY18 Oct - Dec Mfd Stock';
        schemeListToInsert.add(scheme);
        insert schemeListToInsert;
        List<VME_Claims__c> claimListToInsert = new List<VME_Claims__c>();
        claim = VME_TestDataUtilityClass.claims_Init();
        claim.VME_Number_Of_Attachments__c = 0;
        claim.VME_Region_Market__c = 'IN';
        claim.VME_Related_Scheme__c = scheme.Id;
        claim.VME_Country_ISO_Code__c = 'IN';
        claim.VME_Status__c = 'Generated';
        claim.VME_VIN__c = vin.Id;
        claim.VME_Maximum_Attempts__c = 5;
        claim.VME_Last_Date_of_Submissiom__c = System.today().addDays(-1);
        claim.VME_Last_Resubmission_Date__c = Date.today().addDays(30);
        claim2 = VME_TestDataUtilityClass.claims_Init();
        claim2.VME_Number_Of_Attachments__c = 0;
        claim2.VME_Region_Market__c = 'IN';
        claim2.VME_Related_Scheme__c = scheme.Id;
        claim2.VME_Country_ISO_Code__c = 'IN';
        claim2.VME_Status__c = 'Generated';
        claim2.VME_VIN__c = vin.Id;
        claim2.VME_Maximum_Attempts__c = 5;
        claim2.VME_Last_Date_of_Submissiom__c = System.today().addDays(-1);
        claim2.VME_Last_Resubmission_Date__c = Date.today().addDays(30);
        claimListToInsert.add(claim2);
        insert claimListToInsert;
    }
    @isTest static void updateExpiredClaims_Testmethod1() {
        Test.startTest();
        String batchid = VME_BatchClassForExpiredClaimsScheduler.scheduleMe();
        System.debug(batchid);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : batchid];
        System.assertEquals(0, ct.TimesTriggered, 'Checking whether the job is scheduled or not');
        Test.stopTest();                
    }
    
}