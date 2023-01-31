/*--
||      Name : VME_GenerateClaimsTriggerHandler_Test.apxc
||      Created By: Sumit Kumar @Marlabs Private Limited
||      Purpose : This will have the unit test logic of Channel Martrix Calculation and Sales Link , on top Claim generation class coverage
||      Created Date : 21/5/2016
||      Modified By:<Your Name>
||      Modified Date :<Date>
||      Reason :<Reason>
--*/
@isTest
private class VME_GenerateClaimsTriggerHandler_Test {
    public static final String FIRST_ASSET = 'SADCA2AK3HA087201';
    public static final String SECOND_ASSET = 'SADCA2AK3HA087202';
    public static final String THIRD_ASSET = 'SADCA2AK3HA087203';
    @testSetup static void itShould() {
        // Given
        List < Account > accountList = new List < Account > ();
        List < Vehicle_Specification__c > vehicleSpecList = new List < Vehicle_Specification__c > ();
        List < Product2 > prodList = new List < Product2 > ();
        List < opportunity > oppList = new List < opportunity > ();
        List < Asset > asstList = new List < Asset > ();
        List < OpportunityLineItem > lineItemsList = new List < OpportunityLineItem > ();
        List<VME_Campaign__c> vmeCampList =new List<VME_Campaign__c>();
        List<VME_Schemes__c> parentSchList =new List<VME_Schemes__c>();
        List<VME_Schemes__c> childSchList =new List<VME_Schemes__c>();
        List<VME_Bundling__c> bundelingList =new List<VME_Bundling__c>();
        //create a user for login
        User testUser = VME_TestDataUtilityClass.createSalesforceUser();
        Insert testUser;
        System.runAs(testUser) {
            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 24 ' +  Limits.getQueries());
            //create Retailer Record
            Account retailer = VME_TestDataUtilityClass.createRetailer();
            retailer.Primary_Dealer_Code__c = 'IN11801';
            //Insert retailer;
            accountList.add(retailer);
            //create Retailer Record
            Account retailer2 = VME_TestDataUtilityClass.createRetailerByValue('Ace Perkins, Pune', '8877665544', 'IN', 'Jaguar', 'Trading', 'Dealer', '10203', '1143874', 'Legal Entity (Dealer Group)', 'IN', '11809');
            retailer.Primary_Dealer_Code__c = 'IN11809';
            //Insert retailer2;
            accountList.add(retailer2);
            //create Customer/Indivisual Record
            Account customer = VME_TestDataUtilityClass.createCustomer();
            customer.Alternative_Key__c = 'IN1143874';
            //customer.Preferred_Sales_Retailer__c = retailer.Id;
            accountList.add(customer);
            //Inserting account List
            Insert accountList;
            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 45 ' +  Limits.getQueries());
            //Create Vehicle_Specification__c data MAke Type
            Vehicle_Specification__c jaguarVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
            vehicleSpecList.add(jaguarVehicle);
            Vehicle_Specification__c landRoverVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Land Rover');
            vehicleSpecList.add(landRoverVehicle); 
            insert vehicleSpecList;
               
            //Create Vehicle_Specification__c data Model Type
            Vehicle_Specification__c jaguarVehicleModel = VME_TestDataUtilityClass.BuildVehicleModel('XF', 'V3');
            jaguarVehicleModel.Make__c = vehicleSpecList[0].Id;
            insert jaguarVehicleModel;

            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 61 ' +  Limits.getQueries());
            //Create Product of Model Type Jaguar
            Product2 modelProductJag = VME_TestDataUtilityClass.CreateModelProduct('XF', 'V3', '  XF');
            modelProductJag.Make__c = vehicleSpecList[0].Id;
            insert modelProductJag;
            //Create Product of Derivative Type Jaguar
            Product2 derivativeProductJag = VME_TestDataUtilityClass.CreateDerivativeProduct('XF (X250) Facelift 2200 Luxury Automatic Singapore', '5000217157', 'XF');
            derivativeProductJag.Make__c = vehicleSpecList[0].Id;
            derivativeProductJag.Model__c = modelProductJag.Id;
            derivativeProductJag.Engine_Name_Alternative__c = '2.2 i4 Diesel';
            derivativeProductJag.Model_Year_Alternative__c = '2015';
            prodList.add(derivativeProductJag);
            //Create Product of Derivative Type Jaguar 2
            Product2 derivativeProductJag2 = VME_TestDataUtilityClass.CreateDerivativeProduct('XF (X250) Facelift 2000 Premium Luxury Automatic', '5000177846', 'XF');
            derivativeProductJag2.Make__c = vehicleSpecList[0].Id;
            derivativeProductJag2.Model__c = modelProductJag.Id;
            derivativeProductJag2.Engine_Name_Alternative__c = '2.0 i4 Petrol';
            derivativeProductJag2.Model_Year_Alternative__c = '2013';
            prodList.add(derivativeProductJag2);

            insert prodList;
            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 82 ' +  Limits.getQueries());
            //create opportunity for the Customer
            Opportunity opp = VME_TestDataUtilityClass.createDeal('(SOCH Apparels Pvt Ltd)-', 'Contacted', 'OSA Post Approval DMS', Date.today().addDays(-15), 'Phone-in', 950000000, Date.today().addDays(-7));
            opp.AccountId = accountList[2].Id; //customer.Id;
            opp.Brand__c = vehicleSpecList[0].Id;
            opp.Primary_Model_Interest__c = jaguarVehicleModel.Id;
            opp.VME_Trade_in_Type__c = 'Exchange JLR to JLR';
            insert opp;
            Opportunity opp1 = VME_TestDataUtilityClass.createDeal('(SOCH Apparels Pvt Ltd)-', 'Contacted', 'OSA Post Approval DMS', Date.today().addDays(-15), 'Phone-in', 950000000, Date.today().addDays(-7));
            opp1.AccountId = accountList[2].Id; //customer.Id;
            opp1.Brand__c = vehicleSpecList[0].Id;
            opp1.Primary_Model_Interest__c = jaguarVehicleModel.Id;
            opp1.VME_Trade_in_Type__c = 'Exchange JLR to JLR';
            insert opp1;

            // This is how we get the Standard PriceBook Id.  Prior to Summer '14, we needed
            // to use SeeAllData=true, so this is a big improvement
            Id pricebookId = Test.getStandardPricebookId();
            //Create your pricebook entry
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodList[0].Id, UnitPrice = 12500.00, IsActive = true);
            Insert pbEntry;

            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 113 ' +  Limits.getQueries());
            Test.startTest();
            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 116 ' +  Limits.getQueries());
            //Create VIN for vme_Scheme_Obj3
            Asset FIRST_ASSET_VIN = VME_TestDataUtilityClass.createVIN(FIRST_ASSET, '', 95000000, 105000000, 'New', 'Created');
            FIRST_ASSET_VIN.Brand__c = vehicleSpecList[0].Id;
            FIRST_ASSET_VIN.Model__c = modelProductJag.Id;
            FIRST_ASSET_VIN.Derivative__c = prodList[0].Id;
            FIRST_ASSET_VIN.AccountId = accountList[2].Id; //customer.Id;
            FIRST_ASSET_VIN.Retailer_Name__c = accountList[0].Id; //retailer.Id;
            FIRST_ASSET_VIN.Product2Id = prodList[0].Id;
            FIRST_ASSET_VIN.Sale_Type_Code__c = 'OUV';
            FIRST_ASSET_VIN.VME_TypeOfSale_Code_L2__c = 'CAH';
            FIRST_ASSET_VIN.VME_Retail_Date__c = Date.today();
            insert FIRST_ASSET_VIN;
           
            OpportunityLineItem oli = new OpportunityLineItem(Asset__c = FIRST_ASSET_VIN.Id, OpportunityId = opp.Id, PricebookEntryId = pbEntry.Id, TotalPrice = 1 * pbEntry.UnitPrice, Quantity = 1, Brand__c = vehicleSpecList[0].Id, Model__c = modelProductJag.Id);
            lineItemsList.add(oli);
            //Create VIN for vme_Scheme_Obj3
            Asset SECOND_ASSET_VIN = VME_TestDataUtilityClass.createVIN(SECOND_ASSET, '', 95000000, 105000000, 'New', 'Created');
            SECOND_ASSET_VIN.Brand__c = vehicleSpecList[0].Id;
            SECOND_ASSET_VIN.Model__c =modelProductJag.Id;
            SECOND_ASSET_VIN.Derivative__c = prodList[0].Id;
            SECOND_ASSET_VIN.Retailer_Name__c = accountList[0].Id; //retailer.Id;
            SECOND_ASSET_VIN.AccountId = accountList[2].Id; //customer.Id;
            SECOND_ASSET_VIN.Product2Id = prodList[0].Id;
            insert SECOND_ASSET_VIN;
            //create your opportunity line item.  This assumes you already have an opportunity created, called opp

            OpportunityLineItem oli1 = new OpportunityLineItem(Asset__c = SECOND_ASSET_VIN.Id, OpportunityId = opp1.Id, PricebookEntryId = pbEntry.Id, TotalPrice = 1 * pbEntry.UnitPrice, Quantity = 1, Brand__c = vehicleSpecList[0].Id, Model__c = modelProductJag.Id);
            lineItemsList.add(oli1);
            insert lineItemsList;
            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 141 ' +  Limits.getQueries());
            //Create QMSP Master Record
            Campaign QMSPObj = VME_TestDataUtilityClass.init_QMSP_Record();
            QMSPObj.Name = 'Q2 - 2019-20 - Jaguar - XF - INDIA';
            QMSPObj.VME_Brand__c = vehicleSpecList[0].Id;
            QMSPObj.QMSP_Model__c = modelProductJag.Id;
            Insert QMSPObj;
            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 159 ' +  Limits.getQueries());
            Test.stopTest();
            //Create VME campaign record //VME-CMP-0000000003
            VME_Campaign__c vme_Camp_Object = VME_TestDataUtilityClass.vme_Camp_init('Regular', 15000, 'IN', 'Q2', Date.today().addDays(-30), Date.today().addDays(+30));
            vme_Camp_Object.VME_Brand__c = vehicleSpecList[0].Id;
            vme_Camp_Object.VME_Model__c = modelProductJag.Id;
            vme_Camp_Object.QMSP_Campaign__c = QMSPObj.Id;
            vme_Camp_Object.VME_Sub_Category__c = 'Trade-In Support';
            vme_Camp_Object.VME_Country_ISO_Code__c = 'IN';
            vme_Camp_Object.VME_Country__c = 'India';
            vme_Camp_Object.VME_Fiscal_Year__c = String.valueOf(Date.today().year());
            vme_Camp_Object.VME_External_ID__c = 'VJ20BE02RRFFI2R81258307';
            vme_Camp_Object.VME_Category__c = 'Retail Non-Finance';
            vme_Camp_Object.VME_Sub_Category__c = 'Cash Programmes';
            vme_Camp_Object.VME_Approved_Volume__c = 124;
            vme_Camp_Object.VME_Approved_Budget__c = 500000;
            vme_Camp_Object.VME_Adjusted_PU_Amount__c = 500000;
            vmeCampList.add(vme_Camp_Object);

            //Create VME campaign record //VME-CMP-0000000607
            VME_Campaign__c vme_Camp_Object2 = VME_TestDataUtilityClass.vme_Camp_init('Tactical', 20000, 'IN', 'Q2', Date.today().addDays(-28), Date.today().addDays(+25));
            vme_Camp_Object2.VME_Brand__c = jaguarVehicle.Id;
            vme_Camp_Object2.VME_Model__c = modelProductJag.Id;
            vme_Camp_Object2.QMSP_Campaign__c = QMSPObj.Id;
            vme_Camp_Object2.VME_Country_ISO_Code__c = 'IN';
            vme_Camp_Object2.VME_Country__c = 'India';
            vme_Camp_Object2.VME_Fiscal_Year__c = String.valueOf(Date.today().year());
            //vme_Camp_Object2.VME_Submit_Claim_Within_X_Days__c = 30;
            vme_Camp_Object2.VME_External_ID__c = 'VJ20BE02RRFFI2R81258301';
            vme_Camp_Object2.VME_Category__c = 'Tactical Programme';
            vme_Camp_Object2.VME_Sub_Category__c = 'Volume Related Bonus';
            vme_Camp_Object2.VME_Approved_Volume__c = 124;
            vme_Camp_Object2.VME_Approved_Budget__c = 600000;
            vme_Camp_Object2.VME_Adjusted_PU_Amount__c = 600000;
            vmeCampList.add(vme_Camp_Object2);

              //Create VME campaign record //VME-CMP-0000000062
              VME_Campaign__c vme_Camp_Object3 = VME_TestDataUtilityClass.vme_Camp_init('Discretionary', 29000, 'IN', 'Q2', Date.today().addDays(-23), Date.today().addDays(+27));
              vme_Camp_Object3.VME_Brand__c = jaguarVehicle.Id;
              vme_Camp_Object3.VME_Model__c = modelProductJag.Id;
              vme_Camp_Object3.QMSP_Campaign__c = QMSPObj.Id;
              vme_Camp_Object3.VME_Country_ISO_Code__c = 'IN';
              vme_Camp_Object3.VME_Country__c = 'India';
              vme_Camp_Object3.VME_Fiscal_Year__c = String.valueOf(Date.today().year());
              // vme_Camp_Object3.VME_Submit_Claim_Within_X_Days__c = 30;
              vme_Camp_Object3.VME_External_ID__c = 'VJ20BE02RRFFI2R81258306';
              vme_Camp_Object3.VME_Category__c = 'Discretionary Support';
              vme_Camp_Object3.VME_Sub_Category__c = 'Discretionary';
              vme_Camp_Object3.VME_Approved_Volume__c = 124;
              vme_Camp_Object3.VME_Approved_Budget__c = 500000;
              vme_Camp_Object3.VME_Adjusted_PU_Amount__c = 500000;
              // vme_Camp_Object3.VME_Submit_Claim_Within_X_Days__c = 30;
              vmeCampList.add(vme_Camp_Object3);

              insert  vmeCampList;

            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 177 ' +  Limits.getQueries());
            //Create VME Scheme1 record for vme_Camp_Object #1
            VME_Schemes__c vme_Scheme_Obj1 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 69, 25000, 'Parent', 'Base', '');
            vme_Scheme_Obj1.VME_Campaign__c = vmeCampList[0].Id;
            parentSchList.add(vme_Scheme_Obj1);
            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 183 ' +  Limits.getQueries());
            //Create Bundling 1 Object for vme_Scheme_Obj1 Model Based
           
