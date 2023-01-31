/*****************************************************
 *  Name        : VME_Model_Adjustment_Controller_Test
 *  
 *  Company     : ETMarlabs
 *    
 *  Purpose     : Test class for model adjustment
 * 
 *  Developer   : Tejashree J
 *
 *  Created Date: 18/04/2019
 *
 *  Modified    : 09/07/2019 BY Tejashree J
 *****************************************************/
@isTest
private class VME_Model_Adjustment_Controller_Test {
        public static Vehicle_Specification__c brand_init;
        public static Product2 prod;
        public static Campaign qmspRec;
        public static VME_Campaign__c vmeCamp;
        @testSetup public static void instantiation() {
                brand_init = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
                insert brand_init;
                prod = VME_TestDataUtilityClass.CreateModelProduct('X760 Jaguar XE', 'X7', 'XE');
                insert prod;
                qmspRec = VME_TestDataUtilityClass.init_QMSP_Record();
                qmspRec.QMSP_Model__c = prod.Id;
                qmspRec.VME_Brand__c = brand_init.Id;
                insert qmspRec;
                vmeCamp = VME_TestDataUtilityClass.vme_Camp_init();
                vmeCamp.VME_Brand__c = brand_init.Id;
                vmeCamp.QMSP_Campaign__c = qmspRec.Id;
                insert vmeCamp;
                //System.debug('QMSP inserted successfully:::::' + qmspRec);
        }
        @isTest static void successful_filtering() {
            Campaign qmspRec = [Select id,Market__c,CurrencyIsoCode,Market_ID__c,VME_Fiscal_Year__c,QMSP_Quarter__c from Campaign LIMIT 1];
            Vehicle_Specification__c brand_init=[Select id,Name from Vehicle_Specification__c LIMIT 1];
        	Product2 prod=[Select id,Name,Model_Alternative__c from Product2 LIMIT 1];
                String searchRegionTest = qmspRec.Market__c;
                String searchMarketTest = qmspRec.Market_ID__c;
                String searchYearTest = qmspRec.VME_Fiscal_Year__c;
                String searchBrandTest = brand_init.Name;
                String searchQuarterTest = qmspRec.QMSP_Quarter__c;
                String searchModelTest = prod.Name;
                //System.debug(searchRegionTest + ' ' + searchMarketTest + ' ' + searchYearTest + ' ' + searchBrandTest + ' ' + searchQuarterTest + ' ' + searchModelTest);
                System.debug('Inserted product id ' + prod.Id + ' Model Alternative ' + prod.Model_Alternative__c + ' Model Name ' + prod.Name);
                Campaign search_QMSP = VME_Model_Adjustment_Ctrl.get_QMSP_Record(searchRegionTest, searchMarketTest, searchYearTest, searchBrandTest, searchQuarterTest, searchModelTest);
                List < Campaign > campAssertionTest = [Select Id, Name, Market__c, VME_Fiscal_Year__c, QMSP_Model__r.Name from Campaign where Market__c = : searchMarketTest and VME_Fiscal_Year__c = : searchYearTest and VME_Brand__r.Name = : searchBrandTest and QMSP_Quarter__c = : searchQuarterTest];
                System.assertEquals(campAssertionTest[0].Id, search_QMSP.Id, 'Checking whether the Inserted Campaign is same as the searched Campaign');
                System.assertEquals(campAssertionTest[0].Market__c, searchRegionTest, 'Checking whether the Searched Campaign has same Region as that of the Inserted Campaign');
                System.assertEquals(campAssertionTest[0].VME_Fiscal_Year__c, searchYearTest, 'Checking whether the Searched Campaign has same Financial Year as that of the Inserted Campaign');
                System.assertEquals(campAssertionTest[0].QMSP_Model__r.Name, searchModelTest, 'Checking whether the Searched Campaign has same Model as that of the Inserted Campaign');
        }
        @isTest static void unsuccessful_filtering_withProductCode() {
            	Product2 prod=[Select id,Name,Model_Alternative__c from Product2 LIMIT 1];
                prod.Model_Alternative__c = 'X152(W9)';
                //prod.ProductCode = 'W9';
                update prod;
            	Campaign qmspRec = [Select id,Market__c,CurrencyIsoCode,Market_ID__c,VME_Fiscal_Year__c,QMSP_Quarter__c from Campaign LIMIT 1];
            	Vehicle_Specification__c brand_init=[Select id,Name from Vehicle_Specification__c LIMIT 1];
        		prod=[Select id,Name,Model_Alternative__c from Product2 LIMIT 1];
                String searchRegionTest = qmspRec.Market__c;
                String searchMarketTest = qmspRec.Market_ID__c;
                String searchYearTest = qmspRec.VME_Fiscal_Year__c;
                String searchBrandTest = brand_init.Name;
                String searchQuarterTest = qmspRec.QMSP_Quarter__c;
                String searchModelTest = prod.Model_Alternative__c;
                //System.debug(searchRegionTest + searchMarketTest + searchYearTest + searchBrandTest + searchQuarterTest + searchModelTest);
                Campaign search_QMSP = VME_Model_Adjustment_Ctrl.get_QMSP_Record(searchRegionTest, searchMarketTest, searchYearTest, searchBrandTest, searchQuarterTest, searchModelTest);
                System.assertEquals(search_QMSP, null, 'Checking whether the Record is found or not by populating the filter criteria by the data that does not match any existing records inserted by the test class');
        }
        @isTest static void unSuccessful_filtering() {
            	Vehicle_Specification__c brand_init=[Select id,Name from Vehicle_Specification__c LIMIT 1];
        		Product2 prod=[Select id,Name,Model_Alternative__c from Product2 LIMIT 1];
                String searchRegionTest = 'IN';
                String searchMarketTest = 'IndiaTest';
                String searchYearTest = '2019-20';
                String searchBrandTest = brand_init.Name;
                String searchQuarterTest = 'Q4';
                String searchModelTest = prod.Model_Alternative__c;
                Campaign search_QMSP = VME_Model_Adjustment_Ctrl.get_QMSP_Record(searchRegionTest, searchMarketTest, searchYearTest, searchBrandTest, searchQuarterTest, searchModelTest);
                System.assertEquals(search_QMSP, null, 'Checking whether the Record is found or not by populating the filter criteria by the data that does not match any existing records inserted by the test class');
        }
        @isTest static void successful_QMSP_Update() {
            	Campaign qmspRec = [Select id,Market__c,Market_ID__c,CurrencyIsoCode,VME_Fiscal_Year__c,QMSP_Quarter__c from Campaign LIMIT 1];
                Id recToUpdt = qmspRec.Id;
                Integer plnAmt = 456;
                Integer retailVolume = 10;
                Decimal adjvolume = 123;
                VME_Model_Adjustment_Ctrl.TransactionStatus statusdetails = VME_Model_Adjustment_Ctrl.updt_QMSP_Record(recToUpdt, plnAmt, adjvolume, qmspRec,retailVolume);
                System.assertEquals(statusdetails.Status, VME_Constants.SUCCESS_MSG, 'Checking whether the Campaign record is Updated successfully or not');
        }
        @isTest static void unSuccessful_QMSP_Update() {
            	Product2 prod=[Select id,Name from Product2 LIMIT 1];
                Id recToUpdt = prod.Id;
                Integer plnAmt = -906;
                Decimal adjvolume = 123;
                Integer retailVolume = 10;
                VME_Model_Adjustment_Ctrl.TransactionStatus statusdetails = VME_Model_Adjustment_Ctrl.updt_QMSP_Record(recToUpdt, plnAmt, adjvolume, qmspRec,retailVolume);
                System.assertEquals(statusdetails.Status, VME_Constants.ERROR, 'Checking whether the Campaign record is Updated successfully or not');
        }
        @isTest static void loggedIn_User_Currency() {
                String curType;
                curType = VME_Model_Adjustment_Ctrl.get_User_Currency();
                System.assertEquals(UserInfo.getDefaultCurrency(), curType, 'Checking whether the User Currency is same as that being displayed on the Layout of QMSP adjustment Layout');
        }
        //This is the Method used to cover the class VME_QMSP_Filter_Ctrl used for the filters in the tactical adjustment Module
        @isTest static void VME_QMSP_Filter_CtrlMethodsCoverage() {
                Map < String, List < String >> marketMap = VME_QMSP_Filter_Ctrl.get_VME_Region_Market_Map();
                System.assertNotEquals(marketMap, null, 'Checking whether there is data in the Market and Region Map');
                Map < String, List < String >> getRegion_Market_ActualMap = VME_QMSP_Filter_Ctrl.get_VME_Region_Market_Map();
                System.assertEquals(true, getRegion_Market_ActualMap.containsKey('IN'), 'Checking the market picklist contains IN values of not');
                VME_QMSP_Filter_Ctrl.get_User_Details();
                VME_QMSP_Filter_Ctrl.getQuarterPicklistValues();
                Map < String, List < String >> modelMap = VME_QMSP_Filter_Ctrl.getModelPicklistValues();
                System.assertNotEquals(modelMap, null, 'Checking whether there is data in the Model Map');
                Map < String, List < String >> brandMap = VME_QMSP_Filter_Ctrl.getBrand_Model_Map();
                System.assertNotEquals(brandMap, null, 'Checking whether there is data in the Brand-Model Map');
                //Map < String, List < String >> expectedBrandModelDetailsMap = VME_QMSP_Filter_Ctrl.getBrand_Model_Map();
                //List < Vehicle_Specification__c > actualBrandModelList = [SELECT Id, Name FROM Vehicle_Specification__c];
                //System.assertEquals(expectedBrandModelDetailsMap.keySet().size(), actualBrandModelList.size(), 'Checking inserted brand ');
        }
}