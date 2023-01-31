@isTest(SeeAllData= false)
public class CustomerAccountControllerTest{
    
    private static final String STAGE_RESERVE = 'Pay Deposit';
    private static final String STAGE_QUOTE = 'Save a Quote';
    
    /* **************************************************
    Method Name: testExecute
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to test functionality for singapore market
    ****************************************************** */
    
     /* **************************************************
    Method Name: testCheckoutScenario
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to set variables and test navigation for checkoutpage
    ****************************************************** */  
    static testMethod void testCheckoutScenario() {
        
        CreateTestData tdata = new CreateTestData();
         // load custom setting data 
        tdata .loadJUDAANMarketSettingsData();
        
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        List<Asset> assets = tdata.createAssets();
        tdata.createCampaign();
        tdata.createExpireDay( 3 , 7 , 7 );

        List <Vehicle_Specification__c> specs = [select name from Vehicle_Specification__c];
        System.assertEquals(1,specs.size());
        System.assertEquals('Land Rover',specs[0].Name,'tdata.createMaker() has failed');
       
        Account guestAccount = tdata.createPersonalAccount();
        guestAccount.LastName = 'nonDupe';
        insert guestAccount;
        
        Id recordTypeAccountID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();

        User comUser;
        System.runAs( new User( Id = UserInfo.getUserId() ) ) {
            comUser = tdata.createCustomerCommunityUser( guestAccount );
            comUser.Udaan_Active__c =true;
            comUser.isActive= true;
            insert comUser;
        }
           system.debug('---comUser'+comUser);
        User myUser = [Select email from user where contact.account.id =: guestAccount.Id limit 1];

        system.assertEquals('testcommunityuser@jlr.com', myUser.Email);

        Lead ld = tdata.createLead( guestAccount );
        insert ld;

        system.assertEquals('TestFirstName', ld.LastName);
        
        List<Asset> assets2 = [select id from Asset ];
        system.assertEquals(1,assets2.size());
        Test.StartTest();
        Saved_Vehicle_for_Account__c svfa = tdata.createSavedVehicleForAccount( guestAccount , assets2.get(0) );
        Saved_Vehicle_for_Lead__c svfl = tdata.createSavedVehicleForLead( ld , assets2.get(0) );  
        
        system.debug('---svfa'+svfa);
        system.debug('---svfl'+svfl);
        
        //PageReference CustomerAccountPage = Page.CustomerAccountPage;
        //CustomerAccountPage.getParameters().put( 'market' , 'jp' );
        
        
        ApexPages.currentPage().getParameters().put( 'brand' , tdata.brandName );
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'vid' , assets.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
       
         Opportunity reservation = tdata.createOpportunity( Date.today() , STAGE_RESERVE );
        
         CustomerAccountController ctrl = new CustomerAccountController();
         CustomerAccountController.ReservationWrapper wrap = new CustomerAccountController.ReservationWrapper( reservation , 3 );
         PageReference checkoutPage = Page.SGCheckout;
         checkoutPage.getParameters().put( 'brand' , tdata.brandName );
         checkoutPage.getParameters().put( 'lang' , 'ja' );
         checkoutPage.getParameters().put( 'vid' , assets.get(0).Id );
         checkoutPage.getParameters().put( 'market' , 'jp' );
         
         Test.setCurrentPage(checkoutPage);
        
         
         System.runAs( comUser ) {
            wrap.ExtGrpcolor  = 'black';
            wrap.IsAvailable   = true;
            wrap.Availability  = 'yes';
            wrap.PowerOutput = '23';
            wrap.LocalLoanAmount = 20000.0;
            wrap.LocalMonthlyPaymentAmount  = 20000.0;
            wrap.InterestChargesCombined = 40000.0;
            wrap.TotalAmountPaid = 40000.0;
            wrap.LocalBonusPaymentAmount  = 40000.0;
            wrap.LocalVehiclePrice  = 210000.0;
            wrap.FirstPayment  = 10000.0;
            wrap.FinalPayment  = 10000.0;
            checkoutPage.getParameters().put( 'market' , 'jp' );
             checkoutPage.getParameters().put('vid' , assets.get(0).Id);
            ctrl.getRecords();
            ctrl.showCheckoutPage();
            
        }
          Test.stopTest();
   
    }
    
