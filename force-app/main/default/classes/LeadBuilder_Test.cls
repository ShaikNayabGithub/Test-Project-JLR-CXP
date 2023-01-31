@isTest
private class LeadBuilder_Test {
    
    @isTest
    static void Build_ReturnsLead_GivenEmptyObjects() {
        LeadBuilder leadBuilder = BuildLeadBuilder();
        
        Request__c request = new Request__c();
        Account account = new Account();
        AvokaFormInformation avokaFormInformation = new AvokaFormInformation();
        avokaFormInformation.NSCQueue = [Select Id from Group Where Type = 'Queue' limit 1][0];
        
        Lead result = leadBuilder.Build(request, account, avokaFormInformation);
        
        System.assertNotEquals(null, result);
    }
    
    @isTest(SeeAllData=true)
    static void Build_SetsOwnerId_WhenCalled() {//no reliable way to test ownership
        LeadBuilder leadBuilder = BuildLeadBuilder();
        Request__c request = new Request__c();
        Account account = new Account();
        AvokaFormInformation avokaFormInformation = new AvokaFormInformation();
        avokaFormInformation.NSCQueue = [Select Id from Group Where Type = 'Queue' limit 1][0];

        Lead result = leadBuilder.Build(request, account, avokaFormInformation);

        System.assertNotEquals(null, result.OwnerId);
    }

    @isTest
    static void Build_SetRetailerContactTrue() {
        LeadBuilder leadBuilder = BuildLeadBuilder();
        
        Request__c request = new Request__c();
        request.Preferred_Retailer_Code__c = '49841';
        request.Brand__c = 'Jaguar';
        request.Assign_To_Queue__c = false;
       
        Account account = new Account();
        account.Queue_ID__c = '00G24000001Pv7p';
        account.Retailer_Status__c = 'Trading';
        account.Secondary_Dealer_Code__c = 'LRIN49841';
        
        AvokaFormInformation avokaFormInformation = new AvokaFormInformation();
        avokaFormInformation.AssignToRetailerQueue = true;
        
        avokaFormInformation.NSCQueue = [Select Id from Group Where Type = 'Queue' limit 1][0];
        
        Lead result = leadBuilder.Build(request, account, avokaFormInformation);
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void Build_SetRetailerContactFalse() {
        
        Group queueName = new group();
        queueName.Name = 'India Marketing Call Queue';
        queueName.Type = 'Queue';
        
        insert queueName;
        
        Account account = TestClass_AccountCreator.BuildRetailer();
        account.Queue_ID__c = '00G24000001Pv7p';
        account.Secondary_Dealer_Code__c = 'LRIN49841';
        insert account;
        
        Vehicle_Specification__c vehSpec = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c vehSpecModel = TestClass_VehicleSpecificationBuilder.BuildModel(vehSpec);
        
        LeadBuilder leadBuilder = BuildLeadBuilder();
        
        Request__c request = new Request__c();
        request.Preferred_Retailer_Code__c = 'LRIN49841';
        request.Brand__c = 'Jaguar';
        request.Description__c = 'This is some text';
        request.Request_Source__c = 'lr-peb-in-en';
        request.Assign_To_Queue__c = true;
        request.Primary_Model_Of_Interest_Text__c = 'M1';
       
        Id queryAccount = [Select id from Account].id;
        
        Account account2 = new Account();
        account2.Queue_ID__c = '00G24000001Pv7p';
        account2.Retailer_Status__c = 'Trading';
        account2.Secondary_Dealer_Code__c = 'LRIN49841';
        account2.ParentId = queryAccount;
        
        AvokaFormInformation avokaFormInformation = new AvokaFormInformation();
        avokaFormInformation.AssignToRetailerQueue = false;
        avokaFormInformation.Brand = vehSpec;
        avokaFormInformation.CountryISOCode = 'in';
        
        avokaFormInformation.NSCQueue = [Select Id from Group Where Type = 'Queue' limit 1][0];
        
        Lead result = leadBuilder.Build(request, account, avokaFormInformation);
        
        System.assertNotEquals(null, result);
    }
    
    private static LeadBuilder BuildLeadBuilder()
    {
        ModelRetriever modelRetriever = new ModelRetriever();
        return new LeadBuilder(modelRetriever);
    }
    
    //could do with some more, although class only assigns variables - very little can go wrong
}