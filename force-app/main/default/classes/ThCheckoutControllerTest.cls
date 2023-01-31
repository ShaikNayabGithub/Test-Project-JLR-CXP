/* *************************************************************************************************************    
Class Name    : ThCheckoutControllerTest

Description   : This class is used for testing functionality of 
thCheckoutController 
CreatedDate   : 09 Mar 2018         
Version       : 1.0     
Author        : TCS
-----------------------  Revision History -------------------

Sno      Version      Modification Done                                 Modified By            Modified Date
1        1.0          Initial Version                                                
2        2.0          Mixed DML fixed and reduce SOQL queries           chernan3               14/07/2019                      
***************************************************************************************************************** */
@isTest
private class ThCheckoutControllerTest
{
    Static List<Asset> assetList = new List<Asset>();
  //  Static User usr = new User();
    Static Saved_Vehicle_for_Lead__c savedVehLead = new Saved_Vehicle_for_Lead__c ();
    Static Vehicle_Specification__c vehiclespec= new Vehicle_Specification__c();
  
/* **************************************************
    Method Name: setUpData
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to create test data
    ****************************************************** */ 
        
  @testSetup   static void setUpData() 
    {
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()]; // Added Sno 2
        RecordSharer.DisableRecordSharing = true; //DJB added
        AssetHandler.IgnoreMMIT = true; //DJB added
    
        CreateTestData tdata = new CreateTestData();
        Account acc = tdata.createPersonalAccount();
        insert acc;
        
       // Lead leadRec = tdata.createLead(acc);
       // insert leadRec;
        
      User  usr = tdata.createCustomerCommunityUser(acc);
       // Profile p = [select Id,name from Profile where UserType =:'CSPLiteUser' limit 1];
       // usr.ProfileId=p.id;
        usr.CPF__c =  '30030030031';
        System.runAs(usrAdmin) { // Added Sno 2
            insert usr;
        } // Added Sno 2
        
        tdata.createMaker();       
        tdata.createProducts();          
        tdata.createAssets();
     tdata.loadJUDAANMarketSettingsData();
        
        tdata.loadTradeinSetting();
       tdata.createVehicleSpecForCompare();
       
