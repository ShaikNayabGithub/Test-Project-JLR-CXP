@isTest(seeAllData=false)
public class AdjustmentHandler_test {
    
    @istest
    public static void onInsertTest()
    {
        Id retailerRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Retailer Contact').getRecordTypeId();
        Account a = COOP_TestDataFactory.CreateAccount();
        insert a;        	
        Contact c;
        c = new Contact(AccountId = a.id, lastname = 'lastname',recordtypeId=retailerRecordTypeID, Phone='9876543210');
        Database.insert(c);
        /* Get any profile for the given type.*/
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.runAs(thisUser){
        Profile p = [select id
                      from profile
                     where Name = 'Dealer Principle'
                     limit 1];  
        String testemail = 'testuser@jlrtest.com.dev';
        User u = new User(profileId = p.id, username = testemail, email = testemail,
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = c.id);

        insert u;
        }
        date mydate = date.parse('3/04/2020');
        date mydate1 = date.parse('20/04/2020');
        id camprectype=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('NSC').getRecordTypeId();
        id camprectype1=Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Generic').getRecordTypeId();
        Campaign camp=new Campaign();
        camp.Name='camptest';
        camp.Type='Exp';
        camp.Campaign_Level__c='NSC';
        camp.Description='this is Campaign testing';
        camp.StartDate=mydate;
        camp.EndDate=mydate1;
        camp.Campaign_Brand__c='jaguar';
        camp.Market_ID__c='IN';
        camp.CurrencyIsoCode='INR';
        camp.CampaignMemberRecordTypeId=camprectype1;
        camp.RecordTypeId=camprectype;
        camp.Retailer__c=a.Id;
        insert camp;
        COOP_Adjustment__c coopadj=new COOP_Adjustment__c();//
        coopadj.Name='testcoop';
        coopadj.Campaign__c	=camp.Id;
        coopadj.Amount__c=5678;
        coopadj.Adjustment_Comment__c='abc';
        coopadj.CurrencyIsoCode='INR';
        insert coopadj;
         
        camp= [SELECT COOP_Adjustment_Amount__c FROM Campaign WHERE Id = :camp.Id];
        System.assertEquals(5678, camp.COOP_Adjustment_Amount__c);
    }
        
