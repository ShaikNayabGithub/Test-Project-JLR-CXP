/**************************************************************************    
Class Name    : SaveVehicleEnquiryTest

Description   : This class is used for testing functionality of 
SaveVehicleEnquiry 
CreatedDate   : 10 Sep 2019         
Version       : 1.0     
Author        : TCS
**************************************************************************/
@isTest
public class SaveVehicleEnquiryTest {

   
     @testSetup static void createData()
    {
        CreateTestData tdata = new CreateTestData();
        tdata.loadJUDAANMarketSettingsData();
        String market = 'BR';
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.createAssets(market);
        
    }
    // This method will test the successful insertion of Lead for Brazil Market.
    public static testMethod void createTestLead()
    {
        SaveVehicleEnquiry objVE = new SaveVehicleEnquiry();
        objVE.firstName = 'testLead';
        objVE.lastName = 'testLead';
        objVE.email = 'testLead@test.com';
        objVE.phone  = '12345678';  
       
        Asset objAsset = [select id from asset limit 1];
        Id assetId = objAsset.id; 
        Id rtIdforNSC = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('NSC').getRecordTypeId();
        
        Campaign objCampaign = new Campaign();
        objCampaign.Name = Label.OSA_BRAZIL_Campaign_Name;
        objCampaign.isActive = true;
        objCampaign.recordtypeId = rtIdforNSC;
        objCampaign.Type= 'PRO';
        objCampaign.Market_ID__c= 'BR';

        insert objCampaign;
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('market', 'br');
        SaveVehicleEnquiry mainObjVE = new SaveVehicleEnquiry();
        String errorMsg = mainObjVE.createLead(objVE, assetId);  
        System.assert(errorMsg == 'success');
        test.stopTest();
    }
    // To test value required validation this method is implemented(negative scenario).
    public static testMethod void createTestLeadValidate()
    {
        SaveVehicleEnquiry objVE = new SaveVehicleEnquiry();
        
        objVE.lastName = 'testLead';
        objVE.email = 'testLead@test.com';
        objVE.phone  = '123456';  
        Id assetId = '1011q000000BBBB';
        test.startTest();
        SaveVehicleEnquiry mainObjVE1 = new SaveVehicleEnquiry();
        String errorMsg = mainObjVE1.createLead(objVE, assetId);   
        System.assert(errorMsg == Label.Required_Error_Message);
        test.stopTest();
    }
    // To test phone number validation this method is implemented(negative scenario).
     public static testMethod void createTestLeadValidatePhone()
    {
        SaveVehicleEnquiry objVE = new SaveVehicleEnquiry();
        objVE.firstName = 'testLead';
        objVE.lastName = 'testLead';
        objVE.email = 'testLead@test.com';
        objVE.phone  = '123456';  
        Id assetId = '1011q000000AAAA';
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('market', 'br');
        SaveVehicleEnquiry mainObjVE2 = new SaveVehicleEnquiry();
        String errorMsg = mainObjVE2.createLead(objVE, assetId);
        System.assert(errorMsg == Label.Brazil_Phone_Number);
        test.stopTest();
    }
    // To test phone number validation this method is implemented(negative scenario).
     public static testMethod void createTestLeadValidatePhoneSG()
    {
        SaveVehicleEnquiry objVE = new SaveVehicleEnquiry();
        objVE.firstName = 'testLead';
        objVE.lastName = 'testLead';
        objVE.email = 'testLead@test.com';
        objVE.phone  = '123456';  
        objVE.isPhone = false;
        objVE.isEmail = false;
        objVE.isSMS= false;
        objVE.strleadtype = 'General Enquiry';
        objVE.strDescription  ='Test';
        
        Id assetId = '1011q000000AAAA';
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('market', 'sg');
        SaveVehicleEnquiry mainObjVE2 = new SaveVehicleEnquiry();
        String errorMsg = mainObjVE2.createLead(objVE, assetId);
        
        test.stopTest();
    }
    
     // To test phone number validation this method is implemented(negative scenario).
     public static testMethod void createTestLeadValidatePhonejp()
    {
        SaveVehicleEnquiry objVE = new SaveVehicleEnquiry();
        objVE.firstName = 'testLead';
        objVE.lastName = 'testLead';
        objVE.email = 'testLead@test.com';
        objVE.phone  = '123456';  
        objVE.isPhone = false;
        objVE.isEmail = false;
        objVE.isSMS= false;
        objVE.strleadtype = 'General Enquiry';
        objVE.strDescription  ='Test';
        
        //Id assetId = '1011q000000AAAA';
        Asset objAsset = [select id from asset limit 1];
        Id assetId = objAsset.id; 
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('market', 'jp');
        SaveVehicleEnquiry mainObjVE2 = new SaveVehicleEnquiry();
        String errorMsg = mainObjVE2.createLead(objVE, assetId);
        
        test.stopTest();
    }
}