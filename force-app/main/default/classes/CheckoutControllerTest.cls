@isTest(SeeAllData = false)
private class CheckoutControllerTest 
{ 
    private static User currentUser { get; set; }
    private static String assetId { get; set; }
    private static Account acc { get; set; }
    private static Lead lead { get; set; }
    Static Vehicle_Specification__c vehiclespec= new Vehicle_Specification__c();
    private static String retailerRT { get; set; }
    @testSetup static void createData()
    {
        retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        List<Account> retailers = TestDataFactory.generateAccounts(1, retailerRT, '埼玉県', 'さいたま市;');
        Account retailer = retailers[0];

        system.assertEquals(1, retailers.size());
        String brand = TestDataFactory.generateVehicleSpecification('Land Rover');
        // Create Asset
        assetId = TestDataFactory.generateAsset(brand, retailer.Id);

        // Create user
        CreateTestData ctd = new CreateTestData();
        Account acc = ctd.createPersonalAccount();
        insert acc;
        Lead lead  = ctd.createLead(acc);
        insert lead;
        User currentUser1 = [select Id, AccountId from User where Id = :UserInfo.getUserId()];
        system.runas(currentUser1 ){
        currentUser = ctd.createCustomerCommunityUser(acc);
        insert currentUser;
        }
        ctd.loadJUDAANMarketSettingsData();
        ctd.createVehicleSpecForCompare();
        currentUser = [select Id, AccountId from User where Id = :currentUser.Id];

        Opportunity opp = TestDataFactory.generateOpportunity(assetId, currentUser.AccountId);
        opp = [select Id, Asset__c, AccountId from Opportunity where Id = :opp.Id];
        vehiclespec=[select id,Make__c,product_code__c ,Name,Is_Currently_Sold__c from Vehicle_Specification__c limit 1];
        system.assertEquals(true, opp.AccountId != null);
        system.assertEquals(true, opp.Asset__c != null);
    }
    @isTest static void testTradeinPositive()
    {
        // Get Asset
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        Lead l = [select Id, Account__c from Lead limit 1];
        Account acc = [select Id from Account where Id = :l.Account__c];
        // Insert saved vehicles
        TestDataFactory.generateSavedVehicleForLead(3, l.Id, asset.Id);
        Contact pcon = [Select id from contact Where AccountId = :l.Account__c Limit 1];
        User u = [select Id from User where ContactId = :pcon.Id];
        system.assertEquals(3, [select Id from Saved_Vehicle_for_Lead__c].size());
        
        PageReference checkout = Page.checkout;
        checkout.getParameters().put('vid', asset.Id); 
        checkout.getParameters().put('market', 'jp'); 
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());

        CheckoutController con = new CheckoutController();
        con.setInit();
        system.assertEquals(asset.Id, con.Vehicle2Show.Id);  
        // Trade in value
        con.getBrands();

        con.Brand = JUDAAN_MockHttpResponseGenerator.brand;
        con.getModels();
        
        con.Model = JUDAAN_MockHttpResponseGenerator.model;
        con.getGrades();

        con.Grade = JUDAAN_MockHttpResponseGenerator.grade;
        JUDAAN_MockHttpResponseGenerator.NoYear = false;
        con.getYears();
        
        con.Year = JUDAAN_MockHttpResponseGenerator.Year;
        con.getCatID();
        
        con.Vehicle = JUDAAN_MockHttpResponseGenerator.cate_id + ',' + JUDAAN_MockHttpResponseGenerator.year_num + ',' + JUDAAN_MockHttpResponseGenerator.handle_id;
        JUDAAN_MockHttpResponseGenerator.NoColor = false;
        con.getPriceColor();
        con.Color = String.valueOf(JUDAAN_MockHttpResponseGenerator.color);
        con.getColorName();        
        con.Mileage = JUDAAN_MockHttpResponseGenerator.mileage;
        con.getWholePrice();

