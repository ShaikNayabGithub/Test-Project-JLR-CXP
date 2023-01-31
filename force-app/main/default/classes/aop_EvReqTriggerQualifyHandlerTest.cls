@isTest
public class aop_EvReqTriggerQualifyHandlerTest {   
    static Account GetTestAccount()
    {
        Account newAccount = new Account(Name = 'AcctNme', Dealer_CI_Code__c = 'DealerCode', Secondary_Dealer_Code__c = 'JISODealerCode');
        insert newAccount;
        return newAccount;
    }
    
    static TestMethod void TestCheckCommunityAccessDoesntSetNoNeedQualifyIfNoUser()
    {
        Contact newCon = new Contact(LastName = 'jones', email ='abc@jkl.com');
        insert newCon;
        Request__C evReq = new Request__C(aop_Customer__c = newCon.Id, aop_Status__c = 'Submitted');        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        evReq = handler.CheckContactCommunityAccess(evReq);

        System.assertNotEquals('No Qualification Required', evReq.aop_Status__c);
    }
    
    static TestMethod void TestQualifyRetailerEvReqSetsStatusQualifiedWRetailer()
    {
        Account newAccount = GetTestAccount();
        List<Account> accountList = new List<Account>();
        accountList.add(newAccount);
        Request__C evReq = new Request__C(aop_Status__c = 'Submitted', Preferred_Retailer__c = newAccount.Id);        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        evReq = handler.QualifyRetailerEventRequest(evReq, accountList);

        System.assertEquals('Qualified', evReq.aop_Status__c);
    }
    
    static TestMethod void TestQualifyRetailerEvReqSetsStatusQualifiedWRetailerCode()
    {
        aop_NationalityToISOCode__c countryMap = new aop_NationalityToISOCode__c(Name = 'Britain', aop_ISO_Code__c = 'ISO', aop_Checkfront_Instance__c = 'a@b.com');
        insert countryMap;
        Account newAccount = GetTestAccount();
        List<Account> accountList = new List<Account>();
        accountList.add(newAccount);
        Request__C evReq = new Request__C(aop_Status__c = 'Submitted', aop_Country__c = 'Britain', Preferred_Retailer_Code__c = 'DealerCode');        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        evReq = handler.QualifyRetailerEventRequest(evReq, accountList);

        System.assertEquals('Qualified', evReq.aop_Status__c);
        System.assertEquals(newAccount.ID, evReq.Preferred_Retailer__c);
    }
    
    static TestMethod void TestAssignToRetailerQueueAssignsToQueue()
    {
        Group newQueue = new Group(Name = 'queueueue');
        insert newQueue;
        Request__C evReq = new Request__C(aop_Status__c = 'Submitted', Preferred_Retailer_Code__c = 'DealerCode');        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        evReq = handler.AssignToNamedQueue(evReq, 'queueueue');

        System.assertEquals(newQueue.ID, evReq.OwnerId);
    }
    
    static TestMethod void TestIsCustomerOldEnoughReturnsTrueIfOldEnough()
    {
        DateTime now = DateTime.now();
        DateTime before = now.addYears(-30);
        Date beforeDate = before.date();
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Minimum_Age__c = 1);
        Request__C evReq = new Request__C(aop_Date_Of_Birth__C = beforeDate, aop_Status__c = 'Submitted',  Preferred_Retailer_Code__c = 'DealerCode');        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        Boolean result = handler.IsCustomerOldEnough(evReq, eventConfig);

