/*
    Name : VME_ShowClaimScheme_Test.apxc

    Author: Deepti Tanguturi

    Purpose: VME Show Claim Scheme Test class for displaying scheme and camapign information  for claim

    Created Date : 08/05/2019
*/
@isTest
private class VME_ShowClaimScheme_Test {
        @testSetup
        public static void dataSetup() {
            	 Vehicle_Specification__c vehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
                insert vehicle;
             Product2 modelProductJag = VME_TestDataUtilityClass.CreateModelProduct('XF', 'V3', '  XF');
                        modelProductJag.Make__c = vehicle.Id;
                        Insert modelProductJag;
            
                 Product2 derivativeProductJag = VME_TestDataUtilityClass.CreateDerivativeProduct('XF (X250) Facelift 2200 Luxury Automatic Singapore', '5000217157', 'XF');
                        derivativeProductJag.Make__c = vehicle.Id;
                        derivativeProductJag.Model__c = modelProductJag.Id;
                        derivativeProductJag.Engine_Name_Alternative__c = '2.2 i4 Diesel';
                        derivativeProductJag.Model_Year_Alternative__c = '2015';
                        Insert derivativeProductJag;
               
                Campaign QMSPObj = VME_TestDataUtilityClass.init_QMSP_Record();
                QMSPObj.Name = 'Q2 - 2019-20 - Jaguar - INDIA';
                QMSPObj.VME_Brand__c = vehicle.Id;
                QMSPObj.QMSP_Model__c = derivativeProductJag.Id;
                Insert QMSPObj;
                VME_Campaign__c vmeCampaign = VME_TestDataUtilityClass.vme_Camp_init();
                vmeCampaign.VME_Brand__c = vehicle.Id;
                vmeCampaign.VME_Model__c = modelProductJag.Id;
                vmeCampaign.QMSP_Campaign__c = QMSPObj.Id;
                Insert vmeCampaign;
                VME_Schemes__c vmeScheme = VME_TestDataUtilityClass.vme_Schemes_Init(null,null, 0, 25000, 'Parent', 'Others', '');
                vmeScheme.VME_Campaign__c = vmeCampaign.Id;
                Insert vmeScheme;
            	
           
              List < Account > accountList = new List < Account > ();
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
            
            Asset FIRST_ASSET_VIN = VME_TestDataUtilityClass.createVIN('SADCA2AK3HA087201', '', 95000000, 105000000, 'New', 'Created');
            FIRST_ASSET_VIN.Brand__c = vehicle.Id;
            FIRST_ASSET_VIN.Model__c = modelProductJag.Id;
            FIRST_ASSET_VIN.Derivative__c = derivativeProductJag.Id;
            FIRST_ASSET_VIN.AccountId = accountList[2].Id; //customer.Id;
            FIRST_ASSET_VIN.Retailer_Name__c = accountList[0].Id; //retailer.Id;
            FIRST_ASSET_VIN.Product2Id = derivativeProductJag.Id;
            Insert FIRST_ASSET_VIN;
            
                VME_Claims__c claimObj = VME_TestDataUtilityClass.claims_Init();
                claimObj.VME_Related_Scheme__c = vmeScheme.Id;
            	claimObj.VME_VIN__c =FIRST_ASSET_VIN.Id;
                insert claimObj;
        }
        public static testMethod void positiveScenario() {
                Test.startTest();
                User expectedFetchUser = VME_ShowClaimScheme_Ctrl.fetchUser();
                User actualUser = [SELECT Id, Name from User WHERE Id = : UserInfo.getUserId()];
                System.assertEquals(expectedFetchUser.Name, actualUser.Name, 'Checking for the same user\'s Name for JLR ADMIN');
                List < VME_ShowClaimScheme_Ctrl.SchemeCampaignWrapper > schemeWrap = new List < VME_ShowClaimScheme_Ctrl.SchemeCampaignWrapper > ();
                VME_Claims__c claim = [SELECT Id, VME_Related_Scheme__c FROM VME_Claims__c LIMIT 1];
                VME_ShowClaimScheme_Ctrl.SchemeCampaignWrapper wrapperObj = VME_ShowClaimScheme_Ctrl.getClaimSchemeData(claim.Id);
                String userDfltCurrency = VME_ShowClaimScheme_Ctrl.get_User_Currency();
                User expectedUser = [SELECT Id, Name, DefaultCurrencyIsoCode from User WHERE Id = : UserInfo.getUserId()];
                System.assertEquals(expectedUser.DefaultCurrencyIsoCode, userDfltCurrency, 'Checking for the same user\'s DefaultCurrencyIsoCode for JLR ADMIN');
                VME_Schemes__c scheme = [SELECT Id, Name, VME_Start_Date__c, VME_End_Date__c, VME_Campaign__c, VME_Campaign__r.Name, VME_JLR_Share__c, VME_PU_Amount__c, VME_Retailer__c, VME_Claims_Available__c, VME_Claims_Approved__c, VME_Total_Amount_Approved__c, VME_Total_Amount_Available__c, VME_InActive__c, VME_Scheme_Type__c, VME_Volume__c FROM VME_Schemes__c];
                System.assertEquals(wrapperObj.campaignObj.Name, scheme.VME_Campaign__r.Name, 'Checking for L2 VME Category name');
                System.assertEquals(wrapperObj.schemeObj.VME_PU_Amount__c, scheme.VME_PU_Amount__c, 'Checking for scheme PU Amount with Sales Link PU amount');
                Test.stopTest();
        }
}