/*
||      Name : VME_Sales_Link_Controller_Test.apxc
||      Author: Deepti Tanguturi
||      Purpose: VME Sales Link Test class to get the avialable schemes for the opportunity
||      Created Date : 29/04/2018
||      Modified By : Sumit Kumar @Marlabs
||      Reason : Sale Link Logic Got modified
||      Modified Date : 23/08/2019
*/
@isTest

private class VME_Sales_Link_Controller_Test {
        public static VME_Schemes__c vmeScheme;
        public static Vehicle_Specification__c vehicle;
        public static List < VME_Sales_Link.VME_Campaign_Scheme_Wrapper > schemeWrap;
        public static VME_Campaign__c vmeCampaign;
        public static Id p;
        public static Account retailer;
        public static Contact con;
        @testSetup
        public static void dataSetup() {
                User adminUser = VME_TestDataUtilityClass.createSalesforceUser();
                Insert adminUser;
                System.RunAs(adminUser) {
                        p = [select id from profile where name = 'Retailer Finance (VME) User'].id;
                        //create Retailer Record
                        Account retailer = VME_TestDataUtilityClass.createRetailer();
                        Insert retailer;
                        //create JLR COntact Record
                        Contact conmContact = new Contact(FirstName = 'JLR', LastName = 'testCon', AccountId = retailer.Id, Email = 'jlrtest@gmailcon.com');
                        Insert conmContact;
                        //create COmmunity User Record
                        User comUser = new User(alias = 'etComUse', email = 'slaesLink@comUser.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_IN', localesidkey = 'en_IN', profileid = p, country = 'India', IsActive = true, ContactId = conmContact.Id, Market__c = 'IN', Is_Marketing_User__c = true, timezonesidkey = 'Asia/Kolkata', username = 'useret@salesLink.com');
                        Insert comUser;
                        //create Customer/Indivisual Record
                        Account customer = VME_TestDataUtilityClass.createCustomer();
                        customer.Alternative_Key__c = 'IN1193874';
                        customer.OwnerId = comUser.Id;
                        Insert customer;
                        //Create Vehicle_Specification__c data MAke Type
                        Vehicle_Specification__c jaguarVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
                        Insert jaguarVehicle;
                        Vehicle_Specification__c landRoverVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Land Rover');
                        Insert landRoverVehicle;
                        //Create Vehicle_Specification__c data Model Type
                        Vehicle_Specification__c jaguarVehicleModel = VME_TestDataUtilityClass.BuildVehicleModel('XF', 'V3');
                        jaguarVehicleModel.Make__c = jaguarVehicle.Id;
                        Insert jaguarVehicleModel;
                        //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 61 ' +  Limits.getQueries());
                        //Create Product of Model Type Jaguar
                        Product2 modelProductJag = VME_TestDataUtilityClass.CreateModelProduct('XF', 'V3', '  XF');
                        modelProductJag.Make__c = jaguarVehicle.Id;
                        modelProductJag.VME_GST__c = 50;
                        Insert modelProductJag;
                        //Create Product of Derivative Type Jaguar
                        Product2 derivativeProductJag = VME_TestDataUtilityClass.CreateDerivativeProduct('XF (X250) Facelift 2200 Luxury Automatic Singapore', '5000217157', 'XF');
                        derivativeProductJag.Make__c = jaguarVehicle.Id;
                        derivativeProductJag.Model__c = modelProductJag.Id;
                        derivativeProductJag.VME_GST__c = 50;
                        derivativeProductJag.Engine_Name_Alternative__c = '2.2 i4 Diesel';
                        derivativeProductJag.Model_Year_Alternative__c = '2015';
                        Insert derivativeProductJag;
                        //Create Product of Derivative Type Jaguar 2
                        Product2 derivativeProductJag2 = VME_TestDataUtilityClass.CreateDerivativeProduct('XF (X250) Facelift 2000 Premium Luxury Automatic', '5000177846', 'XF');
                        derivativeProductJag2.Make__c = jaguarVehicle.Id;
                        derivativeProductJag2.Model__c = modelProductJag.Id;
                        derivativeProductJag2.VME_GST__c = 50;
                        derivativeProductJag2.Engine_Name_Alternative__c = '2.0 i4 Petrol';
                        derivativeProductJag2.Model_Year_Alternative__c = '2013';
                        Insert derivativeProductJag2;
                        //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 82 ' +  Limits.getQueries());
                        //create opportunity for the Customer
                        Opportunity opp = VME_TestDataUtilityClass.createDeal('(SOCH Apparels Pvt Ltd)-SalesLInk', 'Contacted', 'OSA Post Approval DMS', Date.today().addDays(-15), 'Phone-in', 950000000, Date.today().addDays(-7));
                        opp.AccountId = customer.Id;
                        opp.OwnerId = comUser.Id;
                        opp.Brand__c = jaguarVehicle.Id;
                        opp.Primary_Model_Interest__c = jaguarVehicleModel.Id;
                        opp.VME_Trade_in_Type__c = 'Exchange JLR to JLR';
                        //create opportunity for the Customer
                        Opportunity opp2 = VME_TestDataUtilityClass.createDeal('TTUMIT OPP TESTEE', 'Contacted', 'OSA Post Approval DMS', Date.today().addDays(-15), 'Phone-in', 950000000, Date.today().addDays(-7));
                        opp2.AccountId = customer.Id;
                        opp2.OwnerId = comUser.Id;
                        opp2.Brand__c = jaguarVehicle.Id;
                        opp2.Primary_Model_Interest__c = jaguarVehicleModel.Id;
                        opp2.VME_Trade_in_Type__c = 'Exchange JLR to JLR';

                        //create opportunity for the Customer
                        Opportunity opp3 = VME_TestDataUtilityClass.createDeal('ZZUMIT OPP TESTEE', 'Contacted', 'OSA Post Approval DMS', Date.today().addDays(-15), 'Phone-in', 950000000, Date.today().addDays(-7));
                        opp3.AccountId = customer.Id;
                        opp3.OwnerId = comUser.Id;
                        opp3.Brand__c = jaguarVehicle.Id;
                        opp3.Primary_Model_Interest__c = jaguarVehicleModel.Id;
                        opp3.VME_Trade_in_Type__c = 'Exchange JLR to JLR';
                        Test.startTest();

                        Insert opp;
                        
                        
                        List<Asset> assetList = new List<Asset>();
                        //Create VIN for vme_Scheme_Obj3
                        Asset FIRST_ASSET_VIN = VME_TestDataUtilityClass.createVIN('SADCA2AK3HA087201', '', 95000000, 105000000, 'New', 'Created');
                        FIRST_ASSET_VIN.Brand__c = jaguarVehicle.Id;
                        FIRST_ASSET_VIN.Model__c = modelProductJag.Id;
                        FIRST_ASSET_VIN.Derivative__c = derivativeProductJag.Id;
                        FIRST_ASSET_VIN.AccountId = customer.Id;
                        FIRST_ASSET_VIN.Retailer_Name__c = retailer.Id;
                        FIRST_ASSET_VIN.Product2Id = derivativeProductJag.Id;
                        FIRST_ASSET_VIN.Manufacture_Year__c = Date.today().addDays(-5);
                        FIRST_ASSET_VIN.VME_Market_Arrival_Date__c = Date.today().addDays(-5);
                        Insert FIRST_ASSET_VIN;
                        //assetList.add(FIRST_ASSET_VIN);
                        //Updating Opportunity Line Item with Asset
                        //Create QMSP Master Record
                        Campaign QMSPObj = VME_TestDataUtilityClass.init_QMSP_Record();
                        QMSPObj.Name = 'Q2 - 2019-20 - Jaguar - XF - INDIA';
                        QMSPObj.VME_Brand__c = jaguarVehicle.Id;
                        QMSPObj.QMSP_Model__c = modelProductJag.Id;
                        Insert QMSPObj;
                        Test.stopTest();
                        //Create VME campaign record //VME-CMP-0000000003
                        VME_Campaign__c vme_Camp_Object = VME_TestDataUtilityClass.vme_Camp_init('Regular', 15000, 'IN', 'Q2', Date.today().addDays(-30), Date.today().addDays(+30));
                        vme_Camp_Object.VME_Brand__c = jaguarVehicle.Id;
                        vme_Camp_Object.VME_Model__c = modelProductJag.Id;
                        vme_Camp_Object.QMSP_Campaign__c = QMSPObj.Id;
                        vme_Camp_Object.VME_Sub_Category__c = 'Trade-In Support';
                        vme_Camp_Object.VME_Country_ISO_Code__c = 'IN';
                        vme_Camp_Object.VME_Country__c = 'India';
                        vme_Camp_Object.VME_Fiscal_Year__c = String.valueOf(Date.today().year());
                        // vme_Camp_Object.VME_Submit_Claim_Within_X_Days__c = 30;
                        vme_Camp_Object.VME_External_ID__c = 'VJ20BE02RRFFI2R81258307';
                        vme_Camp_Object.VME_Category__c = 'Retail Non-Finance';
                        vme_Camp_Object.VME_Sub_Category__c = 'Cash Programmes';
                        vme_Camp_Object.VME_Approved_Volume__c = 124;
                        vme_Camp_Object.VME_Approved_Budget__c = 500000;
                        vme_Camp_Object.VME_Adjusted_PU_Amount__c = 500000;
                        Insert vme_Camp_Object;
                        //Create VME Scheme1 record for vme_Camp_Object #1
                        VME_Schemes__c vme_Scheme_Obj1 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-20), Date.today().addDays(+20), 69, 25000, 'Parent', 'Others', '');
                        vme_Scheme_Obj1.VME_Campaign__c = vme_Camp_Object.Id;
                        Insert vme_Scheme_Obj1;
                        //Create Bundling 1 Object for vme_Scheme_Obj1 Model Based
                        VME_Bundling__c bundlingObj1 = new VME_Bundling__c();
                        bundlingObj1.VME_Scheme__c = vme_Scheme_Obj1.Id;
                        bundlingObj1.VME_Model_Derivative__c = modelProductJag.Id;
                        Insert bundlingObj1;

