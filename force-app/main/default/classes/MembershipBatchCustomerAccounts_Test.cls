@isTest
public class MembershipBatchCustomerAccounts_Test {
   @testSetup 
    static void setup(){ 
        
  
   //List<Account> accntList = new List<Account>();
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

        Account personAccount = TestClass_AccountCreator.createPersonAccount();
        personAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        personAccount.Owner_Retailer__c = '1234567';
        personAccount.Is_Primary__c = false;
        personAccount.Country_ISO_Code__c='KR';
        personAccount.Phone = '12131313';
        personAccount.PersonMobilePhone = '5445565768';
        personAccount.Preferred_Sales_Retailer__c = retailer.Id;
        //personAccount.Owner = u.id;
        update personAccount;
            
       // }
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        Opportunity oppobj = new Opportunity(); 
        oppobj.Name = 'test' + personAccount.Name;
        oppobj.AccountId = personAccount.Id;
       oppobj.Brand__c = make.Id;
        oppobj.Primary_Model_Interest__c = model.Id;
        oppobj.StageName = 'Order Taken';
        oppobj.CloseDate = Date.today();
        oppobj.HandOver_Date__c = system.today();
        
        insert oppobj; 
        list<contract> contList = new list<contract>();

        //for(Account acc: accntList){
         contract cont = new contract();
         cont.AccountId = personAccount.Id;
         cont.StartDate  = system.today();
         //contList.add(cont) ;  
        //}
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
        
       // Vehicle_Specification__c make1 = TestClass_VehicleSpecificationBuilder.BuildMake();
       //// Vehicle_Specification__c model1 = TestClass_VehicleSpecificationBuilder.BuildModel(make1);
        Test.startTest();
        OpportunityLineItem opp1  = TestClass_OppLineItemCreator.CreateOppLineItem(oppobj.Id, make.Id, null);
        opp1.Asset__c = newAsset.Id;
        opp1.Brand__c = make.Id;
        insert opp1;
Test.stoptest();
   
    
    }
    
  public static testmethod void testStart() {
    list<opportunity> opplist = [select id,accountid,Account.Gender__pc,stagename from opportunity where stagename = 'Order Taken'];
        set<id> ids =  new set<id>();
        for(opportunity oppt: opplist){
          ids.add(oppt.accountid);  
        }
        list<Account> acntlist = [select id,Gender__pc,PersonMailingPostalCode,Country_ISO_Code__c,RecordType.Name from Account 
                                  where Country_ISO_Code__c = 'KR' AND RecordType.Name ='Individual'];
        list<account> acnt = new list<account>();
        if(acntlist!=null && acntlist.size()>0){
         for(Account acc: acntlist){
         acc.Gender__pc = 'Female';
         acnt.add(acc);    
        }
        update acnt;   
        }
		list<Account> acntlist1 = [select id, RecordType.Name,(select id,Account.Gender__pc,Account.PersonMobilePhone,Account.PersonMailingStreet,Account.PersonMailingCity From Opportunities where StageName = 'Order Taken'),
								  (select id,StartDate from contracts)from Account 
                                  where Country_ISO_Code__c = 'KR' AND RecordType.Name ='Individual' AND id IN:ids AND  LastModifiedDate >= LAST_N_DAYS:1 ];
        
       Test.startTest();
      // Database.executeBatch(new MembershipBatchCustomerAccounts(), 200);
      MembershipBatchCustomerAccounts obj = new MembershipBatchCustomerAccounts();
     // obj.start(null);
      Database.QueryLocator querylocator = obj.start(null);
      
      Test.stopTest();
      string query = querylocator.getQuery();
      list<Account> outputData = Database.query(query);
      
      assert.areEqual('Female',outputData[0].Opportunities[0].Account.Gender__pc);
      assert.areEqual('5445565768',outputData[0].Opportunities[0].Account.PersonMobilePhone);
      assert.areEqual('Valid Street',outputData[0].Opportunities[0].Account.PersonMailingStreet);
      assert.areEqual('Valid City',outputData[0].Opportunities[0].Account.PersonMailingCity);
      assert.areEqual('Individual',outputData[0].RecordType.Name);

      
    }  
    
