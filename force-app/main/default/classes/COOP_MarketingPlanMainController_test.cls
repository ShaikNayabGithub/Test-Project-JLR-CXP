@IsTest (seeAllData=false)
public class COOP_MarketingPlanMainController_test 
{    
     @testSetup static void setup() 
     { 
        List<Campaign> updateCamps = new List<Campaign>();
        Account acct = COOP_TestDataFactory.CreateAccount();
        insert acct;
        Campaign CoOpJLR = COOP_TestDataFactory.CreateCampaign('Co Op Retailer', 'Jaguar', acct);       
        insert CoOpJLR;
        List<CooP_Campaign_Activity__c> lst_coopActJLR = COOP_TestDataFactory.createCoOpActivities(3, CoOpJLR.id);
        insert lst_coopActJLR;
        Campaign CoOpLR = COOP_TestDataFactory.CreateCampaign('Co Op Retailer', 'Land Rover',acct);       
        insert CoOpLR;
        List<CooP_Campaign_Activity__c> lst_coopActLR = COOP_TestDataFactory.createCoOpActivities(3, CoOpLR.id);
        insert lst_coopActLR;          
     } 
    
    @istest
    public static void SubmitApprovalRequest() 
    {
        List<Campaign> updateCamps = new List<Campaign>();
        Account acc = [select id, name from account];       
        Campaign CoOpJLR = [select id, name,ActualCost from Campaign where name like '%JAG%' limit 1];
        List<CooP_Campaign_Activity__c> lst_coopActJLR = [Select id, name from CooP_Campaign_Activity__c where Campaign__c =: CoOpJLR.Id ];
            
        
       // Account acc = [select id,name from Account limit 1];
        COOP_MarketingPlanMainController.getFYearDetails();
        COOP_MarketingPlanMainController.getUserDetails();
        COOP_MarketingPlanMainController.getModelList();
        
        COOP_MarketingPlanMainController.saveCampaignComments(CoOpJLR.Id, 'CommentTest');
        COOP_MarketingPlanMainController.searchCampaigns('19-20','Q4','Jaguar', '',acc.name );
        COOP_MarketingPlanMainController.searchCampaigns('19-20','Q4','Land Rover', '',acc.name );
       
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(CoOpJLR.Id);
        Approval.ProcessResult result = Approval.process(app);
        COOP_MarketingPlanMainController.getNextApproverDetails(CoOpJLR.Id); 
        
        COOP_MarketingPlanMainController.approveOrReject(CoOpJLR.Id, lst_coopActJLR[1].id, 'Testing', 'Approve');      
        COOP_MarketingPlanMainController.getCampaignsDetails('19-20', 'Q4');
        
    }
    
    @istest
    public static void saveUpdates() 
    {
        List<Campaign> updateCamps = new List<Campaign>();
        Account acc = [select id, name from account];       
        Campaign CoOpJLR = [select id, name,ActualCost from Campaign where name like '%JAG%' limit 1];
        List<CooP_Campaign_Activity__c> lst_coopActJLR = [Select id, name,Campaign__c,Status__c from CooP_Campaign_Activity__c where Campaign__c =: CoOpJLR.Id ];
        
        CoOpJLR.ActualCost = 10000;
        updateCamps.add(CoOpJLR);
        COOP_MarketingPlanMainController.saveCampaigns(updateCamps);    
        lst_coopActJLR[1].name = 'ActivityTest';
        COOP_MarketingPlanMainController.saveCampaignActivitys(lst_coopActJLR);
    }
    
    @istest
    public static void SubmitRejectRequest() 
    {
        List<Campaign> updateCamps = new List<Campaign>();
        Account acc = [select id, name from account];       
        Campaign CoOpJLR = [select id, name,ActualCost from Campaign where name like '%JAG%' limit 1];
        List<CooP_Campaign_Activity__c> lst_coopActJLR = [Select id, name from CooP_Campaign_Activity__c where Campaign__c =: CoOpJLR.Id ];
        COOP_MarketingPlanMainController.getRejCanActivities(CoOpJLR.Id);
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(CoOpJLR.Id);
        Approval.ProcessResult result = Approval.process(app);
        COOP_MarketingPlanMainController.getNextApproverDetails(CoOpJLR.Id);         
        COOP_MarketingPlanMainController.approveOrReject(CoOpJLR.Id, lst_coopActJLR[1].id, 'Testing', 'Reject'); 
       
        COOP_MarketingPlanMainController.approveOrReject(CoOpJLR.Id, null, 'Testing', 'Comment'); 
    }
    
    @istest
    public static void needsModification() 
    {
        List<Campaign> updateCamps = new List<Campaign>();
        Account acc = [select id, name from account];       
        Campaign CoOpJLR = [select id, name,ActualCost from Campaign where name like '%JAG%' limit 1];
        List<CooP_Campaign_Activity__c> lst_coopActJLR = [Select id, name,Status__c, Campaign__c from CooP_Campaign_Activity__c where Campaign__c =: CoOpJLR.Id ];
        List<CooP_Campaign_Activity__c> lst_newActivity = COOP_TestDataFactory.createCoOpActivities(1, CoOpJLR.id);
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(CoOpJLR.Id);
        Approval.ProcessResult result = Approval.process(app);
        
        Approval.ProcessSubmitRequest app1 = new Approval.ProcessSubmitrequest();
        app1.setObjectId(lst_coopActJLR[0].Id);
        Approval.ProcessResult result1 = Approval.process(app1);
        lst_coopActJLR[0].Status__c ='Activity Needs Modification';
        lst_coopActJLR[1].Status__c ='Activity Needs Modification';
        user u=[select id from user where name='Vivek Varale' Limit 1];
        system.runAs(u){
        COOP_MarketingPlanMainController.saveCampaignActivitys(lst_coopActJLR);
        }
    }
}