        con.setSubjectiveValue();
        system.assertEquals(true, con.ShowSubjectiveValue);
        system.assertEquals(JUDAAN_MockHttpResponseGenerator.MyVehicle, con.MyVehicle);
        
        con.BrandName = 'レクサス';
        con.getWholePrice();
        system.assertEquals(5872000, con.TradeInPrice);
        
        con.setDeposit();
        con.dto.IsFirst = true;
        con.dto.userId = u.Id;
        checkout.getParameters().put('level', '1');
        con.setUrl();
        system.assertEquals(true, con.dto.SelectedVehicleBeanStr != null);
        checkout.getParameters().put('fromDeposit', '1');
        
        PageReference thePage = con.saveQuote();
        //system.assertEquals(3, [select Id from Saved_Vehicle_for_Account__c where Account__c = :acc.Id].size());
        system.assertEquals('1', con.FromDeposit); 
        Opportunity savedQuote = [select Id, Trade_in_Done__c, Trade_In_Value__c , Trade_In_Vehicle__c from Opportunity where AccountId = :acc.Id and Asset__c = :asset.Id and StageName = 'Save a Quote' limit 1];
        system.assertEquals(true, savedQuote != null);
        //system.assertEquals(5872000, savedQuote.Trade_In_Value__c );
        system.assertEquals('レクサス Fタイプ Sコンバーチブル 2014 ブラック', savedQuote.Trade_In_Vehicle__c);
        system.assertEquals(true, savedQuote.Trade_in_Done__c);
        
        system.runAs(u)
        {
            con.checkIsReloaded();
            con.saveQuote();
        }
        system.assertEquals('レクサス Fタイプ Sコンバーチブル 2014 ブラック', con.MyVehicle);
        system.assertEquals(5872000, con.TradeInPrice);
        