        System.assert(result);
    }

    static TestMethod void TestQualifyByOpenOpportunityDoesntChangeStatusNoOpp()
    {
        Account newAccount = GetTestAccount();
        Contact con = new Contact(LastName = 'Connie', AccountID = newAccount.Id, Email = 'a@b.com');
        insert con;
        Request__C evReq = new Request__C(aop_Status__c = 'Submitted',  Preferred_Retailer_Code__c = 'DealerCode', aop_Customer__c = con.Id);        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        evReq = handler.QualifyByOpenOpportunity(evReq);

        System.assertNotEquals('Qualified', evReq.aop_Status__c);
    }
    
    static TestMethod void TestQualifyByOpenOpportunityQualifiesRequestWOpp()
    {
        Account newAccount = GetTestAccount();
        Contact con = new Contact(LastName = 'Connie', AccountID = newAccount.Id, Email = 'a@b.com');
        insert con;
        //stagename closedate brand
        Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'Jaguar');
        insert newBrand;
        Opportunity opp = new Opportunity(Name = 'OppName', AccountId = newAccount.Id, CloseDate = Date.today(), StageName = 'Contacted', Brand__c = newBrand.Id);
        insert opp;
        Request__C evReq = new Request__C(aop_Status__c = 'Submitted', Preferred_Retailer_Code__c = 'DealerCode', aop_Customer__c = con.Id);        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        evReq = handler.QualifyByOpenOpportunity(evReq);

        System.assertEquals('Qualified', evReq.aop_Status__c);
    }
    
    static TestMethod void TestCurrentBrandRelatedToConfigReturnsFalseIfBrandNull()
    {
        Request__C evReq = new Request__C(aop_Status__c = 'Submitted',  Preferred_Retailer_Code__c = 'DealerCode');        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Minimum_Age__c = 1);
        boolean result = handler.CurrentBrandRelatedToConfig(evReq, eventConfig);

        System.assertNotEquals(true, result);
    }
    
    static TestMethod void TestCurrentBrandRelatedToConfigReturnsTrueIfBrandRelatedToConfig()
    {
        Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'Jaguar');
        insert newBrand;
        Request__C evReq = new Request__C(aop_Status__c = 'Submitted',  Preferred_Retailer_Code__c = 'DealerCode', Current_Vehicle_Brand__C = newBrand.Id);        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Retailer_Queue_Name__c = 'name', aop_Customer_Queue_Name__c = 'name', aop_Spotify_Link__c = 'spotify.com', aop_Rebooking_Window__c = 1.4, aop_NSC_Contact_Phone__c = '083633', aop_NSC_Contact_Email__c = 'a@b.com', aop_Community_URL__C = 'www.facebook.com', aop_Checkfront_Token__c = 'abcdefg', aop_Community_Permission_Set__c = 'abcdefg', aop_AWS_Path__C = 'abc', aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_AOP_Id__c = '1', aop_Minimum_Age__c = 1);
        insert eventConfig;
        aop_Area_Competitor__c competition = new aop_Area_Competitor__c(aop_Event_Configuration__c = eventConfig.Id, aop_Vehicle_Brand__C = newBrand.Id);
        insert competition;
        boolean result = handler.CurrentBrandRelatedToConfig(evReq, eventConfig);

        System.assertEquals(true, result);
    }
    
    static TestMethod void TestQualifyByRulesDoesntChangeQualifiedEvReq()
    {
        Request__C evReq = new Request__C(aop_Status__c = 'Qualified',  Preferred_Retailer_Code__c = 'DealerCode');        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Qualify_If_Opportunity__c = false, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_AOP_Id__c = '1', aop_Minimum_Age__c = 1);
        Request__c result = handler.QualifyByRules(evReq, eventConfig);

        System.assertEquals('Qualified', result.aop_Status__C);
    }
    
    static TestMethod void TestQualifyByRetailerDoesntSetOwnerIfQualified()
    {
        Request__C evReq = new Request__C(aop_Status__c = 'Qualified',  Preferred_Retailer_Code__c = 'DealerCode');        
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Retailer_Queue_Name__c = 'QName', aop_Qualify_If_Opportunity__c = false, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_AOP_Id__c = '1', aop_Minimum_Age__c = 1);
        Request__c result = handler.QualifyByRetailer(evReq, eventConfig);

        System.assertEquals(evReq.OwnerId, result.OwnerId);
    }
    
    static TestMethod void TestQualifyByRetailerSetsOwnerIfSubmitted()
    {
        Request__C evReq = new Request__C(aop_Status__c = 'Submitted',  Preferred_Retailer_Code__c = 'DealerCode');  
        Group newGroup = new Group(Name = 'QName');
        insert newGroup;
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Retailer_Queue_Name__c = 'QName', aop_Qualify_If_Opportunity__c = false, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_AOP_Id__c = '1', aop_Minimum_Age__c = 1);
        Request__c result = handler.QualifyByRetailer(evReq, eventConfig);

        System.assertEquals(evReq.OwnerId, newGroup.Id);
    }
    
    static TestMethod void TestQualifyByRulesQualifiesRequestIfLicense()
    {
        Request__C evReq = new Request__C(aop_Valid_Driving_License__c = true, aop_Status__c = 'Submitted',  Preferred_Retailer_Code__c = 'DealerCode');
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Customer_Queue_Name__c = 'Q', aop_Spotify_Link__c = 'spotify.com', aop_Rebooking_Window__c = 1.4, aop_NSC_Contact_Phone__c = '083633', aop_NSC_Contact_Email__c = 'a@b.com', aop_Community_URL__C = 'www.facebook.com', aop_Checkfront_Token__c = 'abcdefg', aop_Community_Permission_Set__c = 'abcdefg', aop_AWS_Path__C = 'abc', aop_Retailer_Queue_Name__c = 'QName', aop_Qualify_If_Opportunity__c = false, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_AOP_Id__c = '1', aop_Minimum_Age__c = 1);
        insert eventConfig;
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(Name = 'Competitor Car');
        insert vehSpec;
        evReq.Current_Vehicle_Brand__c = vehSpec.Id;
        aop_Area_Competitor__c eventCompet = new aop_Area_Competitor__c(aop_Event_Configuration__C = eventConfig.Id,  aop_Vehicle_Brand__c = vehSpec.Id);
        insert eventCompet;
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        evReq = handler.QualifyByRules(evReq, eventConfig);
        System.assertEquals('Qualified', evReq.aop_Status__c);
    }
    
    static TestMethod void TestAutoQualifyOrRejectDisqualifiesIfTooYoung()
    {
        Request__C evReq = new Request__C(aop_Date_Of_Birth__C = Date.today(), aop_Valid_Driving_License__c = true, aop_Status__c = 'Submitted',  Preferred_Retailer_Code__c = 'DealerCode');
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Auto_Rejection_Enabled__c = true, aop_Customer_Queue_Name__c = 'Q', aop_Spotify_Link__c = 'spotify.com', aop_Rebooking_Window__c = 1.4, aop_NSC_Contact_Phone__c = '083633', aop_NSC_Contact_Email__c = 'a@b.com', aop_Community_URL__C = 'www.facebook.com', aop_Checkfront_Token__c = 'abcdefg', aop_Community_Permission_Set__c = 'abcdefg', aop_AWS_Path__C = 'abc', aop_Retailer_Queue_Name__c = 'QName', aop_Qualify_If_Opportunity__c = false, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_AOP_Id__c = '1', aop_Minimum_Age__c = 17);
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        evReq = handler.AutoQualifyOrReject(evReq, eventConfig);
        
        System.assertEquals('Disqualified', evReq.aop_Status__c);
    }
    
    static TestMethod void TestAutoQualifyOrRejectQualifiesIfAutoQualifyAccet()
    {
        Request__C evReq = new Request__C(aop_Date_Of_Birth__C = Date.today(), aop_Valid_Driving_License__c = true, aop_Status__c = 'Submitted',  Preferred_Retailer_Code__c = 'DealerCode');
        aop_Area_Configuration__c eventConfig = new aop_Area_Configuration__c(aop_Auto_Qualification__c = 'Accept', aop_Auto_Rejection_Enabled__c = false, aop_Customer_Queue_Name__c = 'Q', aop_Spotify_Link__c = 'spotify.com', aop_Rebooking_Window__c = 1.4, aop_NSC_Contact_Phone__c = '083633', aop_NSC_Contact_Email__c = 'a@b.com', aop_Community_URL__C = 'www.facebook.com', aop_Checkfront_Token__c = 'abcdefg', aop_Community_Permission_Set__c = 'abcdefg', aop_AWS_Path__C = 'abc', aop_Retailer_Queue_Name__c = 'QName', aop_Qualify_If_Opportunity__c = false, aop_Checkfront_Instance__c =  'abc.com', aop_Checkfront_AOP_Id__c = '1', aop_Minimum_Age__c = 17);
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        evReq = handler.AutoQualifyOrReject(evReq, eventConfig);
        
        System.assertEquals('Qualified', evReq.aop_Status__c);
    }
     
}