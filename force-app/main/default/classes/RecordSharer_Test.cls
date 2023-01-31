@IsTest
public class RecordSharer_Test  {

    @TestSetup
    public static void Setup(){
        Record_Share__c share = new Record_Share__c();
        share.Retailer__c = TestClass_AccountCreator.CreateRetailer().id;
        share.Account__c  = 'Read';
        share.Account_Case__c = 'Read';
        share.Account_Opportunity__c = 'Read';
        share.Campaign__c = 'Read';
        share.Lead__c = 'Read';
        share.User__c = UserInfo.getUserId();
        insert share;

        //create retailer user
        Id p = [select id from profile where name='Partner Community User' LIMIT 1].id;  
        Contact con = new Contact(LastName ='testCon',AccountId = share.Retailer__c, 
                                FirstName = 'john', Phone = '0794', Gender__c = 'Male', 
                                Birthdate = Date.newInstance(2000,1,30),
                                Salutation = 'Mr', HasOptedOutOfEmail = true, DoNotCall = true,
                                Email = 'test_unit@example.com.unittest');
        insert con;  
                  
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='tester1@noemail.com.unittest');
       System.RunAs(new User(Id=userinfo.getUserId())){
        insert user;
       }
        //Create customer as the partner user
        
        System.runAs(user){
            Account account = new Account();        
            account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
            account.Name = 'test';          
            account.OwnerId = user.id;
            account.LiveAgent_OptOut__c = 'J';
        
            insert account;
        }           
    }

    public static testmethod void RecordShareTrigger(){
        //Not a good test
        Record_Share__c share = [Select id, Account_Case__c, status__c from Record_Share__c limit 1];
        share.Status__c = 'Processing';
        update share;

        share.Account_Case__c = 'Edit';

        try{            
            update share;
        }
        catch (Exception e){

            System.assert(e.getMessage().containsIgnoreCase('You can not edit the record while it is being processed'));
        }

        try{            
            delete share;
        }
        catch (Exception e){
            System.assert(e.getMessage().containsIgnoreCase('Users are not allowed to delete records'));            
        }       
    }


    public static testmethod void Status_ShouldBePending_ForNewRecords(){       
        Record_Share__c shareFromDB = [Select status__c from Record_Share__c limit 1];
        System.assertEquals('Pending',shareFromDB.Status__c);
    }

    public static testmethod void ManualShare_ShouldBeCreated_ForConfigureUser(){
        Account businessAccount = [Select id from Account where name = 'Test' LIMIT 1];


        List<AccountShare> manualShares = [Select id from AccountShare where UserOrGroupId =: UserInfo.getUserId() and AccountId=:businessAccount.id];
        System.assertEquals(1, manualShares.size());        
    }

    public static testmethod void Lead_Share(){
        User user = [Select id from User where Alias = 'test123' ORDER BY CreatedDate DESC LIMIT 1];

        Lead lead;
        System.runAs(user){
            lead = TestClass_LeadCreator.CreateLead();
        }

        List<LeadShare> manualShares = [Select id from LeadShare where UserOrGroupId =: UserInfo.getUserId() and LeadId=:lead.id];
        System.assertEquals(1, manualShares.size());
    }

    public static testmethod void Campaign_Share(){
        User user = [Select id from User where Alias = 'test123' ORDER BY CreatedDate DESC LIMIT 1];

        Campaign campaign;
        System.runAs(user){
            campaign = TestClass_CampaignBuilder.BuildCampaign();
            insert campaign;
        }

        List<CampaignShare> manualShares = [Select id from CampaignShare where UserOrGroupId =: UserInfo.getUserId() and CampaignId=:campaign.id];
        System.assertEquals(1, manualShares.size());
    }

    public static testmethod void Case_Share(){
        User user = [Select id from User where Alias = 'test123' ORDER BY CreatedDate DESC LIMIT 1];
        // create entitlement required for case
        Entitlement testEntitlement =  new Entitlement(Name = 'Medium Priority Entitlement', StartDate = Date.today(), AccountId = [select id from account limit 1].id);
        insert testEntitlement;


        Case newCase;
        System.runAs(user){
            newCase = TestClass_CaseCreator.Create('Phone','0121','test@test.com');         
        }

        List<CaseShare> manualShares = [Select id from CaseShare where UserOrGroupId =: UserInfo.getUserId() and CaseId=:newCase.id];
        System.assertEquals(1, manualShares.size());
    }

    public static testmethod void Opportunity_Share(){
        User user = [Select id from User where Alias = 'test123' ORDER BY CreatedDate DESC LIMIT 1];
    
        Account acc = [Select id from account where Name='test' LIMIT 1];

        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        opportunity.AccountId = acc.Id;
        System.runAs(user){
            insert opportunity;         
        }

        List<OpportunityShare> manualShares = [Select id from OpportunityShare where UserOrGroupId =: UserInfo.getUserId() and OpportunityId=:Opportunity.id];
        System.assertEquals(1, manualShares.size());
    }

    /*
    public static testmethod void OverriteShare_WithGreaterAccess(){
        User user = [Select id from User where Alias = 'test123'];
                
        Lead lead;
        System.runAs(user){
            lead = TestClass_LeadCreator.CreateLead();
            //insert lead;
        }

        List<LeadShare> manualShares = [Select id,LeadAccessLevel from LeadShare where UserOrGroupId =: UserInfo.getUserId() and LeadId=:lead.id];
        System.assertEquals('Read', manualShares[0].LeadAccessLevel);

        Record_Share__c share = [Select Id, Lead__c from Record_Share__c];
        share.Lead__c = 'Edit';
        RecordSharer_Handler.AllowEdit = true;
        update share;
        

        List<Lead> leads = new List<Lead>();
        leads.add(lead);
        RecordSharer sharer = new RecordSharer();
        sharer.Share_Leads(leads);

        manualShares = [Select id, LeadAccessLevel from LeadShare where UserOrGroupId =: UserInfo.getUserId() and LeadId=:lead.id];
        System.assertEquals('Edit', manualShares[0].LeadAccessLevel);

    }
    */

}