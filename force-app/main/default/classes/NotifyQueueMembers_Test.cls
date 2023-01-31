@isTest 
global class NotifyQueueMembers_Test {  
    
    @testSetup
    private static void testSetup(){
        test.startTest();
        Group group1 = new Group();
        group1.Name = 'Test Group NQM';
        group1.Type = 'Queue';
        group1.DoesSendEmailToMembers = true;
        group1.Email = 'testgroup@email.com';
        insert group1;
        
        QueuesObject q1 = new QueueSObject();
        q1.QueueId = group1.id;
        q1.SobjectType = 'Lead';
        insert q1;
        
        User testUser = new User();
        testUser.Phone = '1234567890';
        testUser.Email = 'test@test.com';
        testUser.ProfileId = [select Id from Profile where Name = 'Standard User' limit 1].Id;
        testUser.UserName = 'test@test.com.testMN';
        testUser.Alias = 'TMN';
        testUser.FirstName = 'TestM';
        testUser.LastName = 'TestN';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.Web_to_lead_Notification_Opt_in__c = true;
        insert testUser;
        
        GroupMember gpm = new GroupMember();
        gpm.GroupId = group1.Id;
        gpm.UserOrGroupId = testUser.Id;
        insert gpm;
        test.stopTest();
        
    }
    
    @isTest 
    private static void testgetListOfRecipientsReturnsCorrectNumber(){
        
        
        Group g1 = [ SELECT Id,Name, DoesSendEmailToMembers, Email  FROM Group WHERE Type = 'Queue'and Email != '' and DoesSendEmailToMembers = true and Name ='Test Group NQM' limit 1];
        //  Map<Id, User> users = new  Map<Id, User>([Select id, Name, email from user where isActive = true and email != '' and ID in (select UserOrGroupId from GroupMember where  GroupId = :g1.Id ) ]);
        List<User> users = new  List<User>([Select id, Name, email from user where Web_to_lead_Notification_Opt_in__c = true and isActive = true and email != '' and ID in (select UserOrGroupId from GroupMember where  GroupId = :g1.Id ) ]);
        System.debug('Number of users '+ users.size());       
        NotifyQueueMembers NVQ = new NotifyQueueMembers();
        Lead lead = new Lead();      
        
        lead.LastName = 'lastname';
        lead.RecordTypeId = [Select Id From RecordType Where SObjectType='Lead' And DeveloperName='Generic' Limit 1].Id;
        lead.Purchase_Type__c = 'New Vehicle';
        lead.MobilePhone = '1234567890';
        lead.Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53';
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        lead.Mapping_Brand__c = make.name;
        lead.Industry = 'Other';
        insert lead;    
        
        Map<Lead, Id> leadsWithQueueIds = new Map<Lead, Id>();
        leadsWithQueueIds.put(lead,g1.Id);
        
        Map<String, List<User>> mapQueuewithQueueMembers =  new Map<String, List<User>>() ;
        
        mapQueuewithQueueMembers.put(g1.Id,users);
        Map<Id, Group> mapqueues = New Map<id, group>([Select id, email from group where id = :g1.Id]);
        
        List<String> recipients = NVQ.getListOfRecipients( lead, leadsWithQueueIds, mapQueuewithQueueMembers,  mapqueues);
        
        System.assert(recipients.size() == (users.size()+1));
        
    }
    
    @isTest 
    private static void testmapQueuewithQueueMembersmethodReturnsCorrectMapp(){
        // Map<String, List<User>> mapQueuewithQueueMembersmethod( Map<Id, Group> mapqueues, Map<Id, User> users){
        Group g1 = [ SELECT Id,Name, DoesSendEmailToMembers, Email  FROM Group WHERE Type = 'Queue'and Email != '' and DoesSendEmailToMembers = true and Name ='Test Group NQM' limit 1];
        Map<Id, Group> g1Map = New Map<Id, Group>();
        g1map.put(g1.Id, g1);
        Map<Id, User> users = new   Map<Id, User>([Select id, Name, email from user where Web_to_lead_Notification_Opt_in__c = true and isActive = true and email != '' and ID in (select UserOrGroupId from GroupMember where  GroupId = :g1.Id ) ]);
        System.debug('Number of users '+ users.size());
        
        
        
        NotifyQueueMembers NVQ = new NotifyQueueMembers();
        Map<String, List<User>> mppp = NVQ.mapQueuewithQueueMembersmethod(g1Map,users);
        integer numOfUsers = 0;
        if(mppp.get(g1.id) != null){
            numOfUsers =  mppp.get(g1.id).size();
        }
        
        System.assert(users.size() == numOfUsers);
        
    }
    
    @isTest 
    private static void TestCheckMembersAndSendEmail(){
        
        List<Group> g1 = [ SELECT Id,Name, DoesSendEmailToMembers, Email  FROM Group WHERE Type = 'Queue'and Email != '' and DoesSendEmailToMembers = true and Name ='Test Group NQM' limit 1];     
        system.debug('100 ' + json.serializePretty(g1) );
        Lead lead = new Lead();     
        
        lead.FirstName = 'firstname';
        lead.LastName = 'lastname';
        lead.Email = 'testw2l@email.com';
        lead.Description = 'Test description';
        lead.RecordTypeId = [Select Id From RecordType Where SObjectType='Lead' And DeveloperName='Generic' Limit 1].Id;
        lead.Purchase_Type__c = 'New Vehicle';
        lead.MobilePhone = '1234567890';
        lead.Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53';
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        lead.Mapping_Brand__c = make.name;
        lead.Industry = 'Other';
        insert lead;
        Map<Lead, Id> leadsWithQueueIds = new Map<Lead, Id>();
        leadsWithQueueIds.put(lead,g1.get(0).id);
        NotifyQueueMembers NVQ = new NotifyQueueMembers();
        NVQ.CheckMembersAndSendEmail(g1, leadsWithQueueIds, null, false);       
        System.assert( Limits.getEmailInvocations() == g1.size());
    }
    
    @isTest 
    private static void TestCheckMembersAndSendEmailTW(){ 
        
        List<Group> g2 = [ SELECT Id,Name, DoesSendEmailToMembers, Email  FROM Group WHERE Type = 'Queue'and Email != '' and DoesSendEmailToMembers = true and Name ='Test Group NQM' limit 1];     
        Lead lead = new Lead();     
        
        lead.FirstName = 'firstname';
        lead.LastName = 'lastname';
        lead.Email = 'testw2l@email.com';
        lead.Description = 'Test description';
        lead.RecordTypeId = [Select Id From RecordType Where SObjectType='Lead' And DeveloperName='Generic' Limit 1].Id;
        lead.Purchase_Type__c = 'New Vehicle';
        lead.MobilePhone = '1234567890';
        lead.Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53';
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        lead.Mapping_Brand__c = make.name;
        lead.Industry = 'Other';
        lead.Country_ISO_Code__c = 'TW';
        insert lead;
        Map<Lead, Id> leadsWithQueueIds = new Map<Lead, Id>();
        leadsWithQueueIds.put(lead,g2.get(0).id);
        NotifyQueueMembers NVQ = new NotifyQueueMembers();
        NVQ.CheckMembersAndSendEmail(g2, leadsWithQueueIds, null, false);       
        System.assert( Limits.getEmailInvocations() == g2.size());
    }
    
    @isTest 
    private static void TestCheckMembersAndSendEmailNZ(){ 
        Campaign camp1 = new Campaign(
            Name = 'Test Campaign 1',
            IsActive = True,
            Market_ID__c = 'NZ'
        );
        insert camp1;
        List<Group> g2 = [ SELECT Id,Name, DoesSendEmailToMembers, Email  FROM Group WHERE Type = 'Queue'and Email != '' and DoesSendEmailToMembers = true and Name ='Test Group NQM' limit 1];     
        Lead lead = new Lead();     
        
        lead.FirstName = 'firstname';
        lead.LastName = 'lastname';
        lead.Email = 'testw2l@email.com';
        lead.Description = 'Test description';
        lead.RecordTypeId = [Select Id From RecordType Where SObjectType='Lead' And DeveloperName='Generic' Limit 1].Id;
        lead.Purchase_Type__c = 'New Vehicle';
        lead.MobilePhone = '1234567890';
        lead.Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53';
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        lead.Mapping_Brand__c = make.name;
        lead.Industry = 'Other';
        lead.Country_ISO_Code__c = 'NZ';
        lead.NZ_Campaign_Id__c = camp1.id;
        insert lead;
        Map<Lead, Id> leadsWithQueueIds = new Map<Lead, Id>();
        leadsWithQueueIds.put(lead,g2.get(0).id);
        NotifyQueueMembers NVQ = new NotifyQueueMembers();
        NVQ.CheckMembersAndSendEmail(g2, leadsWithQueueIds, null, true);       
        System.assert( Limits.getEmailInvocations() == g2.size());
    }
    
    
}