    public static testmethod void testExecute() {
       list<opportunity> opplist = [select id,accountid,stagename from opportunity where stagename = 'Order Taken'];
        set<id> ids =  new set<id>();
        for(opportunity oppt: opplist){
          ids.add(oppt.accountid);  
        }
        list<Account> acntlist = [select id,Gender__pc,(select id,StageName,AccountId from opportunities),PersonMailingPostalCode,Country_ISO_Code__c,RecordType.Name from Account 
                                  where Country_ISO_Code__c = 'KR' AND RecordType.Name ='Individual']; 
        list<account> acnt = new list<account>();
        if(acntlist!=null && acntlist.size()>0){
         for(Account acc: acntlist){
         acc.Gender__pc = 'Female';
         acnt.add(acc);    
        }
        update acnt;   
        }
        list<Account> acntlist1 = [select id,Name,Preferred_Sales_Retailer__r.name,Gender__pc,PersonMobilePhone,PersonMailingStreet,PersonMailingCity,
                                   (select id,StageName,AccountId,HandOver_Date__c from opportunities where StageName = 'Order Taken'),
                                   PersonMailingPostalCode,(select id,StartDate from contracts),Country_ISO_Code__c,RecordType.Name from Account 
                                  where Country_ISO_Code__c = 'KR' AND RecordType.Name ='Individual' AND id IN:ids AND  LastModifiedDate >= LAST_N_DAYS:1 ];
        list<opportunitylineitem> oppline = [select id,opportunityId,Asset__r.VIN__c,Asset__r.Brand__r.Name,Asset__r.Model__r.Name,Asset__r.Warranty_Start_Date__c,Asset__r.KR_Platinum_Care_End_Date__c,Asset__r.Product2.Name from opportunitylineitem
                                             where opportunityid =: acntlist1[0].opportunities[0].id AND Asset__c !=null];
       
        Test.startTest();
        Database.executeBatch(new MembershipBatchCustomerAccounts(), 200);
        Test.stopTest();
        Membership__c obj = [select id,Retailer_Name__c,VIN__c,Customer_ID__c,Delivery_Date__c,Contract_Date__c,Individual_Corporate__c,
                             Home_Post_No__c,Home_address1__c,Home_address2__c,Mobile_number__c,Gender__c,Showroom_name__c,Customer_Name__c from Membership__c];

       assert.areEqual(oppline[0].Asset__r.VIN__c, obj.VIN__c);
       assert.areEqual(acntlist1[0].Gender__pc, obj.Gender__c);
       assert.areEqual('test retailer', obj.Retailer_Name__c); 
       assert.areEqual('test', obj.Showroom_name__c); 
       assert.areEqual(acntlist1[0].Name, obj.Customer_Name__c);
       assert.areEqual(acntlist1[0].id, obj.Customer_ID__c);
       assert.areEqual(string.valueOf(acntlist1[0].opportunities[0].HandOver_Date__c), obj.Delivery_Date__c);
       assert.areEqual(string.valueOf(acntlist1[0].contracts[0].StartDate), obj.Contract_Date__c);     
       assert.areEqual(acntlist1[0].RecordType.Name, obj.Individual_Corporate__c);  
       assert.areEqual(acntlist1[0].PersonMobilePhone, obj.Mobile_number__c); 
       assert.areEqual(acntlist1[0].PersonMailingPostalCode, obj.Home_Post_No__c);
       assert.areEqual(acntlist1[0].PersonMailingStreet, obj.Home_address1__c);
       assert.areEqual(acntlist1[0].PersonMailingCity, obj.Home_address2__c);
       
       
    }
    public static testmethod void testScheduler() {
       
        list<opportunity> opplist = [select id,accountid,stagename from opportunity where stagename = 'Order Taken'];
        set<id> ids =  new set<id>();
        for(opportunity oppt: opplist){
          ids.add(oppt.accountid);  
        }
        list<Account> acntlist = [select id,Gender__pc,(select id,StageName,AccountId from opportunities),PersonMailingPostalCode,Country_ISO_Code__c,RecordType.Name from Account 
                                  where Country_ISO_Code__c = 'KR' AND RecordType.Name ='Individual' limit 10];
        list<account> acnt = new list<account>();
        if(acntlist!=null && acntlist.size()>0){
         for(Account acc: acntlist){
         acc.Gender__pc = 'Female';
         acnt.add(acc);    
        }
        update acnt;   
        }
        list<Account> acntlist1 = [select id,Preferred_Sales_Retailer__r.name,Gender__pc,(select id,StageName,AccountId from opportunities where StageName = 'Order Taken'),
                                   PersonMailingPostalCode,(select id from contracts),Country_ISO_Code__c,RecordType.Name from Account 
                                  where Country_ISO_Code__c = 'KR' AND RecordType.Name ='Individual' AND id IN:ids limit 10];
        
         Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobID = System.schedule('TestSchedule', CRON_EXP, new MembershipBatchCustomerAccounts() );
        
        CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobID];
        System.assertEquals(CRON_EXP,ct.CronExpression); 
        System.assertEquals(jobID,ct.Id); 
        Test.stopTest();
       // AsyncApexJob jobInfo = [SELECT id FROM AsyncApexJobWHERE Id=: jobID];

    }
    
    
    
}