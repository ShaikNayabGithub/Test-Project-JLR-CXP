/*--
||  Name : VME_Planner_Controller_Test.apxc
||  Author: Sumit Kumar
||  Purpose: VME Planner controller test class to get the data from test set up.
||  Created Date : 22/04/2018
--*/
@isTest
private class VME_Planner_Controller_Test {
        public static final String PARENT_SCHEME_RECORD_TYPE_NAME = 'Parent';
        public static final String CHILD_SCHEME_RECORD_TYPE_NAME = 'Child';
        public static final Id PARENT_SCHEME_RECORD_TYPE = VME_Utility_Class.getRecordTypeId('VME_Schemes__c', PARENT_SCHEME_RECORD_TYPE_NAME);
        public static final Id CHILD_SCHEME_RECORD_TYPE = VME_Utility_Class.getRecordTypeId('VME_Schemes__c', CHILD_SCHEME_RECORD_TYPE_NAME);
        @testSetup
        public static void dataBuildUp() {
                // Given
                //create a user for login
                User testUser = VME_TestDataUtilityClass.createSalesforceUser();
                Insert testUser;
                System.runAs(testUser) {
                        //create Retailer Record
                        Account retailer = VME_TestDataUtilityClass.createRetailer();
                        Insert retailer;
                        //Create Vehicle_Specification__c data
                        Vehicle_Specification__c jaguarVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
                        Insert jaguarVehicle;
                        Vehicle_Specification__c landRoverVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Land Rover');
                        Insert landRoverVehicle;
                        //Create Product of Model Type Jaguar
                        Product2 modelProductJag = VME_TestDataUtilityClass.CreateModelProduct('F-PACE', 'R8', 'F-PACE');
                        modelProductJag.Make__c = jaguarVehicle.Id;
                        Insert modelProductJag;
                        //Create Product of Model Type Jaguar
                        Product2 modelProductJagIpace = VME_TestDataUtilityClass.CreateModelProduct('I-PACE', 'A7', 'I-PACE');
                        modelProductJagIpace.Make__c = jaguarVehicle.Id;
                        Insert modelProductJagIpace;
                        //Create Product of Derivative Type Jaguar
                        Product2 derivativeProductJag = VME_TestDataUtilityClass.CreateDerivativeProduct('F-Pace 3.0 S/C V6 AWD - Prestige Auto, Colombia V32M, R8MKS/ZL12, 2017', '5000291712', 'F-PACE');
                        derivativeProductJag.Make__c = jaguarVehicle.Id;
                        derivativeProductJag.Model__c = modelProductJag.Id;
                        Insert derivativeProductJag;
                        //Create Product of Model Type Land Rover
                        Product2 modelProductLR = VME_TestDataUtilityClass.CreateModelProduct('L494 - Range Rover Sport', 'F5', 'RANGE ROVER SPORT');
                        modelProductLR.Make__c = landRoverVehicle.Id;
                        Insert modelProductLR;
                        Test.startTest();
                        //Create QMSP Master Record
                        Campaign QMSPObj = VME_TestDataUtilityClass.init_QMSP_Record();
                        QMSPObj.Name = 'Q2 - 2019-20 - Jaguar - INDIA-F-PACE';
                        QMSPObj.VME_QMSP_Code__c = 'Q2201920JaguarINDIAFPACE';
                        QMSPObj.VME_Brand__c = jaguarVehicle.Id;
                        QMSPObj.QMSP_Model__c = modelProductJag.Id;
                        QMSPObj.VME_Adjust_P_U_Amount__c = 12500;
                        QMSPObj.VME_Adjust_volume__c = 12;
                        Insert QMSPObj;
                        //Create QMSP Master Record
                        Campaign QMSPObjIPACE = VME_TestDataUtilityClass.init_QMSP_Record();
                        QMSPObjIPACE.Name = 'Q2 - 2019-20 - Jaguar - INDIA-I-PACE';
                        QMSPObjIPACE.VME_QMSP_Code__c = 'Q2201920JaguarINDIAIPACE';
                        QMSPObjIPACE.VME_Brand__c = jaguarVehicle.Id;
                        QMSPObjIPACE.QMSP_Model__c = modelProductJagIpace.Id;
                        QMSPObjIPACE.VME_Adjust_P_U_Amount__c = 10500;
                        QMSPObjIPACE.VME_Adjust_volume__c = 19;
                        Insert QMSPObjIPACE;
                        Test.stopTest();
                        //Create VME campaign record
                        VME_Campaign__c vme_Camp_ObjectIPACE = VME_TestDataUtilityClass.vme_Camp_init();
                        vme_Camp_ObjectIPACE.VME_Brand__c = jaguarVehicle.Id;
                        vme_Camp_ObjectIPACE.VME_Model__c = modelProductJagIpace.Id;
                        vme_Camp_ObjectIPACE.QMSP_Campaign__c = QMSPObjIPACE.Id;
                        vme_Camp_ObjectIPACE.VME_Adjusted_PU_Amount__c = 1200;
                        vme_Camp_ObjectIPACE.VME_Adjusted_Volume__c = 15;
                        vme_Camp_ObjectIPACE.VME_Approved_Budget__c = 2000;
                        vme_Camp_ObjectIPACE.VME_Approved_Volume__c = 30;
                        Insert vme_Camp_ObjectIPACE;
                        //Create VME campaign record
                        VME_Campaign__c vme_Camp_Object = VME_TestDataUtilityClass.vme_Camp_init();
                        vme_Camp_Object.VME_Brand__c = jaguarVehicle.Id;
                        vme_Camp_Object.VME_Model__c = modelProductJag.Id;
                        vme_Camp_Object.QMSP_Campaign__c = QMSPObj.Id;
                        vme_Camp_Object.VME_Adjusted_PU_Amount__c = 1500;
                        vme_Camp_Object.VME_Adjusted_Volume__c = 14;
                        vme_Camp_Object.VME_Approved_Budget__c = 2500;
                        vme_Camp_Object.VME_Approved_Volume__c = 50;
                        Insert vme_Camp_Object;
                        //Create VME Scheme1 record
                        VME_Schemes__c vme_Scheme_Obj1 = VME_TestDataUtilityClass.vme_Schemes_Init();
                        vme_Scheme_Obj1.VME_Campaign__c = vme_Camp_Object.Id;
                        vme_Scheme_Obj1.VME_Retailer__c = retailer.Id;
                        vme_Scheme_Obj1.VME_External_ID__c = '';
                        Insert vme_Scheme_Obj1;
                        //Create Bundling 1 Object
                        VME_Bundling__c bundlingObj1 = new VME_Bundling__c();
                        bundlingObj1.VME_Scheme__c = vme_Scheme_Obj1.Id;
                        bundlingObj1.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObj1;
                        //Create VME campaign 2 record
                        VME_Campaign__c vme_Camp_Object2 = VME_TestDataUtilityClass.vme_Camp_init();
                        vme_Camp_Object2.VME_Brand__c = jaguarVehicle.Id;
                        vme_Camp_Object2.VME_Model__c = modelProductJag.Id;
                        vme_Camp_Object2.QMSP_Campaign__c = QMSPObj.Id;
                        vme_Camp_Object2.VME_Adjusted_PU_Amount__c = 2345;
                        vme_Camp_Object2.VME_Adjusted_Volume__c = 12;
                        vme_Camp_Object2.VME_Approved_Budget__c = 3400;
                        vme_Camp_Object2.VME_Approved_Volume__c = 45;
                        Insert vme_Camp_Object2;
                        //Create VME Scheme 2 record
                        VME_Schemes__c vme_Scheme_Obj2 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-30), Date.today().addDays(+30), 20, 200000, PARENT_SCHEME_RECORD_TYPE_NAME, 'Base', 'My18 JLR Exchange Offer');
                        vme_Scheme_Obj2.VME_Campaign__c = vme_Camp_Object2.Id;
                        vme_Scheme_Obj2.VME_External_ID__c = '';
                        Insert vme_Scheme_Obj2;
                        //Create VME Scheme 2 record
                        VME_Schemes__c vme_Scheme_Obj2R = VME_TestDataUtilityClass.vme_Schemes_Init(null, null, null, null, CHILD_SCHEME_RECORD_TYPE_NAME, 'Others', '');
                        vme_Scheme_Obj2R.VME_Campaign__c = vme_Camp_Object2.Id;
                        vme_Scheme_Obj2R.VME_Parent_Scheme__c = vme_Scheme_Obj2.Id;
                        vme_Scheme_Obj2R.VME_Retailer__c = retailer.Id;
                        vme_Scheme_Obj2R.VME_External_ID__c = '';
                        Insert vme_Scheme_Obj2R;
                        //Create Bundling 2 Object
                        VME_Bundling__c bundlingObj2 = new VME_Bundling__c();
                        bundlingObj2.VME_Scheme__c = vme_Scheme_Obj2.Id;
                        bundlingObj2.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObj2;
                        //Create VME Scheme 3 record
                        VME_Schemes__c vme_Scheme_Obj3 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.today().addDays(-30), Date.today().addDays(+30), 20, 200000, PARENT_SCHEME_RECORD_TYPE_NAME, 'Base', 'My18 JLR Exchange Offer');
                        vme_Scheme_Obj3.VME_Campaign__c = vme_Camp_Object2.Id;
                        vme_Scheme_Obj3.VME_External_ID__c = '';
                        Insert vme_Scheme_Obj3;
                        //Create VME Scheme 3 record
                        VME_Schemes__c vme_Scheme_Obj3R = VME_TestDataUtilityClass.vme_Schemes_Init(null, null, null, null, CHILD_SCHEME_RECORD_TYPE_NAME, 'Others', '');
                        vme_Scheme_Obj3R.VME_Campaign__c = vme_Camp_Object2.Id;
                        vme_Scheme_Obj3R.VME_Parent_Scheme__c = vme_Scheme_Obj3.Id;
                        vme_Scheme_Obj3R.VME_Retailer__c = retailer.Id;
                        vme_Scheme_Obj3R.VME_External_ID__c = '';
                        Insert vme_Scheme_Obj3R;
                        //Create Bundling 3 Object
                        VME_Bundling__c bundlingObj3 = new VME_Bundling__c();
                        bundlingObj3.VME_Scheme__c = vme_Scheme_Obj3.Id;
                        bundlingObj3.VME_Model_Derivative__c = derivativeProductJag.Id;
                        Insert bundlingObj3;
                        //Create VIN for vme_Scheme_Obj3
                        Asset vme_Scheme_Obj3_Claim_VIN = VME_TestDataUtilityClass.createVIN();
                        vme_Scheme_Obj3_Claim_VIN.Brand__c = jaguarVehicle.Id;
                        vme_Scheme_Obj3_Claim_VIN.Model__c = modelProductJag.Id;
                        vme_Scheme_Obj3_Claim_VIN.AccountId = retailer.Id;
                        //vme_Scheme_Obj3_Claim_VIN.Product2Id = 
                        Insert vme_Scheme_Obj3_Claim_VIN;
                        vme_Scheme_Obj3_Claim_VIN.VME_TypeOfSale_Code_L2__c = 'AAA';
                        vme_Scheme_Obj3_Claim_VIN.Sale_Type_Code__c = 'RET';
                        vme_Scheme_Obj3_Claim_VIN.VME_Retail_Date__c = Date.today();
                        Update vme_Scheme_Obj3_Claim_VIN;
                        //Create Claims from vme_Scheme_Obj3
                        VME_Claims__c vme_Scheme_Obj3_Claim = VME_TestDataUtilityClass.claims_Init(20000, 'Q2', Date.today(), Date.today(), Date.today(), Date.today(), Date.today(), Date.today(), 'April', 'IN118917', 'SUMIT JLR', 'SUMIT RETAILER', 24000, 'Approved', Date.today());
                        vme_Scheme_Obj3_Claim.VME_VIN__c = vme_Scheme_Obj3_Claim_VIN.Id;
                        vme_Scheme_Obj3_Claim.VME_Related_Scheme__c = vme_Scheme_Obj3.Id;
                        Insert vme_Scheme_Obj3_Claim;
                }
        }
        public static testMethod void positiveScenario() {
                Vehicle_Specification__c brand = [SELECT Id from Vehicle_Specification__c WHERE Name = 'Jaguar'
                        LIMIT 1
                ];
                Map < String, String > selectedFilterValues = new Map < String, String > {
                        'Region' => 'IN',
                        'Country' => 'IN',
                        'Model' => 'F-PACE (R8)',
                        'Fiscal_Year' => '2019',
                        'Brand' => 'Jaguar',
                        'Quarter' => 'Q2',
                        'VME_Type' => 'Regular',
                        'Category' => 'Retail Non-Finance'
                };
                Test.startTest();
                //calling method to cover constructor
                VME_Planner_Controller callConstuctor = new VME_Planner_Controller();
                User expectedUser = VME_Planner_Controller.fetchUser();
                User actualUser = [SELECT Id, Name from User WHERE Id = : UserInfo.getUserId()];
                System.assertEquals(expectedUser.Name, actualUser.Name, 'Checking for the same user\'s name for JLR ADMIN');
                Map < String, List < String >> getRegion_Market_ActualMap = VME_Planner_Controller.getRegion_Market_Map();
                System.assertEquals(true, getRegion_Market_ActualMap.containsKey('IN'), 'Checking the market picklist contains IN values of not');
                Map < String, List < String >> expectedBrandModelDetailsMap = VME_Planner_Controller.getBrand_Model_Map();
                List < Vehicle_Specification__c > actualBrandModelList = [SELECT Id, Name FROM Vehicle_Specification__c];
                System.assertEquals(expectedBrandModelDetailsMap.keySet().size(), actualBrandModelList.size(), 'Checking two types of brand inserted and product make__c queried are same');
                Map < String, Map < String, String >> actualMapOfFilterValues = VME_Planner_Controller.getFiltersValues();
                System.assertEquals(true, actualMapOfFilterValues.containsKey('Fiscal_Year'), 'Checking whether Fiscal_Year value has come in map or not');
                System.assertEquals(4, actualMapOfFilterValues.get('Quarter').size(), 'Checking whether Quarter key has 4 values in map or not');
                Decimal amount = 12345.00;
                Decimal actualAmount = VME_Utility_Class.convertCurrencyGBP_to_Other(amount, 'INR', 'GBP');
                List < CurrencyType > convertionRate = [SELECT Id, ConversionRate, DecimalPlaces from CurrencyType where IsActive = true AND IsoCode IN('GBP', 'INR') ORDER BY IsoCode ASC];
                //This will check for GBP and INR currency. If removed from any org then Assertion will fail.
                System.assertEquals(2, convertionRate.size(), 'CurrencyType of GBP or INR is not found in current ORG.');
                Decimal expectedAmount = amount * (convertionRate[0].ConversionRate / convertionRate[1].ConversionRate);
                expectedAmount = expectedAmount.setScale(2, RoundingMode.HALF_UP);
                System.assertEquals(expectedAmount, actualAmount, 'Checking convertion is working correct or not');

                //calling method to cover constructor
                VME_Utility_Class vup = new VME_Utility_Class();
                Set < String > pickListValuesMap = vup.getPicklistValues('VME_Campaign__c', 'VME_Category__c');
                System.assertEquals(true, pickListValuesMap.contains('retail non-finance'), 'Checking Category contains retail non-finance!');
                String expectedQuery = VME_Utility_Class.getDynamQuery('VME_Schemes__c', 'ID =: schemeId');
                System.assertEquals(true, expectedQuery.containsIgnoreCase('VME_Level_3_Description__c'), 'Checking L3 VME Campaign query has VME_Level_3_Description__c field in it');
                Map < String, String > marketCode = VME_Utility_Class.getMarketCode();
                System.assertEquals(true, marketCode.containsKey('IN'), 'Checking for IN marketCode present in above map');
                Map < String, String > brandCodeValuesMap = VME_Utility_Class.getBrandCode();
                System.debug(brandCodeValuesMap);
                System.assertEquals('X', brandCodeValuesMap.get('Jaguar'), 'Checking for Jaguar X brandCode present in above map');
                Map < String, VME_CXP_Quarter_Info__mdt > quarterCodeValuesMap = VME_Utility_Class.getQuarterInfos();
                System.assertEquals(true, quarterCodeValuesMap.containsKey('Q1'), 'Checking for Q1 code in custom metadata');
                Map < String, String > countryISOMap = VME_Utility_Class.getCountryISOInfos();
                System.assertEquals(true, countryISOMap.containsKey('IN'), 'Checking for IN country code present in above map');
                User newUser = VME_Utility_Class.fetchUser();
                User actualNewUser = [SELECT Id, Name from User WHERE Id = : UserInfo.getUserId()];
                System.assertEquals(newUser.Name, actualNewUser.Name, 'Checking for the same user\'s name for JLR ADMIN');
                Map < String, Set < String >> vmeChannelMatrixDependencyMap = VME_Utility_Class.getVMEChannelMatrixDependency();
                System.assertEquals(true, vmeChannelMatrixDependencyMap.containsKey('RET_AAA'), 'Checking brand code type and type of sale code present in this map');
                VME_Planner_Controller.VME_Planner_Wrapper masterExpectedWrapper = VME_Planner_Controller.getMasterQMSPData(selectedFilterValues, 'INR');
                System.assertEquals('SUCCESS', masterExpectedWrapper.statusOfTransaction, 'Checking the status of the master data transaction');
                List < Campaign > actualL1 = [SELECT Id FROM Campaign WHERE QMSP_Model__r.Name = 'F-PACE'
                        AND QMSP_Model__r.ProductCode = 'R8'
                ];
                System.assertEquals(actualL1.size(), masterExpectedWrapper.QMSP_Wrapper_List.size(), 'Checking the number of L1 QMSP data fetching in master query');
                Test.stopTest();
        }
        public static testMethod void negativeScenario() {
                Vehicle_Specification__c brand = [SELECT Id from Vehicle_Specification__c WHERE Name = 'Jaguar'
                        LIMIT 1
                ];
                Campaign updateCampaign = [Select Id FROM Campaign LIMIT 1];
                Update updateCampaign;
                Map < String, String > selectedFilterValues = new Map < String, String > {
                        'Region' => 'IN',
                        'Country' => 'IN',
                        'Model' => 'I-PACE',
                        'Fiscal_Year' => '2019',
                        'Brand' => 'Jaguar',
                        'Quarter' => 'All_Quarter',
                        'VME_Type' => 'Select_VME-Type',
                        'Category' => 'Select_Category'
                };
                Test.startTest();
                VME_Planner_Controller.VME_Planner_Wrapper masterExpectedWrapper = VME_Planner_Controller.getMasterQMSPData(selectedFilterValues, 'INR');
                System.assertEquals('SUCCESS', masterExpectedWrapper.statusOfTransaction, 'Checking the status of the master data transaction');
                List < Campaign > actualL1 = [SELECT Id FROM Campaign WHERE QMSP_Model__r.Name = 'I-PACE'];
                System.assertEquals(actualL1.size(), masterExpectedWrapper.QMSP_Wrapper_List.size(), 'Checking the number of L1 QMSP data fetching in master query');
                VME_Schemes__c baseScheme = [SELECT Id FROM VME_Schemes__c WHERE RecordTypeId = : PARENT_SCHEME_RECORD_TYPE LIMIT 1];
                List < VME_Schemes__c > expectedRTL3 = VME_Planner_Controller.getMyRetailerScheme(baseScheme.Id);
                List < VME_Schemes__c > actualRTL3 = [SELECT Id FROM VME_Schemes__c WHERE VME_Parent_Scheme__c = : baseScheme.Id];
                System.assertEquals(expectedRTL3.size(), actualRTL3.size(), 'Checking for retailer based scheme for base scheme');
                List < VME_Bundling__c > expectedBundlingList = VME_Planner_Controller.getMyBundlingScheme(baseScheme.Id);
                List < VME_Bundling__c > actualBundlingList = [SELECT Id FROM VME_Bundling__c WHERE VME_Scheme__c = : baseScheme.Id];
                System.assertEquals(expectedBundlingList.size(), actualBundlingList.size(), 'Checking for bundling for base scheme');
                Test.stopTest();
        }
        public static testMethod void exceptionCoverScenario() {
                Map < String, String > selectedFilterValues = new Map < String, String > {
                        'Region' => 'IN',
                        'Country' => 'IN',
                        'Model' => 'F-PACE (R8)',
                        'Fiscal_Year' => '2019',
                        'Brand' => 'Jaguar',
                        'Quarter' => 'Q2',
                        'VME_Type' => 'VME_Type',
                        'Category' => 'Select_Category'
                };
                Test.startTest();
                VME_Planner_Controller.VME_Planner_Wrapper masterExpectedWrapper = VME_Planner_Controller.getMasterQMSPData(selectedFilterValues, 'INR');
                System.assertEquals('ERROR', masterExpectedWrapper.statusOfTransaction, 'Checking the status of the master data transaction');
                //checking negative exception scenario hence list size be zero.
                System.assertEquals(0, masterExpectedWrapper.QMSP_Wrapper_List.size(), 'Checking the number of L1 QMSP data fetching in master query');
                Test.stopTest();
        }
}