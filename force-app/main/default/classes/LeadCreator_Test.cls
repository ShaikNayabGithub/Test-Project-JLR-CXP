@isTest(SeeAllData=true)
private class LeadCreator_Test {
    static testMethod void Create_InsertsNoRecords_GivenInvalidRequest() 
    {
      TestClass_AvokaSettingCreator.InsertBrandMapping('jag', 'Jaguar');
      TestClass_AvokaSettingCreator.InsertRecordTypeMapping('tdsf', 'Test_Drive_Request');
      TestClass_AvokaSettingCreator.InsertLocalMapping('in', 'INR', 'IN', 'India NSC Queue');

        LeadBuilder leadBuilder = CreateLeadBuilder();//horrible, consider mocking
        LeadCreator leadCreator = new LeadCreator(leadBuilder);
        
        Request__c requestRecord = TestClass_RequestCreator.Build();
        requestRecord.Email__c = null;
        Account existingAccount = new Account();
        AvokaFormInformation avokaFormInformation = BuildAvokaFormInformation();
        
        leadCreator.Create(requestRecord, existingAccount, avokaFormInformation);
        integer numberOfRecordsInserted = [Select Id From Lead Where LastName =:requestRecord.Last_Name__c].size();
        
        System.assertEquals(0, numberOfRecordsInserted);
    }
    
    static testMethod void Create_InsertsOneLead_GivenValidRequest() 
    {
      TestClass_AvokaSettingCreator.InsertBrandMapping('jag', 'Jaguar');
      TestClass_AvokaSettingCreator.InsertRecordTypeMapping('tdsf', 'Test_Drive_Request');
      TestClass_AvokaSettingCreator.InsertLocalMapping('in', 'INR', 'IN', 'India NSC Queue');
        
    LeadBuilder leadBuilder = CreateLeadBuilder();//horrible, consider mocking
        LeadCreator leadCreator = new LeadCreator(leadBuilder);
        
        Request__c requestRecord = TestClass_RequestCreator.Build();
        Account existingAccount = new Account();
        AvokaFormInformation avokaFormInformation = BuildAvokaFormInformation();
        
      leadCreator.Create(requestRecord, existingAccount, avokaFormInformation);
        integer numberOfRecordsInserted = [Select Id From Lead Where LastName =:requestRecord.Last_Name__c].size();
        
        System.assertEquals(1, numberOfRecordsInserted);
    }
    
    static testMethod void Create_InsertsOneCampaignMember_GivenValidRequest() 
    {
      TestClass_AvokaSettingCreator.InsertBrandMapping('jag', 'Jaguar');
      TestClass_AvokaSettingCreator.InsertRecordTypeMapping('tdsf', 'Test_Drive_Request');
      TestClass_AvokaSettingCreator.InsertLocalMapping('in', 'INR', 'IN', 'India NSC Queue');
        
        LeadBuilder leadBuilder = CreateLeadBuilder();//horrible, consider mocking
        LeadCreator leadCreator = new LeadCreator(leadBuilder);
        
        Request__c requestRecord = TestClass_RequestCreator.Build();
        Account existingAccount = new Account();
        AvokaFormInformation avokaFormInformation = BuildAvokaFormInformation();
        
      leadCreator.Create(requestRecord, existingAccount, avokaFormInformation);
        integer numberOfRecordsInserted = [Select Id From CampaignMember Where CampaignId =:requestRecord.Campaign__c].size();
        
        System.assertEquals(1, numberOfRecordsInserted);
    }
    
    private static AvokaFormInformation BuildAvokaFormInformation()
    {
      AvokaFormInformation avokaFormInformation = new AvokaFormInformation();
        avokaFormInformation.AssignToRetailerQueue = true;
        avokaFormInformation.NSCQueue = [Select Id From Group Where Name='India NSC Queue' AND Type = 'Queue' limit 1];
        return avokaFormInformation;
    }

    private static LeadBuilder CreateLeadBuilder()
    {
        ModelRetriever modelRetriever = new ModelRetriever();
        return new LeadBuilder(modelRetriever);
    }
}