        //Query inserted Assets
        assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
        // variable vehiclespec not been used (Sno 2): vehiclespec=[select id,Make__c,product_code__c ,Name,Is_Currently_Sold__c from Vehicle_Specification__c limit 1];
         // assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
         assetList[0].APO__c = true;
        assetList[0].Product2.Make__r.Name = 'Jaguar';
        assetList[0].Account.Country_ISO_Code__c ='th';
        assetList[0].Local_price__c = 172999;
        update assetList[0];
       // Saved_Vehicle_for_Account__c savedVehAcc = tdata.createSavedVehicleForAccount( acc,assetList[0]);
      //  savedVehLead = tdata.createSavedVehicleForLead( leadRec, assetList[0]);  
        //insert savedVehLead;
        /*
        List <Vehicle_Specification__c> specs = [select id,Make__c,product_code__c ,Name,Is_Currently_Sold__c  from Vehicle_Specification__c ];
        System.assertEquals(3,specs.size());
        
        Id rtIDforModel = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        List<Product2> models = [select id from Product2 where RecordTypeId = : rtIDforModel]; 
        
        Id rtIDforDerivative = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        List<Product2> derivatives = [select id from Product2 where Model__c = : models[0].id and RecordTypeId = : rtIDforDerivative]; 
        System.assertEquals(1,derivatives.size());
        */
       // insert new JUDAANMarketSettings__c(Name='th',Reservation_Limit__c=1.0);
    }
    static testMethod void testAPOVehicleScenario() 
    {
        // Create test data      
         User usr = [Select id from User where cpf__c = '30030030031' limit 1]; 
         List<Asset> assetList = [Select id,Product2.Make__r.Name ,APO__c,Local_price__c,Account.Country_ISO_Code__c from asset];
        PageReference pageRef = Page.thCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'th' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        system.runAs(usr)
        {
            thCheckoutController ctrl = new thCheckoutController();
            Test.startTest();
            ctrl.setInit();
            system.assertEquals(assetList.get(0).Id, ctrl.Vehicle2Show.Id);
            ctrl.getBrands();
            ctrl.Make = 'JAGU';
            ctrl.getModels();
            ctrl.smodel = 'XJ';
            ctrl.getYears();
            ctrl.year = 2016;
            ctrl.getVehicles();
            ctrl.vehicle = 'JAGU16AI';
            ctrl.mileage = 50000;
            ctrl.DownPaymentValid = false;
            ctrl.RateValid = false;
            ctrl.doValidation();
            ctrl.releaseTradeinBtn();
            ctrl.getTradeinPrice();
            //ctrl.saveOppForTradeIn();
            system.assertEquals(196340, ctrl.TradeinPrice);
            ctrl.setTradein();
            system.assertEquals(true, ctrl.TradeinDone);
            ApexPages.currentPage().getParameters().put( 'fromDeposit' , '1');
            ctrl.saveQuote();
            system.assert(ctrl.dto.url.contains('thcheckout'));
            system.assert(ctrl.dto.willSend == false);
            Test.stopTest();
             
        }
       
        List<Opportunity> opps = new List<Opportunity>();
            opps = [select Id, 
                    Trade_In_Value__c , 
                    Trade_in_Vehicle__c, 
                    StageName, 
                    Local_deposit_amount__c,
                    Local_interest_charge__c,
                    Local_loan_amount__c,
                    Local_monthly_Payment_Amount__c,
                    Number_of_monthly_payment__c,
                    Interest_rate__c,
                    Local_total_paid_amount__c 
                    from Opportunity limit 1];
        
            system.assertEquals(1, opps.size());
    }
    static testMethod void testAPOVehicleSaveQuote() 
    {
        // Create test data 
        List<Asset> assetList = [Select id,Product2.Make__r.Name ,APO__c,Local_price__c,Account.Country_ISO_Code__c from asset];
           User usr = [Select id from User where cpf__c = '30030030031' limit 1];
        PageReference pageRef = Page.thCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'th' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        Test.startTest();
        system.runAs(usr)
        {
            thCheckoutController ctrl = new thCheckoutController();
            
            ctrl.setInit();
            system.assertEquals(assetList.get(0).Id, ctrl.Vehicle2Show.Id);
            ctrl.getBrands();
            ctrl.Make = 'JAGU';
            ctrl.getModels();
            ctrl.smodel = 'XJ';
            ctrl.getYears();
            ctrl.year = 2016;
            ctrl.getVehicles();
            ctrl.vehicle = 'JAGU16AI';
            ctrl.mileage = 50000;
            ctrl.releaseTradeinBtn();
            ctrl.getTradeinPrice();
            ctrl.SelectedPlan = '1';
           
            //ctrl.saveOppForTradeIn();
            system.assertEquals(196340, ctrl.TradeinPrice);
            ctrl.setTradein();
            system.assertEquals(true, ctrl.TradeinDone);
            ApexPages.currentPage().getParameters().put( 'fromDeposit' , '1');
            ctrl.saveQuote();
             system.assert(ctrl.dto.url.contains('thcheckout'));
           
            
             
        }
       
        List<Opportunity> opps = new List<Opportunity>();
            opps = [select Id, 
                    Trade_In_Value__c , 
                    Trade_in_Vehicle__c, 
                    StageName, 
                    Local_deposit_amount__c,
                    Local_interest_charge__c,
                    Local_loan_amount__c,
                    Local_monthly_Payment_Amount__c,
                    Number_of_monthly_payment__c,
                    Interest_rate__c,
                    Local_total_paid_amount__c 
                    from Opportunity limit 1];
       Test.stopTest(); 
            system.assertEquals(1, opps.size());
    }
    static testMethod void testAPOVehicleTradeIn() 
    {
        // Create test data 
      //  setUpData();
         List<Asset> assetList = [Select id,Product2.Make__r.Name ,APO__c,Local_price__c,Account.Country_ISO_Code__c from asset];
           User usr = [Select id from User where cpf__c = '30030030031' limit 1];
        PageReference pageRef = Page.thCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'th' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        system.runAs(usr)
        {
            thCheckoutController ctrl = new thCheckoutController();
            Test.startTest();
            ctrl.setPlan();
            ctrl.setInit();
            system.assertEquals(assetList.get(0).Id, ctrl.Vehicle2Show.Id);
            ctrl.getBrands();
            ctrl.Make = 'JAGU';
            ctrl.getModels();
            ctrl.smodel = 'XJ';
            ctrl.getYears();
            ctrl.year = 2016;
            ctrl.getVehicles();
            ctrl.vehicle = 'JAGU16AI';
            ctrl.mileage = 50000;
            ctrl.SelectedPlan = '0';
            ctrl.releaseTradeinBtn();
            ctrl.getTradeinPrice();
            ctrl.saveOppForTradeIn();
           
            system.assertEquals(196340, ctrl.TradeinPrice);
            ctrl.setTradein();
            system.assertEquals(true, ctrl.TradeinDone);
            Test.stopTest();
             
        }
       
        List<Opportunity> opps = new List<Opportunity>();
            opps = [select Id, 
                    Trade_In_Value__c , 
                    Trade_in_Vehicle__c, 
                    StageName, 
                    Local_deposit_amount__c,
                    Local_interest_charge__c,
                    Local_loan_amount__c,
                    Local_monthly_Payment_Amount__c,
                    Number_of_monthly_payment__c,
                    Interest_rate__c,
                    Local_total_paid_amount__c 
                    from Opportunity limit 1];
        
            system.assertEquals(1, opps.size());
    }
   
    
    static testMethod void testAPOVehiclePayment2() 
    {
        // Create test data 
         List<Asset> assetList = [Select id,Product2.Make__r.Name ,APO__c,Local_price__c,Account.Country_ISO_Code__c from asset];
           User usr = [Select id from User where cpf__c = '30030030031' limit 1];
        PageReference pageRef = Page.thCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'th' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        system.runAs(usr)
        {
            thCheckoutController ctrl = new thCheckoutController();
            Test.startTest();
            ctrl.setInit();
            system.assertEquals(assetList.get(0).Id, ctrl.Vehicle2Show.Id);
            ctrl.setDeposit();
            ctrl.skipPlan();
            system.assertEquals(true, ctrl.FinanceCalculationDone);
            system.assertEquals(true, ctrl.SkipFinance );
            ctrl.SkipFinance = false;
            ctrl.doPayment();
            Test.stopTest();
            
            
            ApexPages.currentPage().getParameters().put( 'fromDeposit' , '1');
          
            PageReference page = ctrl.goBack();

            ApexPages.currentPage().getParameters().put( 'level' , '1');
            ctrl.setUrl();
            system.assert(ctrl.dto.url.contains('customeraccountpage'));
           
            ApexPages.currentPage().getParameters().put( 'level' , '2');
            ctrl.setURL();
             system.assert(ctrl.dto.url.contains('thcheckout'));
           
            ctrl.checkIsReloaded();
             
            ctrl.RegularDeposit = '1000'; 
            ctrl.RegularTradeinPrice= '1000'; 
            ctrl.TotalPrice = 2000; 
            
            
            ctrl.RegularDepositForFL= '1000'; 
            ctrl.RegularTradeinPriceForFL= '1000'; 
            ctrl.TotalPrice = 2000; 
            ctrl.RegularNumOfPaymentforFL  = 36;
            Apexpages.currentPage().getParameters().put('hirep', 'hirep');   
            ctrl.calculateRegular(); 
            Apexpages.currentPage().getParameters().put('fl', 'fl');
            //ctrl.calculateFinanceLease(); 
        }
       
        
    }
    static testMethod void testURlForLogin() 
    {
        // Create test data 
         List<Asset> assetList = [Select id,Product2.Make__r.Name ,APO__c,Local_price__c,Account.Country_ISO_Code__c from asset];
           User usr = [Select id from User where cpf__c = '30030030031' limit 1];
        PageReference pageRef = Page.thCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'th' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        system.runAs(usr)
        {
            thCheckoutController ctrl = new thCheckoutController();
            Test.startTest();
            ctrl.setInit();
            system.assertEquals(assetList.get(0).Id, ctrl.Vehicle2Show.Id);
            ApexPages.currentPage().getParameters().put( 'level' , '2');
            ctrl.setURLForLogin();
     
            Test.stopTest();
            List<Opportunity> opps = new List<Opportunity>();
            opps = [select Id, 
                    Trade_In_Value__c , 
                    Trade_in_Vehicle__c, 
                    StageName, 
                    Local_deposit_amount__c,
                    Local_interest_charge__c,
                    Local_loan_amount__c,
                    Local_monthly_Payment_Amount__c,
                    Number_of_monthly_payment__c,
                    Interest_rate__c,
                    Local_total_paid_amount__c 
                    from Opportunity limit 1];
        
            system.assertEquals(0, opps.size());

             
        }
    }
    
    
     /* **************************************************
    Method Name: testAPOsearchScenario
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to 
    ****************************************************** */  
    
    /* **************************************************
    Method Name: testAPOsearchScenario
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to 
    ****************************************************** */  
   static testMethod void testNewVehicleScenario() 
    {
        
        Test.startTest();
          List<Asset> assetList = [Select id,Product2.Make__r.Name ,APO__c,Local_price__c,Account.Country_ISO_Code__c from asset];
        Asset ass = New Asset();
        ass.id = assetList.get(0).Id;
        ass.APO__c = false;
        update ass;
        PageReference pageRef = Page.thCheckout;
        Test.setCurrentPage(pageRef);
        // Create test data 
           User usr = [Select id from User where cpf__c = '30030030031' limit 1];
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'th' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'svid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        thCheckoutController ctrl = new thCheckoutController();
        system.runAs(usr)
        {
           ctrl.setInit();
           ctrl.SelectedPlan = '0';
           ctrl.SkipFinance = false;
           ctrl.RegularTradeinPrice =  '12,500';
           ctrl.setDTOFinance();
           ctrl.SkipFinance = true;
           ctrl.RegularTradeinPrice =  '12,500';
           ctrl.setDTOFinance();
           system.assertEquals(false, ctrl.IsAPO);
        }
        Test.stopTest();
    }
    
    //tm
         /* **************************************************
    Method Name: testPayHoldingDeposit
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to 
    ****************************************************** */ 

    static testMethod void testPayHoldingDeposit() 
    {
           User usr = [Select id, accountId from User where cpf__c = '30030030031' limit 1];
        Test.startTest();        
        // Create test data 
        
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        opp.AccountId = usr.AccountId;
        opp.Reservation_Cancelled__c = false;
        opp.Deposit_paid_date__c = System.today() + 5;
        insert new JUDAANMarketSettings__c(Name='th',Reservation_Limit__c=1.0);
        Test.stopTest();
    }
    
    
     static testMethod void testAPOVehicleSaveQuoteHirePurchase() 
    {
        // Create test data 
        List<Asset> assetList = [Select id,Product2.Make__r.Name ,APO__c,Local_price__c,Account.Country_ISO_Code__c from asset];
           User usr = [Select id from User where cpf__c = '30030030031' limit 1];
        PageReference pageRef = Page.thCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'th' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
            system.runAs(usr)
            {
                thCheckoutController ctrl = new thCheckoutController();
                Test.startTest();
                ctrl.setInit();
                system.assertEquals(assetList.get(0).Id, ctrl.Vehicle2Show.Id);
                ctrl.getBrands();
                ctrl.Make = 'JAGU';
                ctrl.getModels();
                ctrl.smodel = 'XJ';
                ctrl.getYears();
                ctrl.year = 2016;
                ctrl.getVehicles();
                ctrl.vehicle = 'JAGU16AI';
                ctrl.mileage = 50000;
                ctrl.releaseTradeinBtn();
                ctrl.getTradeinPrice();
                ctrl.SelectedPlan = '0';
                ApexPages.currentPage().getParameters().put('plan', '0');
                ctrl.setPlan();
                ctrl.RegularTradeinPrice =  '12,500';
                //ctrl.saveOppForTradeIn();
                system.assertEquals(196340, ctrl.TradeinPrice);
                ctrl.setTradein();
                system.assertEquals(true, ctrl.TradeinDone);
                ApexPages.currentPage().getParameters().put( 'fromDeposit' , '1');
                ctrl.saveQuote();
                system.assert(ctrl.dto.url.contains('thcheckout'));
                ctrl.checkIsReloaded();
             
                ctrl.calculateFinanceLease();
                Test.stopTest();
               
                system.assert(ctrl.SelectedBean.selectedYear == 2016);
                
                 
            }
        }
        
}