       @istest
        public static void onupdateTest()
    {
        date mydate = date.parse('3/04/2020');
        date mydate1 = date.parse('20/04/2020');
        id camprectype=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('NSC').getRecordTypeId();
        id camprectype1=Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Generic').getRecordTypeId();
        Campaign camp=new Campaign();
        camp.Name='camptest';
        camp.Type='Exp';
        camp.Campaign_Level__c='NSC';
        camp.Description='this is Campaign testing';
        camp.StartDate=mydate;
        camp.EndDate=mydate1;
        camp.Campaign_Brand__c='jaguar';
        camp.Market_ID__c='IN';
       camp.CampaignMemberRecordTypeId=camprectype1;
        camp.RecordTypeId=camprectype;
        insert camp;
        COOP_Adjustment__c coopadj=new COOP_Adjustment__c();//
        coopadj.Name='testcoop';
        coopadj.Campaign__c	=camp.Id;
        coopadj.Amount__c=200;
        coopadj.Adjustment_Comment__c='abc';
        insert coopadj;
        COOP_Adjustment__c coopadjx=new COOP_Adjustment__c();//
        coopadjx.Name='testcoop';
        coopadjx.Campaign__c	=camp.Id;
        coopadjx.Amount__c=100;
        coopadjx.Adjustment_Comment__c='abc';
        insert coopadjx;
        coopadjx.Amount__c=200;
        update coopadjx;
        
        
        
      //  coopadj.CurrencyIsoCode='IN';
        
        camp= [SELECT COOP_Adjustment_Amount__c FROM Campaign WHERE Id = :camp.Id];
        System.assertEquals(400, camp.COOP_Adjustment_Amount__c);
        
    }
     @istest
        public static void ontwocampaignTest()
    {
        date mydate = date.parse('3/04/2020');
        date mydate1 = date.parse('20/04/2020');
        id camprectype=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('NSC').getRecordTypeId();
        id camprectype1=Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Generic').getRecordTypeId();
        Campaign camp=new Campaign();
        camp.Name='camptest';
        camp.Type='Exp';
        camp.Campaign_Level__c='NSC';
        camp.Description='this is Campaign testing';
        camp.StartDate=mydate;
        camp.EndDate=mydate1;
        camp.Campaign_Brand__c='jaguar';
        camp.Market_ID__c='IN';
       camp.CampaignMemberRecordTypeId=camprectype1;
        camp.RecordTypeId=camprectype;
        insert camp;
        COOP_Adjustment__c coopadj=new COOP_Adjustment__c();//
        coopadj.Name='testcoop';
        coopadj.Campaign__c	=camp.Id;
        coopadj.Amount__c=200;
        coopadj.Adjustment_Comment__c='abc';
        COOP_Adjustment__c coopadjx=new COOP_Adjustment__c();//
        coopadjx.Name='testcoop';
        coopadjx.Campaign__c	=camp.Id;
        coopadjx.Amount__c=100;
        coopadjx.Adjustment_Comment__c='abc';
        List<COOP_Adjustment__c> allCOOPAdjustment = new List<COOP_Adjustment__c>{coopadj, coopadjx};
        insert allCOOPAdjustment;
      //  coopadj.CurrencyIsoCode='IN';
         camp= [SELECT COOP_Adjustment_Amount__c FROM Campaign WHERE Id = :camp.Id];
        System.assertEquals(300, camp.COOP_Adjustment_Amount__c);
        
    }
    @istest
        public static void ondeleteTest()
    {
        date mydate = date.parse('3/04/2020');
        date mydate1 = date.parse('20/04/2020');
        id camprectype=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('NSC').getRecordTypeId();
        id camprectype1=Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Generic').getRecordTypeId();
        Campaign camp=new Campaign();
        camp.Name='camptest';
        camp.Type='Exp';
        camp.Campaign_Level__c='NSC';
        camp.Description='this is Campaign testing';
        camp.StartDate=mydate;
        camp.EndDate=mydate1;
        camp.Campaign_Brand__c='jaguar';
        camp.Market_ID__c='IN';
       camp.CampaignMemberRecordTypeId=camprectype1;
        camp.RecordTypeId=camprectype;
        insert camp;
        COOP_Adjustment__c coopadj=new COOP_Adjustment__c();//
        coopadj.Name='testcoop';
        coopadj.Campaign__c	=camp.Id;
        coopadj.Amount__c=200;
        coopadj.Adjustment_Comment__c='abc';
        insert coopadj;
        COOP_Adjustment__c coopadjx=new COOP_Adjustment__c();//
        coopadjx.Name='testcoop';
        coopadjx.Campaign__c	=camp.Id;
        coopadjx.Amount__c=100;
        coopadjx.Adjustment_Comment__c='abc';
        insert coopadjx;
        coopadjx.Amount__c=200;
        update coopadjx;
        try{ 
            delete coopadjx;            
         }Catch (DMLException e){}
        
        
      //  coopadj.CurrencyIsoCode='IN';
        
        camp= [SELECT COOP_Adjustment_Amount__c FROM Campaign WHERE Id = :camp.Id];
        System.assertEquals(200, camp.COOP_Adjustment_Amount__c);
        
    }
    @istest
        public static void onundeleteTest()
    {
        date mydate = date.parse('3/04/2020');
        date mydate1 = date.parse('20/04/2020');
        id camprectype=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('NSC').getRecordTypeId();
        id camprectype1=Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Generic').getRecordTypeId();
        Campaign camp=new Campaign();
        camp.Name='camptest';
        camp.Type='Exp';
        camp.Campaign_Level__c='NSC';
        camp.Description='this is Campaign testing';
        camp.StartDate=mydate;
        camp.EndDate=mydate1;
        camp.Campaign_Brand__c='jaguar';
        camp.Market_ID__c='IN';
       camp.CampaignMemberRecordTypeId=camprectype1;
        camp.RecordTypeId=camprectype;
        insert camp;
        COOP_Adjustment__c coopadj=new COOP_Adjustment__c();//
        coopadj.Name='testcoop';
        coopadj.Campaign__c	=camp.Id;
        coopadj.Amount__c=200;
        coopadj.Adjustment_Comment__c='abc';
        insert coopadj;
        COOP_Adjustment__c coopadjx=new COOP_Adjustment__c();//
        coopadjx.Name='testcoop';
        coopadjx.Campaign__c	=camp.Id;
        coopadjx.Amount__c=100;
        coopadjx.Adjustment_Comment__c='abc';
        insert coopadjx;
        camp= [SELECT COOP_Adjustment_Amount__c FROM Campaign WHERE Id = :camp.Id];
        System.assertEquals(300, camp.COOP_Adjustment_Amount__c);
        delete coopadjx;
         camp= [SELECT COOP_Adjustment_Amount__c FROM Campaign WHERE Id = :camp.Id];
        System.assertEquals(200, camp.COOP_Adjustment_Amount__c);
        undelete coopadjx;
         camp= [SELECT COOP_Adjustment_Amount__c FROM Campaign WHERE Id = :camp.Id];
        System.assertEquals(300, camp.COOP_Adjustment_Amount__c);
    }


}