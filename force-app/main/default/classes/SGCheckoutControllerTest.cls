/* *************************************************************************************************************    
Class Name    : SGCheckoutControllerTest

Description   : This class is used for testing functionality of 
SGCheckoutController 
CreatedDate   : 09 Mar 2018         
Version       : 1.0     
Author        : TCS
-----------------------  Revision History -------------------

Sno      Version      Modification Done                                 Modified By            Modified Date
1        1.0          Initial Version                                                

***************************************************************************************************************** */
@isTest
private class SGCheckoutControllerTest
{
    Static List<Asset> assetList = new List<Asset>();
    Static User usr = new User();
    Static Saved_Vehicle_for_Lead__c savedVehLead = new Saved_Vehicle_for_Lead__c ();
    Static Vehicle_Specification__c vehiclespec= new Vehicle_Specification__c();
  
/* **************************************************
    Method Name: setUpData
    Input Parameters: NA
    Return Type: Integer NA
    Method Description: Method to create test data
    ****************************************************** */ 
        
    @testSetup static void setUpData() 
    {
    
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        
        RecordSharer.DisableRecordSharing = true; //DJB added
        AssetHandler.IgnoreMMIT = true; //DJB added
    
        CreateTestData tdata = new CreateTestData();
        Account acc = tdata.createPersonalAccount();
        insert acc;
        
        Lead leadRec = tdata.createLead(acc);
        insert leadRec;
        
        usr = tdata.createCustomerCommunityUser(acc);
       // Profile p = [select Id,name from Profile where UserType =:'CSPLiteUser' limit 1];
       // usr.ProfileId=p.id;
       
        System.runAs(usrAdmin) { 
        insert usr;
        }
        
        tdata.createMaker();
        tdata.createProducts();
        tdata.createAssets();
        tdata.loadJUDAANMarketSettingsData();
        tdata.loadTradeinSetting();
        tdata.createVehicleSpecForCompare();
        
        //Query inserted Assets
        assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
        
        
        Saved_Vehicle_for_Account__c savedVehAcc = tdata.createSavedVehicleForAccount( acc,assetList[0]);
        savedVehLead = tdata.createSavedVehicleForLead( leadRec, assetList[0]);  
        //insert savedVehLead;
        
        
    }
    static testMethod void testAPOVehicleScenario() 
    {
        // Create test data 
       
        assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
        assetList[0].APO__c = true;
        assetList[0].Product2.Make__r.Name = 'Jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Local_price__c = 172999;
        update assetList[0];
       
        PageReference pageRef = Page.SGCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        usr = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(usr)
        {
             Test.startTest();
            SGCheckoutController ctrl = new SGCheckoutController();
            
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
            //ctrl.saveOppForTradeIn();
            system.assertEquals(196340, ctrl.TradeinPrice);
            ctrl.setTradein();
            system.assertEquals(true, ctrl.TradeinDone);
            ApexPages.currentPage().getParameters().put( 'fromDeposit' , '1');
            ctrl.saveQuote();
            
            
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
      
        assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
        assetList[0].APO__c = true;
        assetList[0].Product2.Make__r.Name = 'Jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Local_price__c = 172999;
        //update assetList[0];
       
        PageReference pageRef = Page.SGCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        usr = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(usr)
        {
            Test.startTest();
            SGCheckoutController ctrl = new SGCheckoutController();
            
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
            //ctrl.saveOppForTradeIn();
            system.assertEquals(196340, ctrl.TradeinPrice);
            ctrl.setTradein();
            system.assertEquals(true, ctrl.TradeinDone);
            ApexPages.currentPage().getParameters().put( 'fromDeposit' , '1');
            ctrl.saveQuote();
            ctrl.saveOppForTradeIn();
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
    static testMethod void testAPOVehicleTradeIn() 
    {
        // Create test data 
        RecordSharer.DisableRecordSharing = true; 
        AssetHandler.IgnoreMMIT = true; 
 
        assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
        assetList[0].APO__c = true;
        assetList[0].Product2.Make__r.Name = 'Jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Local_price__c = 172999;
        //update assetList[0];
       
        PageReference pageRef = Page.SGCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        usr = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(usr)
        { Test.startTest();
            SGCheckoutController ctrl = new SGCheckoutController();
           
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
   
       
    static testMethod void testAPOVehiclePayment() 
    {
        // Create test data 
        RecordSharer.DisableRecordSharing = true; //DJB added
        AssetHandler.IgnoreMMIT = true; //DJB added
        
        assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
        assetList[0].APO__c = true;
        assetList[0].Product2.Make__r.Name = 'Jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Local_price__c = 172999;
        update assetList[0];
       
        PageReference pageRef = Page.SGCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        usr = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(usr)
        {
           Test.startTest();
            SGCheckoutController ctrl = new SGCheckoutController();
            //Test.startTest();
            ctrl.setInit();
            system.assertEquals(assetList.get(0).Id, ctrl.Vehicle2Show.Id);
            
            ctrl.InterestRate = 0;
            ctrl.RegularTradeinPrice = '';
            system.assertEquals('69200', ctrl.RegularDeposit);
            system.assertEquals(36, ctrl.RegularNumOfPayment);
            
            ctrl.calculateRegular();
            system.assertEquals(69200, ctrl.DownPayment);
            system.assertEquals(103799, ctrl.LoanPrincipal);
            system.assertEquals(2883, ctrl.PaymentMonthly);
            system.assertEquals(36, ctrl.PaymentPeriod);
            system.assertEquals(0, ctrl.Rate);
            system.assertEquals(103788, ctrl.InstallmentsFee);
            system.assertEquals(172988, ctrl.totalPayments);
            ctrl.setDeposit();
            system.assert(ctrl.dto.IsPayment == false);
            ctrl.setPlan();
            
            system.assertEquals(true, ctrl.FinanceCalculationDone);
          
            
            Test.stopTest();
            ApexPages.currentPage().getParameters().put( 'fromDeposit' , '0');
            PageReference page = ctrl.goBack();

            ApexPages.currentPage().getParameters().put( 'level' , '1');
            ctrl.setUrl();
            system.assert(ctrl.dto.url.contains('customeraccountpage'));
            ApexPages.currentPage().getParameters().put( 'level' , '2');
            ctrl.setURL();
            system.assert(ctrl.dto.url.contains('sgcheckout'));
          
             
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
        RecordSharer.DisableRecordSharing = true; 
        AssetHandler.IgnoreMMIT = true; 
        
        assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
        assetList[0].APO__c = true;
        assetList[0].Product2.Make__r.Name = 'Jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Local_price__c = 172999;
        //update assetList[0];
       
        PageReference pageRef = Page.SGCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        usr = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(usr)
        {
            Test.startTest();
            SGCheckoutController ctrl = new SGCheckoutController();
             //Test.startTest();     
            ctrl.setInit();
            system.assertEquals(assetList.get(0).Id, ctrl.Vehicle2Show.Id);
            ctrl.setDeposit();
            ctrl.skipPlan();
            system.assertEquals(true, ctrl.FinanceCalculationDone);
            system.assertEquals(true, ctrl.SkipFinance );
           
                 
           
            ctrl.doPayment();
           
            ApexPages.currentPage().getParameters().put( 'level' , '2');
            ctrl.setURL();
     
            system.assertEquals(false, ctrl.dto.willSend);
            
            ctrl.checkIsReloaded();
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
    static testMethod void testURlForLogin() 
    {
        // Create test data 
        
        assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
        assetList[0].APO__c = true;
        assetList[0].Product2.Make__r.Name = 'Jaguar';
        assetList[0].Account.Country_ISO_Code__c ='sg';
        assetList[0].Local_price__c = 172999;
        update assetList[0];
       
        PageReference pageRef = Page.SGCheckout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        usr = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(usr)
        {
            Test.startTest();
            SGCheckoutController ctrl = new SGCheckoutController();
            //Test.startTest();
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
        PageReference pageRef = Page.SGCheckout;
        Test.setCurrentPage(pageRef);
        // Create test data 
        
        assetList = [select id,Product2.Make__c,Product2.Make__r.Name,AccountId,Account.Country_ISO_Code__c,APO__c,pictures__c,mileage__c,Local_price__c,Product2.APO_Body_Style_Alternative__c,Product2.model_alternative__c,Product2.Specification_Pack_Alternative__c,Product2.Model_Year_Alternative__c,Product2.Transmission_Alternative__c,Product2.Fuel_Type_Alternative__c,Vehicle_Initial_Registration_Date__c,FromLocalPrice__c,ToLocalPrice__c,FromMileage__c,ToMileage__c,Exterior_Colour_Group__c,Interior_Color__c,highlighted_base__c from Asset limit 1];
       
        ApexPages.currentPage().getParameters().put( 'lang' , 'en' );
        ApexPages.currentPage().getParameters().put( 'market' , 'sg' );
        ApexPages.currentPage().getParameters().put( 'brand' , 'jaguar' );
        ApexPages.currentPage().getParameters().put( 'vid' , assetList.get(0).Id );
        ApexPages.currentPage().getParameters().put( 'svid' , assetList.get(0).Id );
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        SGCheckoutController ctrl = new SGCheckoutController();
        usr = [SELECT Id FROM User ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(usr)
        {
           ctrl.setInit();
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
        Test.startTest();        
        
        insert new JUDAANMarketSettings__c(Name='sg',Reservation_Limit__c=1.0);
        Test.stopTest();
    }
}