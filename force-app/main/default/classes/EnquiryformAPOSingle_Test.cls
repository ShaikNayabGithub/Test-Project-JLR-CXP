/* *************************************************************************************************************    
Class Name    : EnquiryformAPOSingleTest
Description   : Class is used for testing functionality of APOVehicleSingleController.cls. 
CreatedDate   : 08-08-2018         
Version       : 1.0     
Author        : TCS
***************************************************************************************************************** */
@isTest(SeeAllData = false)
private class EnquiryformAPOSingle_Test {
    
    
    @testSetup static void createData()
    {
        CreateTestData tdata = new CreateTestData();
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        tdata.createCampaign();
        tdata.loadJUDAANMarketSettingsData();
        
        List<Asset> assets = tdata.createAssets();
        List<Account> lstAccount = [Select Id,OwnerId,Email_used_for_Udaan__c,Queue_Id__c from Account Where Id =: assets[0].AccountId];
        lstAccount[0].Record_Sub_Type__c= 'Dual Brand';
        update lstAccount[0];
        
        Account acc = tdata.createPersonalAccount();
        
        insert acc;
        
        system.debug('---new acc id:' + acc.Id);
        Lead ld = tdata.createLead(acc); 
        insert ld;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

       // Insert account as current user

        System.runAs (thisUser) {
  
        User u = tdata.createCustomerCommunityUser(acc);
        try{
        insert u;
            }
        catch(Exception e)
            {
                system.debug('---exx:' + e.getMessage());
            }

        }  
    }
    static testMethod void testExecute() {
        
        Asset ast = [select Id from Asset limit 1];
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        system.debug('---ast:' + ast);
        
        Account acc = [select Id from Account where RecordTypeId = :rtypeId limit 1];
        system.debug('---acc:' + acc);
        
     
        User u = [select Id, Email from User where Contact.AccountId = :acc.Id limit 1];

       
        
        ApexPages.currentPage().getParameters().put( 'lang' , 'ja' );
        ApexPages.currentPage().getParameters().put( 'id' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'assetid' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'svid' , ast.Id );
        ApexPages.currentPage().getParameters().put( 'market' , 'jp' );
        
        
         Test.startTest();
        System.runAs(u){
            APOVehicleSingleController ctrl = new APOVehicleSingleController();
            ctrl.IsEmail = true;
            ctrl.IsPhone = true;
            ctrl.IsSMS = true;
            insert new JUDAANMarketSettings__c(Name='jp',Reservation_Limit__c=1.0,Date_format__c = 'dd/MM/yyyy');
            ctrl.getRecords();
            ctrl.saveEnquiryform();
          
             ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
              ctrl.IsEmail = true;
              ctrl.saveEnquiryform();
           
            
        }
       
        EnquiryformAPOSingle obj = new EnquiryformAPOSingle ();
        obj.getBaseURlForEMail();
        obj.createCaseforFeedback('test','abc@gmail.com','jaguar',string.valueof(acc.id),Label.SG_UDAAN_Lead,'sg');
        Test.stopTest();
        obj.getBaseURlForEMailNSE();
        
    }
    
 }