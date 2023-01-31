/*
    Name : VME_ContentDocLink_Trigger_Test.apxc

    Author: Deepti Tanguturi

    Purpose: VME Content Document Link Test class for attachment upload and delete on Claim 

    Created Date : 08/05/2019
*/
@isTest
private class VME_ContentDocLink_TriggerHandler_Test {
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
                


                VME_Schemes__c vmeSchemeObj = VME_TestDataUtilityClass.vme_Schemes_Init(null, null, 0, 25000, 'Parent', 'Others', '');
                vmeSchemeObj.VME_Campaign__c = vmeCampaign.Id;
                Insert vmeSchemeObj;
				
          
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
                claimObj.VME_Related_Scheme__c = vmeSchemeObj.Id;
                claimObj.VME_Number_Of_Attachments__c = 0;   
            	claimObj.VME_VIN__c =FIRST_ASSET_VIN.Id;
                insert claimObj;
        }
        public static testMethod void positiveScenario() {
                ContentVersion contentVersion_1 = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
                insert contentVersion_1;

                VME_Claims__c claimObjCntZero = [Select Id, VME_Number_Of_Attachments__c from VME_Claims__c LIMIT 1];
                System.assertEquals(0,claimObjCntZero.VME_Number_Of_Attachments__c,'Checking Attachment count must zero at initial');

                ContentVersion contentVersionSelect  = [SELECT Id, Title, ContentDocumentId FROM ContentVersion LIMIT 1];
                ContentDocument documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
                
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = claimObjCntZero.id;
                cdl.ContentDocumentId = documents.Id;
                cdl.shareType = 'V';
                Insert cdl;

                VME_Claims__c claimObjCntOne = [Select Id, VME_Number_Of_Attachments__c from VME_Claims__c WHERE Id=: claimObjCntZero.Id LIMIT 1];
                System.assertEquals(1,claimObjCntOne.VME_Number_Of_Attachments__c,'Checking Attachment count increase to 1');

                Delete documents;
                VME_Claims__c claimObjCntAgnZero = [Select Id, VME_Number_Of_Attachments__c from VME_Claims__c WHERE Id=: claimObjCntZero.Id LIMIT 1];
                System.assertEquals(0,claimObjCntAgnZero.VME_Number_Of_Attachments__c,'Checking Attachment count decrease to 0 after delete');

                Undelete documents;
                VME_Claims__c claimObjCntAgainOne = [Select Id, VME_Number_Of_Attachments__c from VME_Claims__c WHERE Id=: claimObjCntZero.Id LIMIT 1];
                System.assertEquals(1,claimObjCntAgainOne.VME_Number_Of_Attachments__c,'Checking Attachment count increase to 1 after undelete');
        }
}