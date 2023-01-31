@isTest
public class MembershipBatchCustomerOpportunity_Test {
@testSetup 
    static void setup(){ 
    Account retailer = new Account();
            retailer.Name = 'test retailer - test - 01074';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailer.Dealer_CI_Code__c = 'test retailer';
            retailer.Primary_Dealer_Code__c = 'test retailer';
            retailer.Secondary_Dealer_Code__c = 'test retailer';
            retailer.Alternative_Key__c = 'test retailer';
        retailer.Country_ISO_Code__c='KR';
        retailer.Phone = '12131313';
        insert retailer;
        
        //for(integer i=1; i<2; i++){
        Account personAccount = TestClass_AccountCreator.createPersonAccount();
        personAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        personAccount.Owner_Retailer__c = '1234567';
        personAccount.Is_Primary__c = false;
        personAccount.Country_ISO_Code__c='KR';
        personAccount.Phone = '12131313';
        personAccount.Gender__pc = 'Female';
        personAccount.PersonMobilePhone = '5445565768';
        personAccount.BillingPostalCode = '777899';
        personAccount.BillingState = 'Kr state';
        personAccount.Preferred_Sales_Retailer__c = retailer.Id;
        update personAccount;
            
       // }
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        Opportunity oppobj = new Opportunity(); 
        oppobj.Name = 'test' + personAccount.Name;
        oppobj.RecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Process_with_RDA').getRecordTypeId();
        oppobj.AccountId = personAccount.Id;
       oppobj.Brand__c = make.Id;
        oppobj.Country_ISO_Code__c = 'KR';
        oppobj.Primary_Model_Interest__c = model.Id;
        oppobj.StageName = 'Order Taken';
        oppobj.CloseDate = Date.today();
       // oppobj.HandOver_Date__c = system.today();
        //Test.startTest();
        insert oppobj; 
        
        contract cont = new contract();
         cont.AccountId = personAccount.Id;
         cont.StartDate  = system.today();

        insert cont;
        Asset newAsset = TestClass_AssetBuilder.BuildVehicle();
        newAsset.Vehicle_Initial_Registration_Date__c = system.today()-4;
        newAsset.AccountId=personAccount.Id;
        newAsset.Handover_Date__c = system.today()-1;
        newAsset.VIN__c = '11AABB';
        newAsset.Common_Sale_Type__c='Individual';
        newAsset.Sale_Type_Code__c='RET';
        newAsset.Type_Of_Sale_ID__c='AAA';
        insert newAsset;
        
        Test.startTest();
        OpportunityLineItem opp1  = TestClass_OppLineItemCreator.CreateOppLineItem(oppobj.Id, make.Id, null);
        opp1.Asset__c = newAsset.Id;
        opp1.Brand__c = make.Id;
        insert opp1;
Test.stoptest();
    //Test.stoptest();
    
    }
    public static testmethod void testExecute() {
    //Test.startTest();
        list<opportunity> opplist = [select id,HandOver_Date__c from opportunity where Country_ISO_Code__c = 'KR'];
        list<opportunity> opp = new list<opportunity>();
        set<id> ids =  new set<id>();
        for(opportunity opt: opplist){
         opt.HandOver_Date__c = system.today()-1; 
            opp.add(opt);
            ids.add(opt.id);
        }
            update opp;
      list<opportunity> opport = [select Id,Accountid,HandOver_Date__c,Account.Preferred_Sales_Retailer__r.Name,Account.Gender__pc,Account.PersonMobilePhone,Account.BillingPostalCode,
                                 Account.BillingState,Account.PersonMailingCity from opportunity where Country_ISO_Code__c = 'KR' AND HandOver_Date__c = LAST_N_DAYS:3 
                                  AND HandOver_Date__c < Today And id IN:ids ] ; 
      
     Account acc = [select id,Name,RecordType.Name,(select id,StartDate from contracts) from Account where id =:opport[0].accountid];
     opportunitylineitem oppline =[select id,opportunityid,Asset__r.VIN__c from opportunitylineitem where opportunityid =:opport[0].id];     
     
    Test.startTest();
    Database.executeBatch(new MembershipBatchCustomerOpportunity(), 200);
    Test.stopTest();    
     Membership__c obj = [select id,Retailer_Name__c,VIN__c,Customer_ID__c,Delivery_Date__c,Contract_Date__c,Individual_Corporate__c,
                             Home_Post_No__c,Home_address1__c,Home_address2__c,Mobile_number__c,Gender__c,Showroom_name__c,Customer_Name__c from Membership__c];
    
        assert.areEqual(oppline.Asset__r.VIN__c, obj.VIN__c);
        assert.areEqual(opport[0].Account.Gender__pc, obj.Gender__c);
       // assert.areEqual('test retailer', obj.Retailer_Name__c); 
       // assert.areEqual('test', obj.Showroom_name__c);
       // assert.areEqual('', obj.Customer_Name__c);
        
        assert.areEqual(acc.id, obj.Customer_ID__c);
       assert.areEqual(string.valueOf(opport[0].HandOver_Date__c), obj.Delivery_Date__c);
       assert.areEqual(string.valueOf(acc.contracts[0].StartDate), obj.Contract_Date__c);     
      // assert.areEqual(acc.RecordType.Name, obj.Individual_Corporate__c);  
       assert.areEqual(opport[0].Account.PersonMobilePhone, obj.Mobile_number__c); 
       assert.areEqual(opport[0].Account.BillingPostalCode, obj.Home_Post_No__c);
       assert.areEqual(opport[0].Account.BillingState, obj.Home_address1__c);
       //assert.areEqual(opport[0].Account.PersonMailingCity, obj.Home_address2__c);
    }
    