    static testMethod void testExecute() {
       
        CreateTestData tdata = new CreateTestData();
         // load custom setting data 
        tdata .loadJUDAANMarketSettingsData();
        
        tdata.createColourMapping();
        tdata.createMaker();
        tdata.createProducts();
        List<Asset> assets = tdata.createAssets();
        tdata.createCampaign();
        tdata.createExpireDay( 3 , 7 , 7 );

        List <Colour_Group_Mapping__c> colourGroups = [select name,colour_Group__c from Colour_Group_Mapping__c ];
        System.assertEquals(1,colourGroups.size(),'tdata.createColourMapping(); has failed');
        System.assertEquals('Bluefire',colourGroups[0].Name,'tdata.createColourMapping(); has failed');
        System.assertEquals('Blue',colourGroups[0].Colour_Group__c,'tdata.createColourMapping(); has failed'); 

        List <Vehicle_Specification__c> specs = [select name from Vehicle_Specification__c];
        System.assertEquals(1,specs.size());
        System.assertEquals('Land Rover',specs[0].Name,'tdata.createMaker() has failed');

        Id rtIDforModel = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        List<Product2> models = [select id from Product2 where RecordTypeId = : rtIDforModel]; 
        System.assertEquals(1,models.size(),'tdata.createProducts() has failed');
        
        Id rtIDforDerivative = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        List<Product2> derivatives = [select id from Product2 where Model__c = : models[0].id and RecordTypeId = : rtIDforDerivative]; 
        System.assertEquals(1,derivatives.size(),'tdata.createProducts() has failed');

        List<Asset> assets2 = [select id from Asset ];
        assets2[0].Apo__c = true;
        if(!assets2.isEmpty()){
            update assets2;
        }
        System.assertEquals(1,assets2.size(),'tdata.createAssets(); has failed');  
        
        Account guestAccount = tdata.createPersonalAccount();
        guestAccount.LastName = 'nonDupe';
        insert guestAccount;

        Id recordTypeAccountID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();

        //Account mytestaccount = [select FirstName, LastName, PersonEmail from account where PersonEmail = 'testCommunityUser@jlr.com' and RecordTypeId=: recordTypeAccountID ];
        

        //system.assertEquals('TestLastName', mytestaccount.FirstName);
        //system.assertEquals('TestFirstName', mytestaccount.LastName);
        //system.assertEquals('testcommunityuser@jlr.com', mytestaccount.PersonEmail);

        User comUser;
        System.runAs( new User( Id = UserInfo.getUserId() ) ) {
            comUser = tdata.createCustomerCommunityUser( guestAccount );
               comUser.Udaan_Active__c =true;
            insert comUser;
        }

        User myUser = [Select email from user where contact.account.id =: guestAccount.Id limit 1];

        system.assertEquals('testcommunityuser@jlr.com', myUser.Email);

        Test.StartTest();  
        
        Lead ld = tdata.createLead( guestAccount );
        insert ld;

        system.assertEquals('TestFirstName', ld.LastName);
        system.assertEquals('TestLastName', ld.FirstName);
        system.assertEquals('testCommunityUser@jlr.com', ld.Email);
        system.assertEquals('Private', ld.Account_Type__c);

        system.assertEquals('UDAAN', ld.LeadSource);
        system.assertEquals('Warm', ld.Rating);
        system.assertEquals('Product', ld.Type__c);
        system.assertEquals('Retail', ld.Sub_Type__c);
        system.assertEquals('New Vehicle', ld.Purchase_Type__c);
        system.assertEquals(guestAccount.Id, ld.Account__c);

        Saved_Vehicle_for_Account__c svfa = tdata.createSavedVehicleForAccount( guestAccount , assets2.get(0) );
        system.debug('---svfa'+svfa);
        Saved_Vehicle_for_Lead__c svfl = tdata.createSavedVehicleForLead( ld , assets2.get(0) );  
        system.debug('---svfl'+svfl);
        ApexPages.currentPage().getParameters().put( 'brand' , tdata.brandName );
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'vid' , assets.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        
        Opportunity quote = tdata.createOpportunity( Date.today() , STAGE_QUOTE );
        
        
        //Create test records 
        PageReference pageRef = Page.CustomerAccountPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('vid' , assets.get(0).Id);
        pageRef.getParameters().put('assetId' , assets.get(0).Id);
        
        System.runAs( comUser ) {
            CustomerAccountController ctrl = new CustomerAccountController();
              ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
               pageRef.getParameters().put('vid' , assets.get(0).Id);
               pageRef.getParameters().put('assetId' , assets.get(0).Id);
               ApexPages.currentPage().getParameters().put('IdForSavedVehicle',assets.get(0).Id );
            ctrl.getRecords();
            ctrl.showMoreVehicle();
            ctrl.removeAsset();
            ctrl.showCustomerAccount_NewPage();
            ctrl.showCustomerAccountPage();
        }
        
        CustomerAccountController.QuoteWrapper qwrap = new CustomerAccountController.QuoteWrapper( quote , 3 );
        CustomerAccountController.SaveVehicleWrapper svw = new CustomerAccountController.SaveVehicleWrapper( svfa );
        svw = new CustomerAccountController.SaveVehicleWrapper( svfl );
        qwrap.LocalLoanAmount = 20000.0;
            qwrap.LocalMonthlyPaymentAmount  = 20000.0;
            qwrap.InterestChargesCombined = 40000.0;
            qwrap.TotalAmountPaid = 40000.0;
            qwrap.LocalBonusPaymentAmount  = 40000.0;
            qwrap.LocalVehiclePrice  = 210000.0;
            qwrap.FirstPayment  = 10000.0;
            qwrap.FinalPayment  = 10000.0;
            qwrap.ExpirationDate  = System.Today();
        
       Test.StopTest();
    }
    
}