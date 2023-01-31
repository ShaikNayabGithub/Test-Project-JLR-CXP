@isTest(SeeAllData=true)
private class ExistingLeadRetriever_Test {
    /*@isTest
    static void LeadExists_ReturnsTrue_GivenMatchingRequestAndAccount() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.RunAs(thisUser)
        {
            AvokaFormInformation_Retriever avokaFormInformationRetriever = new AvokaFormInformation_Retriever();
            ExistingLeadRetriever existingLeadRetriever = new ExistingLeadRetriever();
            
            Account leadAccount = CreateCorporate();
            
            Request__c request = TestClass_RequestCreator.Build();
            AvokaFormInformation avokaFormInformation = avokaFormInformationRetriever.Retrieve(request.Request_Source__c);
            Lead existingLead = CreateFromRequest(request, leadAccount.Id);
            insert existingLead;
            
            boolean result = existingLeadRetriever.LeadExists(request, leadAccount, avokaFormInformation);
            System.assert(result);
        }
    }
    
    @isTest
    static void LeadExists_ReturnsFalse_GivenNewRequestLastNameAndMatchingAccount() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.RunAs(thisUser)
        {  
            AvokaFormInformation_Retriever avokaFormInformationRetriever = new AvokaFormInformation_Retriever();
            ExistingLeadRetriever existingLeadRetriever = new ExistingLeadRetriever();
            
            Account leadAccount = CreateCorporate();
            
            Request__c request = TestClass_RequestCreator.Build();
            AvokaFormInformation avokaFormInformation = avokaFormInformationRetriever.Retrieve(request.Request_Source__c);
            Lead existingLead = CreateFromRequest(request, leadAccount.Id);
            insert existingLead;
            
            request.Last_Name__c = UniqueString.CreateNew();
            
            boolean result = existingLeadRetriever.LeadExists(request, leadAccount, avokaFormInformation);
            System.assert(!result);
        }
    }
    
    @isTest
    static void LeadExists_ReturnsFalse_GivenNewRequestEmailAndMatchingAccount() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.RunAs(thisUser)
        {    
            AvokaFormInformation_Retriever avokaFormInformationRetriever = new AvokaFormInformation_Retriever();
            ExistingLeadRetriever existingLeadRetriever = new ExistingLeadRetriever();
            
            Account leadAccount = CreateCorporate();
            
            Request__c request = TestClass_RequestCreator.Build();
            AvokaFormInformation avokaFormInformation = avokaFormInformationRetriever.Retrieve(request.Request_Source__c);
            Lead existingLead = CreateFromRequest(request, leadAccount.Id);
            insert existingLead;
            
            request.Email__c = UniqueString.CreateNew() + request.Email__c;
            
            boolean result = existingLeadRetriever.LeadExists(request, leadAccount, avokaFormInformation);
            System.assert(!result);
        }
    }*/
    
    static testmethod void LeadExists_ReturnsTrue_GivenMatchingRequestAndAccount() {
        ExistingLeadRetriever existingLeadRetriever = new ExistingLeadRetriever();
        
        Account leadAccount = CreateCorporate();
        Request__c request = TestClass_RequestCreator.Build();
        Lead existingLead = CreateFromRequest(request, leadAccount.Id);
        insert existingLead;
        AvokaFormInformation avokaFormInformation = CreateFormInfoFromLead(existingLead);
        
        boolean result = existingLeadRetriever.LeadExists(request, leadAccount, avokaFormInformation);
        System.assert(result);
    }
    
    static testmethod void LeadExists_ReturnsFalse_GivenNewRequestPhoneMatchingRequestAndAccount() {
        ExistingLeadRetriever existingLeadRetriever = new ExistingLeadRetriever();
        
        Account leadAccount = CreateCorporate();
        Request__c request = TestClass_RequestCreator.Build();
        Lead existingLead = CreateFromRequest(request, leadAccount.Id);
        insert existingLead;
        AvokaFormInformation avokaFormInformation = CreateFormInfoFromLead(existingLead);
        
        request.Mobile__c = '01234567890';
        request.Email__c = UniqueString.CreateNew() + request.Email__c;
        
        boolean result = existingLeadRetriever.LeadExists(request, leadAccount, avokaFormInformation);
        System.assert(!result);
    }
    
    static testmethod void LeadExists_ReturnsTrue_GivenNewRequestLastNameAndMatchingAccount() {
        ExistingLeadRetriever existingLeadRetriever = new ExistingLeadRetriever();
        
        Account leadAccount = CreateCorporate();
        Request__c request = TestClass_RequestCreator.Build();
        Lead existingLead = CreateFromRequest(request, leadAccount.Id);
        insert existingLead;
        AvokaFormInformation avokaFormInformation = CreateFormInfoFromLead(existingLead);
        
        request.Last_Name__c = UniqueString.CreateNew();
        
        boolean result = existingLeadRetriever.LeadExists(request, leadAccount, avokaFormInformation);
        System.assert(result);
    }
    
    static testmethod void LeadExists_ReturnsFalse_GivenNewRequestEmailAndMatchingAccount() {
        ExistingLeadRetriever existingLeadRetriever = new ExistingLeadRetriever();
        
        Account leadAccount = CreateCorporate();
        Request__c request = TestClass_RequestCreator.Build();
        Lead existingLead = CreateFromRequest(request, leadAccount.Id);
        insert existingLead;
        AvokaFormInformation avokaFormInformation = CreateFormInfoFromLead(existingLead);
        
        request.Email__c = UniqueString.CreateNew() + request.Email__c;
        
        boolean result = existingLeadRetriever.LeadExists(request, leadAccount, avokaFormInformation);
        System.assert(!result);
    }
    
    
    private static AvokaFormInformation CreateFormInfoFromLead(Lead lead)
    {
        AvokaFormInformation avokaFormInformation = new AvokaFormInformation();
        
        avokaFormInformation.Brand = lead.Brand__r;
        avokaFormInformation.RecordType = lead.RecordType;
        
        return avokaFormInformation;
    }
    
    private static Account CreateCorporate()
    {
        Account corporate = new Account();
        corporate.Name = 'test corporate';
        corporate.RecordTypeId = [Select Id From RecordType where DeveloperName ='Corporate' and SobjectType ='Account'  limit 1].Id;
        insert corporate;
        
        return corporate;
    }
    
    private static Lead CreateFromRequest(Request__c request, Id accountId)
    {
        Lead lead = new Lead();
        lead.Purchase_Type__c = 'New Vehicle';
        lead.LastName = request.Last_Name__c;
        lead.Email = request.Email__c;
        lead.RecordType = [Select Id From RecordType  Where SobjectType = 'Lead' And IsActive = true And DeveloperName=:'Test_Drive_Request' Limit 1];
        lead.RecordTypeId = lead.RecordType.Id;
        lead.Brand__r = [Select Id From Vehicle_Specification__c Where Name='Jaguar' Limit 1];
        lead.Brand__c = lead.Brand__r.Id;
        lead.Primary_Model_Interest__c = [Select Id From Vehicle_Specification__c Where Name=:request.Primary_Model_Of_Interest_Text__c And Make__c=:lead.Brand__r.Id And Is_Currently_Sold__c = true Limit 1].Id;
        lead.Preferred_Retailer__c = request.Preferred_Retailer__c;
        
        return lead;
    }
}