    public static testmethod void testStart(){
    list<opportunity> opplist = [select id,HandOver_Date__c from opportunity where Country_ISO_Code__c = 'KR'];
        list<opportunity> opp = new list<opportunity>();
        set<id> ids =  new set<id>();
        for(opportunity opt: opplist){
         opt.HandOver_Date__c = system.today() - 1; 
            opp.add(opt);
            ids.add(opt.id);
        }
            update opp;
      list<opportunity> opport = [select Id,Accountid,HandOver_Date__c,Account.Preferred_Sales_Retailer__r.Name,Account.Gender__pc,Account.PersonMobilePhone,Account.BillingPostalCode,
                                 Account.BillingState,Account.RecordType.Name,Account.PersonMailingCity from opportunity where Country_ISO_Code__c = 'KR' AND HandOver_Date__c = LAST_N_DAYS:3 
                                  AND HandOver_Date__c < Today And id IN:ids ] ;
        Test.startTest();
      MembershipBatchCustomerOpportunity obj = new MembershipBatchCustomerOpportunity();
      Database.QueryLocator querylocator = obj.start(null);
      
      Test.stopTest();
      string query = querylocator.getQuery();
      list<Opportunity> outputData = Database.query(query);
        
      assert.areEqual('Female',outputData[0].Account.Gender__pc);
      assert.areEqual('5445565768',outputData[0].Account.PersonMobilePhone);
      assert.areEqual('777899',outputData[0].Account.BillingPostalCode);
      assert.areEqual('Kr state',outputData[0].Account.BillingState);
      assert.areEqual('Individual',outputData[0].Account.RecordType.Name);
     
    }
    public static testmethod void testScheduler() {
        Test.startTest();
        list<opportunity> opplist = [select id,HandOver_Date__c from opportunity where StageName = 'Order Taken' and Country_ISO_Code__c = 'KR' AND RecordType.Name ='Sales Process with RDA'];
        list<opportunity> opp = new list<opportunity>();
        for(opportunity opt: opplist){
         opt.HandOver_Date__c = system.today(); 
            opp.add(opt);
        }
            update opp;
      list<opportunity> opport = [select Id,Account.Preferred_Sales_Retailer__r.Name,Account.Gender__pc,Account.PersonMobilePhone
                                 from opportunity where StageName = 'Order Taken' and Country_ISO_Code__c = 'KR' AND RecordType.Name ='Sales Process with RDA'] ; 
       
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobID = System.schedule('TestSchedule', CRON_EXP, new MembershipBatchCustomerOpportunity() );
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobID];
        System.assertEquals(CRON_EXP,ct.CronExpression); 
        System.assertEquals(jobID,ct.Id);
        Test.stopTest();
        
        
        
    }

    

}