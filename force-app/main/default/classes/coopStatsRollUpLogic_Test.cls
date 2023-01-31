@IsTest
public class coopStatsRollUpLogic_Test {

    @istest
    public static void Controller_CalculatesTotalCXPCampaignLeads_WhenCXPCampaignHasLeads() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10) );
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10),CurrencyIsoCode='INR');
        insert coopAct;
        //create a Lead and link to the CXP Campaign
        Id genericLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Generic').getRecordTypeId();
        Lead cxpLead = new Lead();
        cxpLead.LastName = 'Test Lead';
        cxpLead.RecordTypeId = genericLeadRecordTypeId;
        cxpLead.Purchase_Type__c = 'New Vehicle';
        cxpLead.MobilePhone = '1234567890';
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        cxpLead.Brand__c = make.Id;
        cxpLead.Industry = 'Other';
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        cxpLead.Primary_Model_Interest__c = model.Id;
        insert cxpLead;
        CampaignMember cMember = new CampaignMember (CampaignId=cxpCampaign.Id, LeadId=cxpLead.Id);
        insert cMember;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFields(new List<Campaign>{cxpCampaign});
        coopCampaign = [SELECT CoOp_Total_Number_of_Leads__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(1, coopCampaign.CoOp_Total_Number_of_Leads__c);
    }
    
    @istest
    public static void Controller_CalculatesTotalCoopLeads_WhenCampaignLinkedToCXPCampaignAndCXPCampaignHasLeads() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created',Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10),CurrencyIsoCode='INR');
        insert coopAct;
        //create a Lead and link to the CXP Campaign
        Id genericLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Generic').getRecordTypeId();
        Lead cxpLead = new Lead();
        cxpLead.LastName = 'Test Lead';
        cxpLead.RecordTypeId = genericLeadRecordTypeId;
        cxpLead.Purchase_Type__c = 'New Vehicle';
        cxpLead.MobilePhone = '1234567890';
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        cxpLead.Brand__c = make.Id;
        cxpLead.Industry = 'Other';
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        cxpLead.Primary_Model_Interest__c = model.Id;
        insert cxpLead;
        CampaignMember cMember = new CampaignMember (CampaignId=cxpCampaign.Id, LeadId=cxpLead.Id);
        insert cMember;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFieldsFromCampaignActivity(new Set<Id>{coopCampaign.Id});
        coopCampaign = [SELECT CoOp_Total_Number_of_Leads__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(1, coopCampaign.CoOp_Total_Number_of_Leads__c);
    }
    
    @istest
    public static void Controller_CalculatesTotalCoopLeads_WhenLeadsEnteredOnCoopCampaignManually() {
        //create a CoopCampaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        insert coopCampaign;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', Number_of_Leads__c=5,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFieldsFromCampaignActivity(new Set<Id>{coopCampaign.Id});
        coopCampaign = [SELECT CoOp_Total_Number_of_Leads__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(5, coopCampaign.CoOp_Total_Number_of_Leads__c);
    }
    
    @istest
    public static void Controller_ShowsZeroCampaignLeads_WhenCXPCampaignHasNoLeads() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created',Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFields(new List<Campaign>{cxpCampaign});
        coopCampaign = [SELECT CoOp_Total_Number_of_Leads__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(0, coopCampaign.CoOp_Total_Number_of_Leads__c);  
    }
    
    @istest
    public static void Controller_CalculatesTotalCXPCampaignOpps_WhenCXPCampaignHasOpps() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //create an Opportunity and link to the CXP Campaign
        Opportunity cxpOpp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        cxpOpp.CampaignId = cxpCampaign.Id;
        insert cxpOpp;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFields(new List<Campaign>{cxpCampaign});
        coopCampaign = [SELECT CoOp_Total_Number_of_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(1, coopCampaign.CoOp_Total_Number_of_Opportunities__c);
    }
    
    @istest
    public static void Controller_CalculatesTotalCoopOpps_WhenCampaignLinkedToCXPCampaignAndCXPCampaignHasOpps() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created',Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //create an Opportunity and link to the CXP Campaign
        Opportunity cxpOpp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        cxpOpp.CampaignId = cxpCampaign.Id;
        insert cxpOpp;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFieldsFromCampaignActivity(new Set<Id>{coopCampaign.Id});
        coopCampaign = [SELECT CoOp_Total_Number_of_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(1, coopCampaign.CoOp_Total_Number_of_Opportunities__c);
    }
    
    @istest
    public static void Controller_CalculatesTotalCoopOpps_WhenOppsEnteredOnCoopCampaignManually() {
        //create a CoopCampaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        insert coopCampaign;
        //create a Campaign Activity as a child of the Coop Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', Number_of_Opportunities__c=5,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFieldsFromCampaignActivity(new Set<Id>{coopCampaign.Id});
        coopCampaign = [SELECT CoOp_Total_Number_of_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(5, coopCampaign.CoOp_Total_Number_of_Opportunities__c);
    }
    
    @istest
    public static void Controller_ShowsZeroCampaignOpps_WhenCXPCampaignHasNoOpps() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created',Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFields(new List<Campaign>{cxpCampaign});
        coopCampaign = [SELECT CoOp_Total_Number_of_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(0, coopCampaign.CoOp_Total_Number_of_Opportunities__c);    
    }
    
    @istest
    public static void Controller_CalculatesTotalCXPCampaignWonOpps_WhenCXPCampaignHasWonOpps() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //create an Opportunity and link to the CXP Campaign
        Opportunity cxpOpp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        cxpOpp.CampaignId = cxpCampaign.Id;
        cxpOpp.StageName = 'Closed Won';
        insert cxpOpp;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFields(new List<Campaign>{cxpCampaign});
        coopCampaign = [SELECT CoOp_Total_Number_of_Won_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(1, coopCampaign.CoOp_Total_Number_of_Won_Opportunities__c);
    }
    
    @istest
    public static void Controller_CalculatesTotalCoopWonOpps_WhenCampaignLinkedToCXPCampaignAndCXPCampaignHasWonOpps() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //create an Opportunity and link to the CXP Campaign
        Opportunity cxpOpp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        cxpOpp.CampaignId = cxpCampaign.Id;
        cxpOpp.StageName = 'Closed Won';
        insert cxpOpp;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFieldsFromCampaignActivity(new Set<Id>{coopCampaign.Id});
        coopCampaign = [SELECT CoOp_Total_Number_of_Won_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(1, coopCampaign.CoOp_Total_Number_of_Won_Opportunities__c);
    }
    
    @istest
    public static void Controller_CalculatesTotalCoopWonOpps_WhenWonOppsEnteredOnCoopCampaignManually() {
        //create a CoopCampaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        insert coopCampaign;
        //create a Campaign Activity as a child of the Coop Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', Number_of_Won_Opportunities__c=5,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFieldsFromCampaignActivity(new Set<Id>{coopCampaign.Id});
        coopCampaign = [SELECT CoOp_Total_Number_of_Won_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(5, coopCampaign.CoOp_Total_Number_of_Won_Opportunities__c);
    }
    
    @istest
    public static void Controller_ShowsZeroCampaignWonOpps_WhenCXPCampaignHasNoWonOpps() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coopAct;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFields(new List<Campaign>{cxpCampaign});
        coopCampaign = [SELECT CoOp_Total_Number_of_Won_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(0, coopCampaign.CoOp_Total_Number_of_Won_Opportunities__c);  
    }
    
    @istest
    public static void Controller_CalculatesTotalCXPCampaignLeads_WhenCXPCampaignHasLeadsAndHasSecondCampaignActivityWithLeads() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created',Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        CooP_Campaign_Activity__c coopAct2 = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', Number_of_Leads__c=5,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        List<CooP_Campaign_Activity__c> allCoopActs = new List<CooP_Campaign_Activity__c>{coopAct, coopAct2};
        insert allCoopActs;
        //create a Lead and link to the CXP Campaign
        Id genericLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Generic').getRecordTypeId();
        Lead cxpLead = new Lead();
        cxpLead.LastName = 'Test Lead';
        cxpLead.RecordTypeId = genericLeadRecordTypeId;
        cxpLead.Purchase_Type__c = 'New Vehicle';
        cxpLead.MobilePhone = '1234567890';
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        cxpLead.Brand__c = make.Id;
        cxpLead.Industry = 'Other';
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        cxpLead.Primary_Model_Interest__c = model.Id;
        insert cxpLead;
        CampaignMember cMember = new CampaignMember (CampaignId=cxpCampaign.Id, LeadId=cxpLead.Id);
        insert cMember;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFields(new List<Campaign>{cxpCampaign});
        coopCampaign = [SELECT CoOp_Total_Number_of_Leads__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(6, coopCampaign.CoOp_Total_Number_of_Leads__c);
    }
    
    @istest
    public static void Controller_CalculatesTotalCXPCampaignOpps_WhenCXPCampaignHasOppsAndHasSecondCampaignActivityWithOpps() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created',Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        CooP_Campaign_Activity__c coopAct2 = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', Number_of_Opportunities__c=5,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        List<CooP_Campaign_Activity__c> allCoopActs = new List<CooP_Campaign_Activity__c>{coopAct, coopAct2};
        insert allCoopActs;
        //create an Opportunity and link to the CXP Campaign
        Opportunity cxpOpp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        cxpOpp.CampaignId = cxpCampaign.Id;
        insert cxpOpp;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFields(new List<Campaign>{cxpCampaign});
        coopCampaign = [SELECT CoOp_Total_Number_of_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(6, coopCampaign.CoOp_Total_Number_of_Opportunities__c);
    }
    
    @istest
    public static void Controller_CalculatesTotalCXPCampaignOpps_WhenCXPCampaignHasOppsAndHasSecondCampaignActivityWithWonOpps() {
        //create a CoopCampaign and a CXP Campaign
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id cxpRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        Campaign cxpCampaign = new Campaign(Name = 'Test CXP Campaign', RecordTypeId = cxpRecordTypeId, Status = 'Created', Market_ID__c = 'IN',Type='Exp',Campaign_Brand__c='jaguar',Campaign_Level__c='NSC',Description='this is Campaign testing',CurrencyIsoCode='INR',StartDate=Date.newInstance(2020,12,9),EndDate=Date.newInstance(2020, 12, 10));
        List<Campaign> allCampaigns = new List<Campaign>{coopCampaign, cxpCampaign};
        insert allCampaigns;
        //create a Campaign Activity as a child of the Coop Campaign, and link to the CXP Campaign
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', CXP_Campaign__c=cxpCampaign.Id,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        CooP_Campaign_Activity__c coopAct2 = new CooP_Campaign_Activity__c(CurrencyIsoCode='INR',Name='Test Coop', Claimable_Proportion__c='100%', Campaign__c=coopCampaign.Id, Status__c='Activity Created', Number_of_Won_Opportunities__c=5,PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        List<CooP_Campaign_Activity__c> allCoopActs = new List<CooP_Campaign_Activity__c>{coopAct, coopAct2};
        insert allCoopActs;
        //create an Opportunity and link to the CXP Campaign
        Opportunity cxpOpp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        cxpOpp.CampaignId = cxpCampaign.Id;
        cxpOpp.StageName = 'Closed Won';
        insert cxpOpp;
        //do we need to run the logic code or is this fired from a trigger?
        coopStatsRollUpLogic rollUpLogic = new coopStatsRollUpLogic();
        rollUpLogic.updateCooPParentsStatFields(new List<Campaign>{cxpCampaign});
        coopCampaign = [SELECT CoOp_Total_Number_of_Won_Opportunities__c FROM Campaign WHERE Id = :coopCampaign.Id];
        System.assertEquals(6, coopCampaign.CoOp_Total_Number_of_Won_Opportunities__c);
    }
}