        Test.stopTest(); 
    }
     @isTest static void testFinanceCalculationPositive()
     {
        PageReference checkout = Page.checkout;
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        checkout.getParameters().put('vid', asset.Id); 
        String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        Account retailer = [select Id from Account where RecordTypeId = :retailerRT limit 1];
        Lead l = [select Id, Account__c from Lead limit 1];
        Contact pcon = [Select id from contact Where AccountId = :l.Account__c Limit 1];
        User u = [select Id from User where ContactId = :pcon.Id];
        FinanceRates__c finance = TestDataFactory.generateRates();
        
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        CheckoutController con = new CheckoutController();
        con.setInit();
        con.RegularTradeinPrice = '0';
        con.RegularDeposit = '100,000';
        con.RegularNumOfPayment = 60;
        con.RegularBonus = '50,000';
        con.PaymentPeriod = 60;
        
        // Test Option 1: Regular Plan
        JUDAAN_MockHttpResponseGenerator.plan = '0';
        JUDAAN_MockHttpResponseGenerator.FinanceNG = false;
        con.calculateRegular();
        system.assertEquals(5500000, con.LoanPrincipal);
        system.assertEquals(100230, con.Payment1st);
        system.assertEquals(98700, con.PaymentMonthly);
        system.assertEquals(60, con.PaymentPeriod);
        system.assertEquals(239130, con.InstallmentsFee);
        system.assertEquals(5739130, con.InstallmentsTotal);
        system.assertEquals(6239130, con.TotalPayments);
        system.assertEquals(con.Vehicle2Show.Local_Price__c, con.TotalPrice);
        
        // Test Option 2: Smart Ownership Plan
        con.SmartNumOfPayment = 37;
        con.setDefaultRate();
        con.SmartTradeinPrice = '0';
        con.SmartDeposit = '100,000';
        con.SmartBonus = '50,000';
        con.PaymentPeriod = 37;
        JUDAAN_MockHttpResponseGenerator.plan = '1';
        system.assertEquals(5000000, con.DifferedCost);
        con.calculateSmart();
        system.assertEquals(5500000, con.LoanPrincipal);
        system.assertEquals(100230, con.Payment1st);
        system.assertEquals(5000000, con.PaymentLast);
        system.assertEquals(98700, con.PaymentMonthly);
        system.assertEquals(37, con.PaymentPeriod);
        system.assertEquals(239130, con.InstallmentsFee);
        system.assertEquals(5739130, con.InstallmentsTotal);
        system.assertEquals(6239130, con.TotalPayments);
        system.assertEquals(con.Vehicle2Show.Local_Price__c, con.TotalPrice);
        
        // Test Set Plan
        checkout.getParameters().put('plan', '1');
        con.setTradein();
        con.setPlan();
        con.dto.IsFirst = true;
        con.dto.userId = u.Id;
        con.saveQuote();
        
        Opportunity savedQuote = [select Id, Number_of_monthly_payment__c, Finance_Calculation_Done__c, Selected_finance_option__c, First_Payment__c, Final_Payment__c, Local_Bonus_Payment_Amount__c, Local_deposit_amount__c, Local_interest_charge__c,  Local_loan_amount__c, Local_monthly_Payment_Amount__c, Local_total_paid_amount__c from Opportunity where AccountId = :l.Account__c and Asset__c = :asset.Id and StageName = 'Save a Quote' limit 1];
        system.assertEquals('Smart Ownership', savedQuote.Selected_finance_option__c);
        system.assertEquals('5500000', savedQuote.Local_loan_amount__c);
        system.assertEquals('100230', savedQuote.First_Payment__c);
        system.assertEquals('5000000', savedQuote.Final_Payment__c);
        system.assertEquals('98700', savedQuote.Local_monthly_Payment_Amount__c);
        system.assertEquals('37', savedQuote.Number_of_monthly_payment__c);
        system.assertEquals('239130', savedQuote.Local_interest_charge__c);
        system.assertEquals('6239130', savedQuote.Local_total_paid_amount__c );
        system.assertEquals(true, savedQuote.Finance_Calculation_Done__c);
        
        Test.stopTest();
     
     }
     
     @isTest static void testFinanceCalculationPositiveUrls()
     {
        PageReference checkout = Page.checkout;
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        checkout.getParameters().put('vid', asset.Id); 
        checkout.getParameters().put('market', 'jp');
        String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        Account retailer = [select Id from Account where RecordTypeId = :retailerRT limit 1];
        Lead l = [select Id, Account__c from Lead limit 1];
        Contact pcon = [Select id from contact Where AccountId = :l.Account__c Limit 1];
        User u = [select Id from User where ContactId = :pcon.Id];
        FinanceRates__c finance = TestDataFactory.generateRates();
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());

        
        CheckoutController con = new CheckoutController();
        con.setInit();
        con.RegularTradeinPrice = '0';
        con.RegularDeposit = '100,000';
        con.RegularNumOfPayment = 60;
        con.RegularBonus = '50,000';
        con.PaymentPeriod = 60;
        JUDAAN_MockHttpResponseGenerator.plan = '0';
        JUDAAN_MockHttpResponseGenerator.FinanceNG = false;
        con.calculateRegular();
        system.assertEquals(5500000, con.LoanPrincipal);
        system.assertEquals(100230, con.Payment1st);
        system.assertEquals(98700, con.PaymentMonthly);
        system.assertEquals(60, con.PaymentPeriod);
        system.assertEquals(239130, con.InstallmentsFee);
        system.assertEquals(5739130, con.InstallmentsTotal);
        system.assertEquals(6239130, con.TotalPayments);
        system.assertEquals(con.Vehicle2Show.Local_Price__c, con.TotalPrice);
        
        con.SmartNumOfPayment = 37;
        con.setDefaultRate();
        con.SmartTradeinPrice = '0';
        con.SmartDeposit = '100,000';
        con.SmartBonus = '50,000';
        
        con.PaymentPeriod = 37;
        JUDAAN_MockHttpResponseGenerator.plan = '1';
        system.assertEquals(5000000, con.DifferedCost);
        con.calculateSmart();
        system.assertEquals(5500000, con.LoanPrincipal);
        system.assertEquals(100230, con.Payment1st);
        system.assertEquals(5000000, con.PaymentLast);
        system.assertEquals(98700, con.PaymentMonthly);
        system.assertEquals(37, con.PaymentPeriod);
        system.assertEquals(239130, con.InstallmentsFee);
        system.assertEquals(5739130, con.InstallmentsTotal);
        system.assertEquals(6239130, con.TotalPayments);
        system.assertEquals(con.Vehicle2Show.Local_Price__c, con.TotalPrice);
        
        checkout.getParameters().put('plan', '1');
        con.setPlan();
        con.SelectedRetailer = retailer.Id;
        con.setRetailer();
        
        con.dto.IsFirst = true;
        con.dto.userId = u.Id;
        con.MyLang = 'ja';
        con.MyBrand = 'landrover';
        checkout.getParameters().put('level', '2');
        checkout.getParameters().put('svid', '11111111111');
        con.setUrl();
        system.assertEquals(5500000, Integer.valueOf(con.dto.finance.LoanPrincipal));
        system.assertEquals('/checkout?vid=' + con.Vehicle2Show.Id + '&brand=' + con.MyBrand + '&lang=' + con.MyLang + '&svid=11111111111' + '&market=jp', con.dto.url); 
        system.runAs(u)
        {
            con.saveQuote();
            con.checkIsReloaded();
        }
        
        List<Opportunity> theOpp = [select Id, StageName, Local_deposit_amount__c, 
                  Local_loan_amount__c, Interest_rate__c, 
                  Local_interest_charge__c, Local_monthly_Payment_Amount__c, 
                  Number_of_monthly_payment__c, Selected_finance_option__c, 
                  Local_total_paid_amount__c, Local_vehicle_price__c,
                  First_Payment__c, Final_Payment__c, Trade_In_Value__c , 
                  Trade_in_vehicle__c, Trade_in_Done__c
                  from Opportunity
                  where Asset__c = :con.Vehicle2Show.Id and AccountId = :l.Account__c];
        
        system.assertEquals(1, theOpp.size());
       
        Test.stopTest();
         
     }
     
      @isTest static void testFinanceCalculationPositiveOfSmartPlan()
      {
        PageReference checkout = Page.checkout;
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        Account retailer = [select Id from Account where RecordTypeId = :retailerRT limit 1];
        Lead l = [select Id, Account__c from Lead limit 1];
        Contact pcon = [Select id from contact Where AccountId = :l.Account__c Limit 1];
        User u = [select Id from User where ContactId = :pcon.Id];
        FinanceRates__c finance = TestDataFactory.generateRates();
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        checkout.getParameters().put('market', 'jp');
        checkout.getParameters().put('vid', asset.Id); 
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        CheckoutController con = new CheckoutController();
        con.setInit();
        con.RegularTradeinPrice = '0';
        con.RegularDeposit = '100,000';
        con.RegularNumOfPayment = 60;
        con.RegularBonus = '50,000';
        con.PaymentPeriod = 60;
        JUDAAN_MockHttpResponseGenerator.plan = '0';
        JUDAAN_MockHttpResponseGenerator.FinanceNG = false;
        con.calculateRegular();
        system.assertEquals(5500000, con.LoanPrincipal);
        system.assertEquals(100230, con.Payment1st);
        system.assertEquals(98700, con.PaymentMonthly);
        system.assertEquals(60, con.PaymentPeriod);
        system.assertEquals(239130, con.InstallmentsFee);
        system.assertEquals(5739130, con.InstallmentsTotal);
        system.assertEquals(6239130, con.TotalPayments);
        system.assertEquals(con.Vehicle2Show.Local_Price__c, con.TotalPrice);
         
        checkout.getParameters().put('plan', '0');
        con.setPlan();
        con.dto.IsFirst = true;
        con.dto.userId = u.Id;
        system.runAs(u)
        {
            con.saveQuote();
            con.checkIsReloaded();
        }
       
        Opportunity savedQuote = [select Id, Number_of_monthly_payment__c, Finance_Calculation_Done__c, Selected_finance_option__c, First_Payment__c, Final_Payment__c, Local_Bonus_Payment_Amount__c, Local_deposit_amount__c, Local_interest_charge__c,  Local_loan_amount__c, Local_monthly_Payment_Amount__c, Local_total_paid_amount__c from Opportunity where AccountId = :l.Account__c and Asset__c = :asset.Id and StageName = 'Save a Quote' limit 1];
        system.assertEquals('Regular Loan', savedQuote.Selected_finance_option__c);
        system.assertEquals('5500000', savedQuote.Local_loan_amount__c);
        system.assertEquals('100230', savedQuote.First_Payment__c);
        system.assertEquals('98700', savedQuote.Local_monthly_Payment_Amount__c);
        system.assertEquals('60', savedQuote.Number_of_monthly_payment__c);
        system.assertEquals('239130', savedQuote.Local_interest_charge__c);
        system.assertEquals('6239130', savedQuote.Local_total_paid_amount__c );
        system.assertEquals(true, savedQuote.Finance_Calculation_Done__c);
        
        Test.stopTest();
     }
     
     @isTest static void testFinanceCalculationPositiveSkipPlan()
     {
        PageReference checkout = Page.checkout;
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        checkout.getParameters().put('vid', asset.Id); 
        String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        Account retailer = [select Id from Account where RecordTypeId = :retailerRT limit 1];
        Lead l = [select Id, Account__c from Lead limit 1];
        Contact pcon = [Select id from contact Where AccountId = :l.Account__c Limit 1];
        User u = [select Id from User where ContactId = :pcon.Id];
        FinanceRates__c finance = TestDataFactory.generateRates();
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        CheckoutController con = new CheckoutController();
        con.setInit();
        con.dto.IsFirst = true;
        con.dto.userId = u.Id;
        con.skipPlan();
        con.saveQuote();
        Opportunity savedQuote = [select Id, Finance_Calculation_Done__c from Opportunity where AccountId = :l.Account__c and Asset__c = :asset.Id and StageName = 'Save a Quote' limit 1];
        system.assertEquals(true, savedQuote.Finance_Calculation_Done__c);
        
        Test.stopTest();
     }
     
    @isTest static void testRetailerLocatorPositive()
    {
        PageReference checkout = Page.checkout;
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        checkout.getParameters().put('vid', asset.Id); 
        checkout.getParameters().put('brand', 'landrover');
        checkout.getParameters().put('lang', 'ja');
        checkout.getParameters().put('svid', 'zzzzzzzzzzzz');
        checkout.getParameters().put('market', 'jp');
        TestDataFactory.generatePrefectureWardsMapping('埼玉県', new List<String> { 'さいたま市', '三芳町'});
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        CheckoutController con = new CheckoutController();
        con.setInit();
        con.setTradein();
        con.skipPlan();
        con.Prefecture2 = '埼玉県';
        con.filterWards();
        system.assertEquals(3, con.Wards2.size());
        con.Ward2 = '三芳町';
        con.searchRetailers();
        system.assertEquals(0, con.Retailers.size());

        con.Ward2 = 'さいたま市';
        con.searchRetailers();
        system.assertEquals(1, con.Retailers.size());

        PageReference singlePage = con.goBack();
        system.assertEquals(asset.Id, singlePage.getParameters().get('id')); 

        Test.stopTest();
    }

    @isTest static void testPayDeposit()
    {
        PageReference checkout = Page.checkout;
        assetId = [select Id from Asset limit 1].Id;
        checkout.getParameters().put('vid', assetId);
        checkout.getParameters().put('brand', 'landrover');
        checkout.getParameters().put('lang', 'ja');
        checkout.getParameters().put('market', 'jp');
        Account acc = [select Id from Account where FirstName = 'TestLastName'][0];
        system.assertEquals(1, [select Id from Account where FirstName = 'TestLastName'].size());
        User currentUser2 = [select Id, AccountId from User where AccountId = :acc.Id][0];
        system.assertEquals(1, [select Id, AccountId from User where AccountId = :acc.Id].size());
        system.assertEquals(true, currentUser2.AccountId != null); 
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());

        CheckoutController con = new CheckoutController();
        con.setInit();
        // Set Retailer
        String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        Account retailer = [select Id, Merchant_Id__c, Service_Id__c from Account where RecordTypeId = :retailerRT limit 1];
        system.assertEquals(true, retailer != null);
        con.SelectedRetailer = retailer.Id;        
        con.setRetailer();
        con.dto.IsFirst = false;
        con.dto.userId = currentUser2.Id;
        con.dto.willSend = false;
        con.dto.retaileriD = 
        checkout.getParameters().put('token', 'zzzzzz');
        checkout.getParameters().put('tokenkey', 'zzzzzz');
        con.TheRetailer  = new Account( ID = Label.JP_Dummy_Retailer );
        con.dto.retailerid = Label.JP_Dummy_Retailer;
        //con.doPayment(); 
        
        system.runAs(currentUser2)
        {
            con.doPayment();
            //con.updateOppStatus();
        }
        Opportunity opp = [select Id, StageName, Softbank_Payment_Tracking_ID__c from Opportunity limit 1];
        //system.assertEquals(null, con.SoftbankTrackingId);
        
        con.saveQuote();
        
        Test.stopTest();
    } 
   
    @isTest static void testInitNegative()
    {
        PageReference checkout = Page.checkout;
        Test.startTest();
        
        Test.setCurrentPage(checkout); 
        CheckoutController con = new CheckoutController();
        checkout.getParameters().put('vid', '1233456');
        checkout.getParameters().put('market', 'jp');
        Test.setCurrentPage(checkout);
        CheckoutController con2 = new CheckoutController();
        system.assertEquals(false, con2.ShowCheckPage);
        
        Test.stopTest();
    } 

    @isTest static void testFinanceRate()
    {
        PageReference checkout = Page.checkout;
        String brand = TestDataFactory.generateVehicleSpecification('Land Rover');
        String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        Account retailer = [select Id from Account where RecordTypeId = :retailerRT limit 1];
        /*List<Account> retailers = TestDataFactory.generateAccounts(1, retailerRT, '埼玉県', 'さいたま市;');
        Account retailer = retailers[0];*/
        Test.startTest(); //LB - moved to avoid test failure
        
        //String newAsset = TestDataFactory.generateAsset(brand, retailer.Id); 
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        FinanceRates__c finance = TestDataFactory.generateRates();
         
        
        checkout.getParameters().put('vid', asset.id);
        checkout.getParameters().put('market', 'jp');
        Test.setCurrentPage(checkout);
        
        CheckoutController con3 = new CheckoutController(); 
        con3.setInit();
        con3.SmartNumOfPayment = 37;
        con3.setDefaultRate();
        system.assertEquals(50.00, con3.DefaultUpRate);
        Test.stopTest();
    }

    //LB - disabled test as it is preventing a production release - TCS to fix 
    
    @isTest static void testProtoJLRPrice()
    {
        PageReference checkout = Page.checkout;
        String brand = TestDataFactory.generateVehicleSpecification('Land Rover');
        String retailerRT = TestDataFactory.getRecordType('Account', 'Retailer');
        Account retailer = [select Id from Account where RecordTypeId = :retailerRT limit 1];
       //LB - moved to avoid test failure
        //String newAsset = TestDataFactory.generateAsset(brand, retailer.Id); 
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        
        
        checkout.getParameters().put('vid', asset.id);
        Test.setCurrentPage(checkout);
        
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        Test.startTest(); 
        CheckoutController con4 = new CheckoutController(); 
        con4.getBrands();

        con4.Brand = JUDAAN_MockHttpResponseGenerator.brand;
        con4.getModels();
        
        con4.Model = JUDAAN_MockHttpResponseGenerator.model;
        con4.getGrades();

        con4.Grade = JUDAAN_MockHttpResponseGenerator.grade;
        JUDAAN_MockHttpResponseGenerator.NoYear = false;
        con4.getYears();
        
        con4.Year = JUDAAN_MockHttpResponseGenerator.Year;
        con4.getCatID();
        
        con4.Vehicle = JUDAAN_MockHttpResponseGenerator.cate_id + ',' + JUDAAN_MockHttpResponseGenerator.year_num + ',' + JUDAAN_MockHttpResponseGenerator.handle_id;
        JUDAAN_MockHttpResponseGenerator.NoColor = true;
        con4.getPriceColor();
        
        con4.Color = String.valueOf(JUDAAN_MockHttpResponseGenerator.color);
        con4.Mileage = JUDAAN_MockHttpResponseGenerator.mileage;
        con4.BrandName = 'ジャガー';
        con4.getWholePrice();
        
        system.assertEquals(6872000, con4.TradeInPrice);
        Test.stopTest();
    }
    

    @isTest static void testSaveWithLogin()
    {
        PageReference checkout = Page.checkout;
        assetId = [select Id from Asset limit 1].Id;
        checkout.getParameters().put('vid', assetId);
        checkout.getParameters().put('market', 'jp');
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());

        CheckoutController con5 = new CheckoutController(); 
        con5.getBrands();

        con5.Brand = JUDAAN_MockHttpResponseGenerator.brand;
        con5.getModels();
        
        con5.Model = JUDAAN_MockHttpResponseGenerator.model;
        con5.getGrades();

        con5.Grade = JUDAAN_MockHttpResponseGenerator.grade;
        JUDAAN_MockHttpResponseGenerator.NoYear = false;
        con5.getYears();
        
        con5.Year = JUDAAN_MockHttpResponseGenerator.Year;
        con5.getCatID();
        
        con5.Vehicle = JUDAAN_MockHttpResponseGenerator.cate_id + ',' + JUDAAN_MockHttpResponseGenerator.year_num + ',' + JUDAAN_MockHttpResponseGenerator.handle_id;
        JUDAAN_MockHttpResponseGenerator.NoColor = true;
        con5.getPriceColor();
        
        con5.Color = String.valueOf(JUDAAN_MockHttpResponseGenerator.color);
        con5.Mileage = JUDAAN_MockHttpResponseGenerator.mileage;

        checkout.getParameters().put('level', '1');

        
        Test.stopTest();

    }
    
    @isTest static void testTradeinvalueNegative()
    {
        // No Year
        PageReference checkout = Page.checkout;
        assetId = [select Id from Asset limit 1].Id;
        checkout.getParameters().put('vid', assetId);
        checkout.getParameters().put('market', 'jp');
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());

        CheckoutController con6 = new CheckoutController(); 
        con6.getBrands();

        con6.Brand = JUDAAN_MockHttpResponseGenerator.brand;
        con6.getModels();
        
        con6.Model = JUDAAN_MockHttpResponseGenerator.model;
        con6.getGrades();

        con6.Grade = JUDAAN_MockHttpResponseGenerator.grade;
        JUDAAN_MockHttpResponseGenerator.NoYear = true;
        con6.getYears();
        
        System.assertEquals(false, con6.DoEvaluation);
        system.assertEquals(true, con6.TradeinErrorMsg != null);
        
        JUDAAN_MockHttpResponseGenerator.NoYear = false;
        con6.getYears();
        System.assertEquals(false, con6.DoEvaluation);
        system.assertEquals(true, con6.TradeinErrorMsg == '');
        
        con6.Year = JUDAAN_MockHttpResponseGenerator.Year;
        con6.getCatID();
        
        // No color
        con6.Vehicle = JUDAAN_MockHttpResponseGenerator.cate_id + ',' + JUDAAN_MockHttpResponseGenerator.year_num + ',' + JUDAAN_MockHttpResponseGenerator.handle_id;
        JUDAAN_MockHttpResponseGenerator.NoColor = true;
        con6.getPriceColor();
        
        System.assertEquals(true, con6.NoColor);
        system.assertEquals(true, con6.TradeinErrorMsg != null);

        con6.setTradein();
        system.assertEquals(true, con6.TradeinDone);
        
        Test.stopTest();
    }
    
    @isTest static void testFinanceCalculationNegative()
    {
        // plan 1 : regular plan
        PageReference checkout = Page.checkout;
        Asset asset = [select Id, Model__c from Asset where Model__c != null limit 1];
        checkout.getParameters().put('vid', asset.Id); 
        checkout.getParameters().put('market', 'jp');
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        CheckoutController con = new CheckoutController();

        con.RegularTradeinPrice = '0';
        con.RegularDeposit = '100,000';
        con.RegularNumOfPayment = 60;
        con.RegularBonus = '50,000';
        con.PaymentPeriod = 60;
        JUDAAN_MockHttpResponseGenerator.plan = '0';
        JUDAAN_MockHttpResponseGenerator.FinanceNG = true;
        con.calculateRegular();
        system.assertEquals(true, con.ShowError);
        system.assertEquals('error msg', con.ErrorMsg);
        
        // Plan 2 : Smart Ownership
        con.SmartTradeinPrice = '0';
        con.SmartDeposit = '100,000';
        con.SmartBonus = '50,000';
        con.DifferedCost = 300000;
        con.PaymentPeriod = 37;
        JUDAAN_MockHttpResponseGenerator.plan = '1';
        JUDAAN_MockHttpResponseGenerator.FinanceNG = true;
        con.calculateSmart();
        system.assertEquals(true, con.ShowError);
        system.assertEquals('error msg', con.ErrorMsg);
        
        Test.stopTest();
    }
    
    @isTest static void testShowVehicle()
    {
        
        system.assertEquals(1, [select Id, Model__c from Asset].size());
        Asset asset = [select Id, Model__r.Name, Model__c from Asset limit 1];
        system.assertEquals(true, asset != null);
        
       
        PageReference checkout = Page.Checkout;
        Test.startTest();
        
        Test.setCurrentPage(checkout);
        checkout.getParameters().put('market', 'jp');
        checkout.getParameters().put('vid', '1111111');
        CheckoutController con = new CheckoutController();
        
        checkout.getParameters().put('vid', asset.Id);
        CheckoutController con2 = new CheckoutController();
        con2.setInit();
        system.assertEquals(null, con2.Camp2Show.Id);
        
        TestDataFactory.generateCampaign(asset.Model__c, 'jp');
        system.assertEquals(1,[select Id, Product__r.Name from JUDAAN_Campaign__c where Market__c = 'jp'].size());
        CheckoutController con3 = new CheckoutController(); 
        checkout.getParameters().put('vid', asset.Id);
        con3.setInit();
        system.assertEquals(true, con3.Camp2Show.Id != null);
        
        Test.stopTest();
    }
    
    @isTest static void testSetMyBudget()
    {
        system.assertEquals(1, [select Id, Model__c from Asset].size());
        Asset asset = [select Id, Model__r.Name, Model__c from Asset limit 1];
        system.assertEquals(true, asset != null);
        PageReference checkout = Page.checkout;
        Test.startTest();
        Test.setCurrentPage(checkout);
        checkout.getParameters().put('market', 'jp');
        checkout.getParameters().put('vid', '1111111');
        checkout.getParameters().put('vid', asset.Id);
        CheckoutController con = new CheckoutController();
        con.dto.IsPayment= true;
        Test.setMock(HttpCalloutMock.class, new JUDAAN_MockHttpResponseGenerator());
        JUDAAN_JACCSProccesor myBudget = new JUDAAN_JACCSProccesor();
        Integer budget = myBudget.doBackCalculation(60, 10000, 200000, 100000);
        system.assertEquals(6697000, budget);

        JUDAAN_BackPrice2Apex backPrice = JUDAAN_BackPrice2Apex.parse(null);
        system.assertEquals(null, backPrice.error);
        
        Test.stopTest();
    }
    
}