                        opp2.VME_Selected_Scheme_Id__c = vme_Scheme_Obj1.Id;
                        opp2.VME_Selected_Schemes__c = vme_Scheme_Obj1.Id+','+vme_Scheme_Obj1.Name;
                        Insert opp2;

                        opp3.VME_Selected_Scheme_Id__c = vme_Scheme_Obj1.Id;
                        opp3.VME_Selected_Schemes__c = vme_Scheme_Obj1.Id+','+vme_Scheme_Obj1.Name;
                        //Insert opp3;

                        //Create VME Scheme1 record for vme_Camp_Object #2
                        VME_Schemes__c vme_Scheme_Obj2 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-20), Date.today().addDays(+20), 76, 12400, 'Parent', 'Others', 'Exchange JLR to JLR');
                        vme_Scheme_Obj2.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Obj2.VME_Trade_In__c = 'Exchange JLR to JLR';
                        Insert vme_Scheme_Obj2;
                        //Create VME Scheme1R record for vme_Camp_Object #2
                        VME_Schemes__c vme_Scheme_Obj2R = VME_TestDataUtilityClass.vme_Schemes_Init(null, null, 0, 0, 'Child', 'Others', '');
                        vme_Scheme_Obj2R.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Obj2R.VME_Parent_Scheme__c = vme_Scheme_Obj2.Id;
                        vme_Scheme_Obj2R.VME_Retailer__c = retailer.Id;
                        Insert vme_Scheme_Obj2R;
                        //Create Bundling 1 Object vme_Scheme_Obj2 Derivative Based
                        VME_Bundling__c bundlingObj2 = new VME_Bundling__c();
                        bundlingObj2.VME_Scheme__c = vme_Scheme_Obj2.Id;
                        bundlingObj2.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObj2;
                        //Create VME Scheme1 record for vme_Camp_Object #3
                        VME_Schemes__c vme_Scheme_Obj3 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-20), Date.today().addDays(+20), 125, 24000, 'Parent', 'Others', 'Exchange Non Premium');
                        vme_Scheme_Obj3.VME_Campaign__c = vme_Camp_Object.Id;
                        Insert vme_Scheme_Obj3;
                        //Create Bundling 1 Object for vme_Scheme_Obj3 Derivative Based
                        VME_Bundling__c bundlingObj3 = new VME_Bundling__c();
                        bundlingObj3.VME_Scheme__c = vme_Scheme_Obj3.Id;
                        bundlingObj3.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObj3;
                        //Create VME Scheme1 record for vme_Camp_Object #3
                        VME_Schemes__c vme_Scheme_Obj4 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-20), Date.today().addDays(+20), 125, 25000, 'Parent', 'Others', 'Exchange Non Premium');
                        vme_Scheme_Obj4.VME_Campaign__c = vme_Camp_Object.Id;
                        Insert vme_Scheme_Obj4;
                        //Create Bundling 1 Object for vme_Scheme_Obj4 Derivative Based
                        VME_Bundling__c bundlingObj4 = new VME_Bundling__c();
                        bundlingObj4.VME_Scheme__c = vme_Scheme_Obj4.Id;
                        bundlingObj4.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObj4;
                        //Create VME Scheme1 record for vme_Camp_Object #5
                        VME_Schemes__c vme_Scheme_Obj5 = VME_TestDataUtilityClass.vme_Schemes_Init(null, null, 0, 0, 'Child', 'Others', '');
                        vme_Scheme_Obj5.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Obj5.VME_Parent_Scheme__c = vme_Scheme_Obj2.Id;
                        vme_Scheme_Obj5.VME_Retailer__c = retailer.Id;
                        Insert vme_Scheme_Obj5;
                        //Create VME Scheme1 record for vme_Camp_Object
                        VME_Schemes__c vme_Scheme_Obj6 = VME_TestDataUtilityClass.vme_Schemes_Init(null, null, 0, 0, 'Child', 'Others', '');
                        vme_Scheme_Obj6.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Obj6.VME_Parent_Scheme__c = vme_Scheme_Obj3.Id;
                        vme_Scheme_Obj6.VME_Retailer__c = retailer.Id;
                        Insert vme_Scheme_Obj6;

                        /* Asset Basewd Scheme */
                        //Create VME Scheme1 record for vme_Camp_Object #3
                        VME_Schemes__c vme_Scheme_Objvin = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-20), Date.today().addDays(+20), 125, 25000, 'Parent', 'Others', '');
                        vme_Scheme_Objvin.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Objvin.VME_Manufacturing_Start_Date__c = Date.today().addDays(-10);
                        vme_Scheme_Objvin.VME_Manufacturing_End_Date__c = Date.today().addDays(+10);
                        Insert vme_Scheme_Objvin;
                        //Create Bundling 1 Object for vme_Scheme_Objvin Derivative Based
                        VME_Bundling__c bundlingObjvin = new VME_Bundling__c();
                        bundlingObjvin.VME_Scheme__c = vme_Scheme_Objvin.Id;
                        bundlingObjvin.Asset__c = FIRST_ASSET_VIN.Id;
                        Insert bundlingObjvin;

                        /* Manufacture date Scheme */
                        //Create VME Scheme1 record for vme_Camp_Object #3
                        VME_Schemes__c vme_Scheme_Objmfg = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-20), Date.today().addDays(+20), 125, 25000, 'Parent', 'Others', '');
                        vme_Scheme_Objmfg.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Objmfg.VME_Manufacturing_Start_Date__c = Date.today().addDays(-10);
                        vme_Scheme_Objmfg.VME_Manufacturing_End_Date__c = Date.today().addDays(+10);
                        Insert vme_Scheme_Objmfg;
                        //Create Bundling 1 Object for vme_Scheme_Objmfg Derivative Based
                        VME_Bundling__c bundlingObjmfg = new VME_Bundling__c();
                        bundlingObjmfg.VME_Scheme__c = vme_Scheme_Objmfg.Id;
                        bundlingObjmfg.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObjmfg;

                        /* Market Arrival date Scheme */
                        //Create VME Scheme1 record for vme_Camp_Object #3
                        VME_Schemes__c vme_Scheme_Objmad = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-20), Date.today().addDays(+20), 125, 25000, 'Parent', 'Others', '');
                        vme_Scheme_Objmad.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Objmad.VME_Market_Arrival_Start_Date__c = Date.today().addDays(-10);
                        vme_Scheme_Objmad.VME_Market_Arrival_End_Date__c = Date.today().addDays(+10);
                        Insert vme_Scheme_Objmad;
                        //Create Bundling 1 Object for vme_Scheme_Objmad Derivative Based
                        VME_Bundling__c bundlingObjmad = new VME_Bundling__c();
                        bundlingObjmad.VME_Scheme__c = vme_Scheme_Objmad.Id;
                        bundlingObjmad.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObjmad;

                        /* Market Arrival date Scheme */
                        //Create VME Scheme1 record for vme_Camp_Object #3
                        VME_Schemes__c vme_Scheme_ObjmadLatest = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-15), Date.today().addDays(+15), 125, 25000, 'Parent', 'Others', '');
                        vme_Scheme_ObjmadLatest.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_ObjmadLatest.VME_Market_Arrival_Start_Date__c = Date.today().addDays(-10);
                        vme_Scheme_ObjmadLatest.VME_Market_Arrival_End_Date__c = Date.today().addDays(+10);
                        Insert vme_Scheme_ObjmadLatest;
                        //Create Bundling 1 Object for vme_Scheme_ObjmadLatest Derivative Based
                        VME_Bundling__c bundlingObjmadLat = new VME_Bundling__c();
                        bundlingObjmadLat.VME_Scheme__c = vme_Scheme_ObjmadLatest.Id;
                        bundlingObjmadLat.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObjmadLat;

                        /* Segment SubDivision based Scheme */
                        //Create VME Scheme1 record for vme_Camp_Object #2
                        VME_Schemes__c vme_Scheme_Objofb = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-20), Date.today().addDays(+20), 76, 12400, 'Parent', 'Others', 'Segment / SubDivision Affinity Sales');
                        vme_Scheme_Objofb.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Objofb.VME_Segment__c = 'Affinity Sales';
                        vme_Scheme_Objofb.VME_Sub_Division__c = 'Automobile Dealer';
                        Insert vme_Scheme_Objofb;
                        //Create Bundling 1 Object vme_Scheme_Objofb Derivative Based
                        VME_Bundling__c bundlingObjofb = new VME_Bundling__c();
                        bundlingObjofb.VME_Scheme__c = vme_Scheme_Objofb.Id;
                        bundlingObjofb.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObjofb;

                        /* Segment based Scheme */
                        //Create VME Scheme1 record for vme_Camp_Object #2
                        VME_Schemes__c vme_Scheme_ObjofbS = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-20), Date.today().addDays(+20), 76, 12400, 'Parent', 'Others', 'Segment / SubDivision Affinity Sales');
                        vme_Scheme_ObjofbS.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Objofb.VME_Segment__c = 'Affinity Sales';
                        vme_Scheme_Objofb.VME_Sub_Division__c = null;
                        Insert vme_Scheme_ObjofbS;
                        //Create Bundling 1 Object vme_Scheme_ObjofbS Derivative Based
                        VME_Bundling__c bundlingObjofbS = new VME_Bundling__c();
                        bundlingObjofbS.VME_Scheme__c = vme_Scheme_ObjofbS.Id;
                        bundlingObjofbS.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObjofbS;
                }
        }

        public static testMethod void idealOpportunityCase() {
                Test.startTest();
                User communityGlobalUser = [SELECT Id, Market__c FROM User WHERE email = 'admin@jlrutil.comtest' AND username = 'etadmin@ettestjlr.utiltest'];
                //getting admin user
                System.runAs(communityGlobalUser) {
                        User expectedFetchUser = VME_Sales_Link.fetchUser();
                        System.assertEquals(expectedFetchUser.Market__c, communityGlobalUser.Market__c, 'Checking for the same user\'s Market as IN');
                        List < Opportunity > oppList = [Select Id, VME_Selected_Schemes__c, VME_Selected_Scheme_Id__c, Brand__r.Name, Primary_Model_Interest__r.Name, IsClosed, StageName from Opportunity];
                        VME_Sales_Link.VME_Scheme_Wrpaper_CheckAll wrList = VME_Sales_Link.getSchemes(oppList[0].Id);
                        //System.debug(' NO product in Opportunity==> '+ wrList);
                        String messge = 'Looks like you have not attached product to opportunity. Please add product to proceed.';
                        System.assertEquals('WARNING', wrList.statusOfTransaction, 'Checking the statius of transaction where NO product on opportunity.');
                        System.assertEquals(messge, wrList.MsgOfTransactionforUser, 'Checking the message of transaction where NO product on opportunity.');
                }
                Test.stopTest();
        }

        public static testMethod void vinSalesTypefailureTest2() {
                Test.startTest();
                User communityGlobalUser = [SELECT Id, Market__c FROM User WHERE email = 'admin@jlrutil.comtest' AND username = 'etadmin@ettestjlr.utiltest'];
                //getting admin user
                System.runAs(communityGlobalUser) {
                        List < Opportunity > oppList = [Select Id, VME_Selected_Schemes__c, VME_Selected_Scheme_Id__c, Brand__r.Name, Primary_Model_Interest__r.Name, IsClosed, StageName from Opportunity];
                        Product2 derivative = [SELECT Id, Model__c, Make__c FROM Product2 WHERE ProductCode='5000217157' LIMIT 1];
                        Id pricebookId = Test.getStandardPricebookId();
                        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = derivative.Id, UnitPrice = 12500.00, IsActive = true);
                        Insert pbEntry;
                        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbEntry.Id, TotalPrice = 1 * pbEntry.UnitPrice, Quantity = 1, Brand__c = derivative.Make__c, Model__c = derivative.Model__c);
                        Insert oli;
                        VME_Sales_Link.VME_Scheme_Wrpaper_CheckAll wrList2 = VME_Sales_Link.getSchemes(oppList[0].Id);
                        String messgewrList2 = 'Looks like you have not attached product to opportunity. Please add product to proceed.';
                        System.assertEquals('WARNING', wrList2.statusOfTransaction, 'Checking the statius of transaction where NO VIN on opportunity.');
                        System.assertEquals(messgewrList2, wrList2.MsgOfTransactionforUser, 'Checking the message of transaction where NO VIN on opportunity.');

                        Asset linkedAsset = [SELECT Id, VME_Retail_Date__c, Sale_Type_Code__c, VME_TypeOfSale_Code_L2__c, Derivative__c, Model__c, Retailer_Name__c, AccountId, Derivative__r.VME_GST__c, VIN__c, (SELECT Id FROM VME_Claims__r) FROM Asset WHERE VIN__c = 'SADCA2AK3HA087201' ];
                        oli.Asset__c = linkedAsset.Id;
                        Update oli;
                        VME_Sales_Link.VME_Scheme_Wrpaper_CheckAll wrList3 = VME_Sales_Link.getSchemes(oppList[0].Id);
                        String messgewrList3 = 'Looks like VIN does not have Sale Type Code / Type of Sale Code L2. Please select an different VIN and refresh.';
                        System.assertEquals('WARNING', wrList3.statusOfTransaction, 'Checking the statius of transaction where NO Sale Type Code on VIN.');
                        System.assertEquals(messgewrList3, wrList3.MsgOfTransactionforUser, 'Checking the message of transaction where NO Sale Type Code on VIN.');

                        linkedAsset.Sale_Type_Code__c = 'RET';
                        linkedAsset.VME_Channel_Type__c = 'Private';
                        linkedAsset.VME_TypeOfSale_Code_L2__c = 'AAA';
                        Update linkedAsset;
                        VME_Sales_Link.VME_Scheme_Wrpaper_CheckAll wrList4 = VME_Sales_Link.getSchemes(oppList[0].Id);
                        String messgewrList4 = 'Congratualtions!! L3 VME Campaigns are available for selection.';
                        System.assertEquals('SUCCESS', wrList4.statusOfTransaction, 'Checking the statius of transaction where scheme reyrieve for VIN.');
                        System.assertEquals(messgewrList4, wrList4.MsgOfTransactionforUser, 'Checking the message of transaction where scheme reyrieve for VIN.');

                        String tempScheleListString = JSON.serialize(wrList4.listofWrapperSchemes);
                        List < VME_Sales_Link.VME_Campaign_Scheme_Wrapper > noSchemetoUpdate = VME_Sales_Link.updateSelectedChemes(null, oppList[0].Id,false);
                        System.assertEquals(true, noSchemetoUpdate.isEmpty(), 'No scheme to update on Opp hence return null');

                        List < VME_Sales_Link.VME_Campaign_Scheme_Wrapper > schemeWrapLIstUpdated = VME_Sales_Link.updateSelectedChemes(tempScheleListString, oppList[0].Id,true);
                        System.assertNotEquals(null, schemeWrapLIstUpdated, 'No scheme to update on Opp hence return null');

                        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbEntry.Id, TotalPrice = 1 * pbEntry.UnitPrice, Quantity = 1, Brand__c = derivative.Make__c, Model__c = derivative.Model__c);
                        Insert oli2;
                        VME_Sales_Link.VME_Scheme_Wrpaper_CheckAll wrList8 = VME_Sales_Link.getSchemes(oppList[0].Id);
                        String messgewrList8 = 'Looks like you have attached more than 1 product to opportunity. Please limit products to 1 and refresh.';
                        System.assertEquals('WARNING', wrList8.statusOfTransaction, 'Checking the statius of transaction where more than 1 OppLineIteam present on opp.');
                        System.assertEquals(messgewrList8, wrList8.MsgOfTransactionforUser, 'Checking the message of transaction where more than 1 OppLineIteam present on opp.');
                }
                Test.stopTest();
        }
        public static testMethod void vinSalesTypefailureTest4() {
                Test.startTest();
                //User communityGlobalUser = [SELECT Id, Market__c FROM User WHERE email = 'slaesLink@comUser.com' AND username = 'useret@salesLink.com'];
                User communityGlobalUser = [SELECT Id, Market__c FROM User WHERE email = 'admin@jlrutil.comtest' AND username = 'etadmin@ettestjlr.utiltest'];
                //getting community user
                System.runAs(communityGlobalUser) {
                        List < Opportunity > oppList = [Select Id, Name, VME_Selected_Schemes__c, VME_Selected_Scheme_Id__c, Brand__r.Name, Primary_Model_Interest__r.Name, IsClosed, StageName from Opportunity ORDER BY Name ASC];
                        Product2 derivative = [SELECT Id, Model__c, Make__c FROM Product2 WHERE ProductCode='5000217157' LIMIT 1];
                        Id pricebookId = Test.getStandardPricebookId();
                        PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = derivative.Id, UnitPrice = 12500.00, IsActive = true);
                        Insert pbEntry;
                        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbEntry.Id, TotalPrice = 1 * pbEntry.UnitPrice, Quantity = 1, Brand__c = derivative.Make__c, Model__c = derivative.Model__c);
                        Insert oli;
                        Asset linkedAsset = [SELECT Id, VME_Retail_Date__c, Sale_Type_Code__c, VME_TypeOfSale_Code_L2__c, Derivative__c, Model__c, Retailer_Name__c, AccountId, Derivative__r.VME_GST__c, VIN__c, (SELECT Id FROM VME_Claims__r) FROM Asset WHERE VIN__c = 'SADCA2AK3HA087201' ];
                        oli.Asset__c = linkedAsset.Id;
                        Update oli;

                        linkedAsset.Sale_Type_Code__c = 'RET';
                        linkedAsset.VME_Channel_Type__c = 'Private';
                        linkedAsset.VME_TypeOfSale_Code_L2__c = 'AAM';
                        linkedAsset.VME_Retail_Date__c = Date.today();
                        Update linkedAsset;
                        VME_Sales_Link.VME_Scheme_Wrpaper_CheckAll wrList5 = VME_Sales_Link.getSchemes(oppList[0].Id);
                        String messgewrList8 = 'Looks like the claims have been generated for attached VIN. Sales-Link has been disabled.';
                        System.assertEquals('DISABLE', wrList5.statusOfTransaction, 'Checking the status of transaction where claims has been generated and sales link for disabled.');
                        System.assertEquals(messgewrList8, wrList5.MsgOfTransactionforUser, 'Checking the message of transaction where claims has been generated and sales link for disabled.');

                        linkedAsset.Sale_Type_Code__c = 'RET';
                        linkedAsset.VME_Channel_Type__c = 'Private';
                        linkedAsset.VME_TypeOfSale_Code_L2__c = 'FAC';
                        //If an exception is thrown from the code being tested (or the test code) then the test is a fail and that is normally need to handle to pass the test class
                        //and as not all exceptions are catchable (e.g. governor limit ones) it will not even always execute.
                        //When designing code, throwing exceptions for expected conditions is not usually a good choice. 
                        //Most of what is said in articles about Java exceptions is applicable to Apex exceptions. And don't forget about try/finally.
                        try {
                                Update linkedAsset;
                                //Note the test should fail if the exception isn't thrown, hence the below code is to check that
                                System.assert(false, 'Exception expected for selected (VME) Channel Type / (VME)Type of Sale Code - L2 is not supported for the Asset');
                        } catch (Exception e) {
                                String messge = 'The selected (VME) Channel Type / (VME)Type of Sale Code - L2 is not supported for the Asset\'s Sale Type Code';
                                System.assert(e.getMessage().contains(messge), 'message=' + e.getMessage());
                        }
                        VME_Sales_Link.VME_Scheme_Wrpaper_CheckAll wrList7 = VME_Sales_Link.getSchemes(oppList[0].Id);
                        String messgewrList9 = 'Looks like the claims have been generated for attached VIN. Sales-Link has been disabled.';
                        System.assertEquals('DISABLE', wrList7.statusOfTransaction, 'Checking the status of transaction where wrong Channel Matrix Code has been given');
                        System.assertEquals(messgewrList9, wrList7.MsgOfTransactionforUser, 'Checking the message of transaction where wrong Channel Matrix Code has been given');
                        System.debug(oppList[1].Name);
                        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = oppList[1].Id, PricebookEntryId = pbEntry.Id, TotalPrice = 1 * pbEntry.UnitPrice, Quantity = 1, Brand__c = derivative.Make__c, Model__c = derivative.Model__c);
                        Insert oli2;
                        VME_Sales_Link.VME_Scheme_Wrpaper_CheckAll wrList55 = VME_Sales_Link.getSchemes(oppList[1].Id);
                        String messgewrList18 = 'Looks like you have not attached product to opportunity. Please add product to proceed.';
                        System.assertEquals('WARNING', wrList55.statusOfTransaction, 'Checking the status of transaction where claims has been generated and sales link for disabled.');
                        System.assertEquals(messgewrList18, wrList55.MsgOfTransactionforUser, 'Checking the message of transaction where claims has been generated and sales link for disabled.');
                        /* OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = oppList[2].Id, PricebookEntryId = pbEntry.Id, TotalPrice = 1 * pbEntry.UnitPrice, Quantity = 1, Brand__c = derivative.Make__c, Model__c = derivative.Model__c);
                        Insert oli3;
                        OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = oppList[2].Id, PricebookEntryId = pbEntry.Id, TotalPrice = 1 * pbEntry.UnitPrice, Quantity = 1, Brand__c = derivative.Make__c, Model__c = derivative.Model__c);
                        Insert oli4;
                        VME_Sales_Link.VME_Scheme_Wrpaper_CheckAll wrList545 = VME_Sales_Link.getSchemes(oppList[1].Id);
                        System.debug(wrList545); */

                }
                Test.stopTest();
        }
}