        //Create VME Scheme1 record for vme_Camp_Object #2
            VME_Schemes__c vme_Scheme_Obj2 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 76, 12400, 'Parent', 'Others', 'Exchange JLR to JLR');
            vme_Scheme_Obj2.VME_Campaign__c = vmeCampList[0].Id;
            vme_Scheme_Obj2.VME_Trade_In__c = 'Exchange JLR to JLR';
            parentSchList.add(vme_Scheme_Obj2);
        
            //Create VME Scheme1 record for vme_Camp_Object #2
            VME_Schemes__c vme_Scheme_Obj2Mfg = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 76, 12400, 'Parent', 'Others', 'Mfg sept to August 18');
            vme_Scheme_Obj2Mfg.VME_Campaign__c = vmeCampList[0].Id;
            parentSchList.add(vme_Scheme_Obj2Mfg);

            //Create VME Scheme1 record for vme_Camp_Object #3
            VME_Schemes__c vme_Scheme_Obj3 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 125, 24000, 'Parent', 'Others', 'Exchange Non Premium');
            vme_Scheme_Obj3.VME_Campaign__c = vmeCampList[0].Id;
            parentSchList.add(vme_Scheme_Obj3);

             //Create VME Scheme1 record for vme_Camp_Object #3
             VME_Schemes__c vme_Scheme_Obj4 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 125, 25000, 'Parent', 'Others', 'Exchange Non Premium');
             vme_Scheme_Obj4.VME_Campaign__c = vmeCampList[0].Id;
             parentSchList.add(vme_Scheme_Obj4);

            //Create VME Scheme1 record for vme_Camp_Object2 #1
            VME_Schemes__c vme_Scheme_Obj22 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 69, 26000, 'Parent', 'Base', '');
            vme_Scheme_Obj22.VME_Campaign__c = vmeCampList[1].Id;
            parentSchList.add(vme_Scheme_Obj22);

              //Create VME Scheme1 record for vme_Camp_Object2 #2
              VME_Schemes__c vme_Scheme_Obj2222 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 76, 27000, 'Parent', 'Others', 'MY18 Jan - Sept Mfd Stock');
              vme_Scheme_Obj2222.VME_Campaign__c = vmeCampList[1].Id;
              parentSchList.add(vme_Scheme_Obj2222);

         //Create VME Scheme1 record for vme_Camp_Object2 #3
            VME_Schemes__c vme_Scheme_Obj222 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 69, 28000, 'Parent', 'Base', '');
            vme_Scheme_Obj222.VME_Campaign__c = vmeCampList[1].Id;
            parentSchList.add(vme_Scheme_Obj222);

            //Create VME Scheme1 record for vme_Camp_Object3 #1
            VME_Schemes__c vme_Scheme_Obj33 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 69, 30000, 'Parent', 'Base', '');
            vme_Scheme_Obj33.VME_Campaign__c = vmeCampList[2].Id;
            parentSchList.add(vme_Scheme_Obj33);

             //Create VME Scheme1 record for vme_Camp_Object2 #3
             VME_Schemes__c vme_Scheme_Obj333 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-22), Date.today().addDays(+22), 69, 31000, 'Parent', 'Base', '');
             vme_Scheme_Obj333.VME_Campaign__c = vmeCampList[1].Id;
             parentSchList.add(vme_Scheme_Obj333);

             insert parentSchList;

             opp.VME_Selected_Schemes__c = parentSchList[6].Name + '-' + parentSchList[6].VME_PU_Amount__c;
             opp.VME_Selected_Scheme_Id__c = parentSchList[6].Id;
             //Updating Opportunity for Sales LInk selection.
             Update opp;

                /*All the Child Scheme insertion */
              //Create VME Scheme1R record for vme_Camp_Object #2
            VME_Schemes__c vme_Scheme_Obj2R = VME_TestDataUtilityClass.vme_Schemes_Init(null, null, 0, 0, 'Child', 'Others', '');
            vme_Scheme_Obj2R.VME_Campaign__c = vmeCampList[0].Id;
            vme_Scheme_Obj2R.VME_Parent_Scheme__c = parentSchList[1].Id;
            vme_Scheme_Obj2R.VME_Retailer__c = accountList[0].Id; //retailer.Id;
            childSchList.add(vme_Scheme_Obj2R);

              //Create VME Scheme1 record for vme_Camp_Object #5
              VME_Schemes__c vme_Scheme_Obj5 = VME_TestDataUtilityClass.vme_Schemes_Init(null, null, 0, 0, 'Child', 'Others', '');
              vme_Scheme_Obj5.VME_Campaign__c = vmeCampList[0].Id;
              vme_Scheme_Obj5.VME_Parent_Scheme__c = parentSchList[1].Id;
              vme_Scheme_Obj5.VME_Retailer__c = accountList[0].Id; //retailer.Id;
              childSchList.add( vme_Scheme_Obj5);

              //Create VME Scheme1 record for vme_Camp_Object
              VME_Schemes__c vme_Scheme_Obj6 = VME_TestDataUtilityClass.vme_Schemes_Init(null, null, 0, 0, 'Child', 'Others', '');
              vme_Scheme_Obj6.VME_Campaign__c = vmeCampList[0].Id;
              vme_Scheme_Obj6.VME_Parent_Scheme__c = parentSchList[3].Id;
              vme_Scheme_Obj6.VME_Retailer__c = accountList[1].Id; //retailer2.Id;
              childSchList.add(vme_Scheme_Obj6);
              insert childSchList;
              
            VME_Bundling__c bundlingObj1 = new VME_Bundling__c();
            bundlingObj1.VME_Scheme__c = parentSchList[0].Id;
            bundlingObj1.VME_Model_Derivative__c = modelProductJag.Id;
            bundelingList.add(bundlingObj1); 
            
            //Create Bundling 1 Object vme_Scheme_Obj2 Derivative Based
            VME_Bundling__c bundlingObj2 = new VME_Bundling__c();
            bundlingObj2.VME_Scheme__c = parentSchList[1].Id;
            bundlingObj2.VME_Model_Derivative__c = modelProductJag.Id;
            bundelingList.add(bundlingObj2);

            //Create Bundling 1 Object vme_Scheme_Obj2Mfg Derivative Based
            VME_Bundling__c bundlingObjmfg = new VME_Bundling__c();
            bundlingObjmfg.VME_Scheme__c = parentSchList[2].Id;
            bundlingObjmfg.VME_Model_Derivative__c = prodList[0].Id;
            bundelingList.add(bundlingObjmfg);
           
            //Create Bundling 1 Object for vme_Scheme_Obj3 Derivative Based
            VME_Bundling__c bundlingObj3 = new VME_Bundling__c();
            bundlingObj3.VME_Scheme__c = parentSchList[3].Id;
            bundlingObj3.VME_Model_Derivative__c = prodList[0].Id;
            bundelingList.add( bundlingObj3);
           
            //Create Bundling 1 Object for vme_Scheme_Obj4 Derivative Based
            VME_Bundling__c bundlingObj4 = new VME_Bundling__c();
            bundlingObj4.VME_Scheme__c = parentSchList[4].Id;
            bundlingObj4.VME_Model_Derivative__c = prodList[0].Id;
            bundelingList.add( bundlingObj4);
            
            //Create Bundling 1 Object for vme_Scheme_Obj22 Model Based
            VME_Bundling__c bundlingObj11 = new VME_Bundling__c();
            bundlingObj11.VME_Scheme__c = parentSchList[5].Id;
            bundlingObj11.VME_Model_Derivative__c = modelProductJag.Id;
            bundelingList.add(bundlingObj11);
          
            //Create Bundling 1 Object vme_Scheme_Obj2222 Derivative Based
            VME_Bundling__c bundlingObj21 = new VME_Bundling__c();
            bundlingObj21.VME_Scheme__c = parentSchList[6].Id;
            bundlingObj21.VME_Model_Derivative__c = prodList[0].Id;
            bundelingList.add(bundlingObj21);
          
            //Create Bundling 1 Object for vme_Scheme_Obj222 Model Based
            VME_Bundling__c bundlingObj22 = new VME_Bundling__c();
            bundlingObj22.VME_Scheme__c = parentSchList[1].Id;
            bundlingObj22.Asset__c = SECOND_ASSET_VIN.Id;
            bundelingList.add(bundlingObj22);

            //Create Bundling 1 Object for vme_Scheme_Obj222 Model Based
            VME_Bundling__c bundlingObj222 = new VME_Bundling__c();
            bundlingObj222.VME_Scheme__c = parentSchList[7].Id;
            bundlingObj222.Asset__c = SECOND_ASSET_VIN.Id;
            bundelingList.add(bundlingObj222);
          
            //Create Bundling 1 Object for vme_Scheme_Obj33 Model Based
            VME_Bundling__c bundlingObj33 = new VME_Bundling__c();
            bundlingObj33.VME_Scheme__c = parentSchList[8].Id;
            bundlingObj33.Asset__c = FIRST_ASSET_VIN.Id;
            bundelingList.add(bundlingObj33);

            insert bundelingList;

            //System.debug(('Total Number of SOQL Queries allowed in this apex code context: 323 ' +  Limits.getQueries());
        }
    }
    public static testMethod void postiveScenario() {
        User testUser = [SELECT Id, Market__c, Country_ISO_Code__c, Name from User WHERE Name = 'JLR ADMIN'
            AND username = 'etadmin@ettestjlr.utiltest'
            LIMIT 1
        ];
        System.runAs(testUser) {
            system.debug('****outside start ' + Limits.getQueries());
            Test.startTest();
            system.debug('****inside start ' + Limits.getQueries());
            List < Asset > assetToUpdate = new List < Asset > ();
            assetToUpdate = [SELECT AccountId, VME_Retail_Date__c, Retailer_Name__c, Brand__c, Common_Sale_Type__c, CurrencyIsoCode, Derivative__c, Handover_Date__c, Id, Manufacture_Year__c, Model_Year__c, Model__c, Name, ParentId, Product2Id, ProductCode, Sale_Type_Code__c, Status, Vehicle_Initial_Registration_Date__c, VIN__c FROM Asset];

            //Claim Reversal Test class Coverage
            VME_ClaimReversalCtrl.processDetails transDetails = VME_ClaimReversalCtrl.getAssetDetails(assetToUpdate[1].Id);
            System.assertEquals(transDetails.message, 'Please fill the Retail Date to generate the claims.', 'Checking retail date is missing');

            VME_ClaimReversalCtrl.processDetails transDetails1 = VME_ClaimReversalCtrl.getAssetDetails(assetToUpdate[0].Id);
            System.assertEquals(transDetails1.message, 'Please fill the Sale Type Code/Channel Type/Type of Sale Code - L2 to generate the claims.', 'Checking fields is missing');
            assetToUpdate[0].VME_Channel_Type__c = 'JLR';
            update assetToUpdate[0];

            VME_ClaimReversalCtrl.processDetails transDetails2 = VME_ClaimReversalCtrl.getAssetDetails(assetToUpdate[0].Id);
            System.assertEquals(transDetails2.message, 'CONFIRMATION', 'Checking  existing claims are not there.');

            assetToUpdate[1].Sale_Type_Code__c = 'RET';
            assetToUpdate[1].VME_TypeOfSale_Code_L2__c = 'AAA';
            assetToUpdate[1].VME_Retail_Date__c = Date.today();
            assetToUpdate[1].VME_Channel_Type__c = 'Private';
            System.debug(assetToUpdate[1].Name);
            update assetToUpdate[1];
            VME_ClaimReversalCtrl.getAssetDetails(assetToUpdate[1].Id);
            List < VME_Claims__c > vmeClaims = [Select id, VME_Status__c from VME_Claims__c where VME_VIN__c =: assetToUpdate[1].Id];
            System.assertNotEquals(vmeClaims, null, 'claims are already created with Trigger process');
            System.assertEquals(vmeClaims[0].VME_Status__c, 'Generated', 'claims are created');

            VME_ClaimReversalCtrl.processDetails transDetails3 = VME_ClaimReversalCtrl.regenerateAllClaims(assetToUpdate[1]);
            System.assertEquals(transDetails3.message, 'There is no update required on the claims.', 'No changes in the claims.');

            delete vmeClaims;
            VME_ClaimReversalCtrl.processDetails transDetails5 = VME_ClaimReversalCtrl.regenerateAllClaims(assetToUpdate[1]);
            System.assertEquals(transDetails5.message, 'Claims are regenerated successfully.', 'Claims are regenerated successfully.');


            VME_ClaimReversalCtrl.processDetails transDetails4 = VME_ClaimReversalCtrl.regenerateAllClaims(assetToUpdate[0]);
            System.assertEquals(transDetails4.message, 'Your selection doesn\'t  yielding any claim generation.Please change and try again.', 'Claims are not generated.');

            system.debug('****inside stop ' + Limits.getQueries());
            Test.stopTest();
            system.debug('****outside stop ' + Limits.getQueries());
            VME_ClaimReversalCtrl.loggedInFormat();
        }
    }

    public static testMethod void postiveScenario1() {
        User testUser = [SELECT Id, Market__c, Country_ISO_Code__c, Name from User WHERE Name = 'JLR ADMIN'
            AND username = 'etadmin@ettestjlr.utiltest'
            LIMIT 1
        ];
        System.runAs(testUser) {
            system.debug('****outside start ' + Limits.getQueries());
            Test.startTest();
            List < Asset > assetToUpdate = new List < Asset > ();
            assetToUpdate = [SELECT AccountId, Retailer_Name__c, Brand__c, Common_Sale_Type__c, CurrencyIsoCode, Derivative__c, Handover_Date__c, Id, Manufacture_Year__c, Model_Year__c, Model__c, Name, ParentId, Product2Id, ProductCode, Sale_Type_Code__c, Status, Vehicle_Initial_Registration_Date__c, VIN__c FROM Asset];
            List < OpportunityLineItem > lineItems = [Select id from OpportunityLineItem where Asset__c =: assetToUpdate[0].Id];
            delete lineItems;
            VME_ClaimReversalCtrl.processDetails transDetails = VME_ClaimReversalCtrl.getAssetDetails(assetToUpdate[0].Id);
            System.assertEquals(transDetails.message, 'Please attach  VIN with an opportunity generate the claims.', 'Checking opportunity is attached with VIN or not.');

            VME_ClaimReversalCtrl.processDetails transDetails1 = VME_ClaimReversalCtrl.getAssetDetails('Test');
            System.assertEquals(transDetails1.variantDetails, 'error', 'Exception Occurs');

            assetToUpdate[1].Sale_Type_Code__c = 'RET';
            assetToUpdate[1].VME_TypeOfSale_Code_L2__c = 'AAA';
            assetToUpdate[1].VME_Retail_Date__c = Date.today();
            assetToUpdate[1].VME_Channel_Type__c = 'Private';
            update assetToUpdate[1];

            List < VME_Claims__c > vmeClaims = [Select id, VME_Status__c from VME_Claims__c where VME_VIN__c =: assetToUpdate[1].Id];
            System.assertNotEquals(vmeClaims, null, 'claims are already created with Trigger process');
            System.assertEquals(vmeClaims[0].VME_Status__c, 'Generated', 'claims are created');

            vmeClaims[0].VME_Amount__c = 799999;
            vmeClaims[1].VME_Amount__c = 799999;
            update vmeClaims;

            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(vmeClaims[0].Id);
            req1.setProcessDefinitionNameOrId('VME_Claim_Level1_Approval_Process');
            req1.setComments('Submitted');
            req1.setSubmitterId(testUser.Id);
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);

            VME_ClaimReversalCtrl.processDetails transDetails2 = VME_ClaimReversalCtrl.regenerateAllClaims(assetToUpdate[1]);
            System.assertEquals(transDetails2.message, 'Claims are regenerated successfully.', 'Claims are regenerated successfully.');

            List < VME_Schemes__c > schList = [Select id, VME_End_Date__c from VME_Schemes__c];
            for (VME_Schemes__c sch: schList) {
                sch.VME_End_Date__c = Date.today().addDays(-2);
            }

            update schList;

            VME_ClaimReversalCtrl.processDetails transDetails3 = VME_ClaimReversalCtrl.regenerateAllClaims(assetToUpdate[1]);
            System.assertEquals(transDetails3.message, 'Claims are regenerated successfully.', 'Claims are regenerated successfully.');

            List < VME_Schemes__c > schList1 = [Select id, VME_End_Date__c, VME_Trade_In__c from VME_Schemes__c where VME_Trade_In__c != null];
            schList1[0].VME_End_Date__c = Date.today().addDays(4);
            update schList1;
            VME_ClaimReversalCtrl.processDetails transDetails4 = VME_ClaimReversalCtrl.regenerateAllClaims(assetToUpdate[1]);
            System.assertEquals(transDetails4.message, 'Claims are regenerated successfully.', 'Claims are regenerated successfully.');

            system.debug('****inside stop ' + Limits.getQueries());
            Test.stopTest();
            system.debug('****outside stop ' + Limits.getQueries());
        }
    }

}