/*****************************************************
 *  Name        : VME_Submit_Claims_Test
 *  
 *  Company     : ETMarlabs
 *    
 *  Purpose     : Test class for submit claims
 * 
 *  Developer   : Tejashree J
 *
 *  Created Date: 4/05/2019
 *
 *  Modified    : 09/07/2019 BY Tejashree J
*****************************************************/
@isTest
private class VME_Submit_Claims_Test {
        public static Vehicle_Specification__c brand;
        public static Vehicle_Specification__c brand2;
        public static Asset vin;
        public static Asset vin2;
        public static Id p;
        public static Account ac;
        public static Contact con;
        public static User user;
        public static Product2 prod;
        public static VME_Campaign__c vmeCampaign;
        public static VME_Campaign__c vmeCampaign2;
        public static VME_Campaign__c vmeCampaign3;
        public static VME_Schemes__c scheme;
        public static VME_Schemes__c scheme2;
        public static VME_Schemes__c scheme3;
        public static VME_Claims__c claim;
        public static VME_Claims__c claim2;
        public static VME_Claims__c claim3;
        public static VME_Claims__c claim4;
        public static VME_Claims__c claim5;
        public static VME_Claims__c claim6;
        @testSetup
        public static void initialize() {
                User usr = [Select id from User where Id = : UserInfo.getUserId()];
                System.RunAs(usr) {
                        p = [select id from profile where name = 'Sales Executive'].id;
                        ac = new Account(name = 'Test Partner Account'); 
                        ac.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId();
                        insert ac;
                        con = new Contact(FirstName = 'JLR', LastName = 'testCon', AccountId = ac.Id, Email = 'jlrtest@gmail.com');
                        insert con;
                        user = new User(alias = 'test123', email = 'tester1234ET@submitclaim.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p, country = 'United States', IsActive = true, ContactId = con.Id, Market__c = 'IN', Is_Marketing_User__c = true, timezonesidkey = 'America/Los_Angeles', username = 'testghjET@submitclaim.com');
                        insert user;
                }
                
                brand = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar Test');
                insert brand;
                List<Asset> vinList = new List<Asset>();
                vin = VME_TestDataUtilityClass.createVIN();
                vin.AccountId = ac.Id;
                vin.Brand__c = brand.Id;
                vin.VME_Retail_Date__c = System.today();
                vin.RecordTypeId=Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
                vin.Retailer_Name__c = ac.Id;
                vinList.add(vin);
                vin2 = VME_TestDataUtilityClass.createVIN('SADCA2AK3HA067541', 'KA-51-6577', 20000, 230000, 'New', 'Created');
                vin2.AccountId = ac.Id;
                vin2.Brand__c = brand.Id;
                vin2.VME_Retail_Date__c = System.today();
                vin2.RecordTypeId=Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Vehicle').getRecordTypeId();
                vin2.Retailer_Name__c = ac.Id;
                vinList.add(vin2);
                insert vinList;
                prod = new Product2();
                prod = VME_TestDataUtilityClass.CreateModelProduct('XJ', '5000341196', 'XE');
                insert prod;
                Campaign qmspRec = new Campaign();
                qmspRec = VME_TestDataUtilityClass.init_QMSP_Record();
                qmspRec.QMSP_Model__c = prod.Id;
                qmspRec.VME_Brand__c = brand.Id;
                insert qmspRec;
                List<VME_Campaign__c> vmeCampaignList = new List<VME_Campaign__c>();
                vmeCampaign = VME_TestDataUtilityClass.vme_Camp_init();
                vmeCampaign.QMSP_Campaign__c = qmspRec.Id;
                vmeCampaign.VME_Brand__c = brand.Id;
                vmeCampaign.VME_Model__c = prod.Id;
                vmeCampaign.VME_Category__c = 'Retail Non-Finance';
                vmeCampaign.VME_Sub_Category__c = 'Cash Programmes';
                vmeCampaignList.add(vmeCampaign);
                vmeCampaign2 = VME_TestDataUtilityClass.vme_Camp_init();
                vmeCampaign2.QMSP_Campaign__c = qmspRec.Id;
                vmeCampaign2.VME_Brand__c = brand.Id;
                vmeCampaign2.VME_Model__c = prod.Id;
                vmeCampaign2.VME_Category__c = 'Retail Non-Finance';
                vmeCampaign2.VME_Sub_Category__c = 'Registration Bonus';
                vmeCampaignList.add(vmeCampaign2);
                vmeCampaign3 = VME_TestDataUtilityClass.vme_Camp_init();
                vmeCampaign3.QMSP_Campaign__c = qmspRec.Id;
                vmeCampaign3.VME_Brand__c = brand.Id;
                vmeCampaign3.VME_Model__c = prod.Id;
                vmeCampaign3.VME_Category__c = 'Retail Non-Finance';
                vmeCampaign3.VME_Sub_Category__c = 'Cash Programmes';
                vmeCampaignList.add(vmeCampaign3);
                insert vmeCampaignList;
                List < VME_Schemes__c > schemeListToInsert= new List < VME_Schemes__c >(); 
                scheme = VME_TestDataUtilityClass.vme_Schemes_Init(Date.Today(),Date.Today().addDays(15),70,12400,'Parent','Others','');
                scheme.VME_Campaign__c = vmeCampaign.Id;
                scheme.VME_Level_3_Description__c = 'MY18 Oct - Dec Mfd Stock';
                schemeListToInsert.add(scheme);
                scheme2 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.Today(),Date.Today().addDays(15),70,12400,'Parent','Others','');
                scheme2.VME_Campaign__c = vmeCampaign2.Id;
                scheme2.VME_Level_3_Description__c = 'MY18 Oct - Dec Mfd Stock';
                schemeListToInsert.add(scheme2);
                scheme3 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.Today(),Date.Today().addDays(15),70,12400,'Parent','Others','');
                scheme3.VME_Campaign__c = vmeCampaign3.Id;
                scheme3.VME_Level_3_Description__c = 'MY18 Oct - Dec Mfd Stock';
                schemeListToInsert.add(scheme3);
                insert schemeListToInsert;
                List<VME_Claims__c> claimListToInsert = new List<VME_Claims__c>();
                claim = VME_TestDataUtilityClass.claims_Init();
                claim.VME_Number_Of_Attachments__c = 0;
                claim.VME_Region_Market__c = 'IN';
                claim.VME_Related_Scheme__c = scheme.Id;
                claim.VME_Country_ISO_Code__c = 'IN';
                claim.VME_Status__c = 'Generated';
                claim.VME_VIN__c = vin.Id;
                claim.VME_Maximum_Attempts__c = 5;
                claim.VME_Last_Date_of_Submissiom__c = System.today();
                claim.VME_Last_Resubmission_Date__c = Date.today().addDays(30);
                claimListToInsert.add(claim);
                claim2 = VME_TestDataUtilityClass.claims_Init();
                claim2.VME_Number_Of_Attachments__c = 1;
                claim2.VME_Region_Market__c = 'IN';
                claim2.VME_Related_Scheme__c = scheme.Id;
                claim2.VME_Country_ISO_Code__c = 'IN';
                claim2.VME_VIN__c = vin.Id;
                claim2.VME_Maximum_Attempts__c = 4;
                claim2.VME_Status__c = 'Rejected';
                claim2.VME_Last_Date_of_Submissiom__c = System.today();
                claim2.VME_Last_Resubmission_Date__c = Date.today().addDays(30);
                claimListToInsert.add(claim2);
                claim3 = VME_TestDataUtilityClass.claims_Init();
                claim3.VME_Number_Of_Attachments__c = 1;
                claim3.VME_Region_Market__c = 'IN';
                claim3.VME_Related_Scheme__c = scheme.Id;
                claim3.VME_Country_ISO_Code__c = 'IN';
                claim3.VME_VIN__c = vin.Id;
                claim3.VME_Maximum_Attempts__c = 5;
                claim3.VME_Status__c = 'Settled';
                claim3.VME_Last_Date_of_Submissiom__c = System.today();
                claim3.VME_Last_Resubmission_Date__c = Date.today().addDays(30);
                claimListToInsert.add(claim3);
                claim4 = VME_TestDataUtilityClass.claims_Init();
                claim4.VME_Number_Of_Attachments__c = 0;
                claim4.VME_Region_Market__c = 'IN';
                claim4.VME_Related_Scheme__c = scheme.Id;
                claim4.VME_Country_ISO_Code__c = 'IN';
                claim4.VME_Status__c = 'Settled';
                claim4.VME_VIN__c = vin.Id;
                claim4.VME_Maximum_Attempts__c = 5;
                claim4.VME_Last_Date_of_Submissiom__c = Date.newInstance(2019, 04, 12);
                claim4.VME_Last_Resubmission_Date__c = Date.today().addDays(30);
                claimListToInsert.add(claim4);
                claim5 = VME_TestDataUtilityClass.claims_Init();
                claim5.VME_Number_Of_Attachments__c = 0;
                claim5.VME_Region_Market__c = 'IN';
                claim5.VME_Related_Scheme__c = scheme3.Id;
                claim5.VME_Country_ISO_Code__c = 'IN';
                claim5.VME_Status__c = 'Settled';
                claim5.VME_VIN__c = vin.Id;
                claim5.VME_Maximum_Attempts__c = 5;
                claim5.VME_Last_Date_of_Submissiom__c = System.today();
                claim5.VME_Last_Resubmission_Date__c = Date.today().addDays(30);
                claimListToInsert.add(claim5);
                claim6 = VME_TestDataUtilityClass.claims_Init();
                claim6.VME_Number_Of_Attachments__c = 1;
                claim6.VME_Region_Market__c = 'IN';
                claim6.VME_Related_Scheme__c = scheme.Id;
                claim6.VME_Country_ISO_Code__c = 'IN';
                claim6.VME_VIN__c = vin.Id;
                claim6.VME_Maximum_Attempts__c = 1;
                claim6.VME_Status__c = 'Recalled';
                claim6.VME_Last_Date_of_Submissiom__c = System.today();
                claim6.VME_Last_Resubmission_Date__c = Date.today().addDays(30);
                claimListToInsert.add(claim6);
                insert claimListToInsert;
                ContentVersion contentVersion = new ContentVersion(Title = 'RC copy', PathOnClient = 'JLR.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
                insert contentVersion;
                ContentVersion contentVersion2 = new ContentVersion(Title = 'Sample', PathOnClient = 'JLR.jpg', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
                insert contentVersion2;
                List < ContentDocument > documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 5];
                //create ContentDocumentLink  record 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = claim3.id;
                cdl.Visibility = 'AllUsers';
                cdl.ContentDocumentId = documents[0].Id;
                cdl.ShareType = 'V';
                insert cdl;
                ContentDocumentLink cdl2 = New ContentDocumentLink();
                cdl2.LinkedEntityId = claim4.id;
                cdl2.Visibility = 'AllUsers';
                cdl2.ContentDocumentId = documents[1].Id;
                cdl2.ShareType = 'V';
                insert cdl2;
                CampaignShare camShr = new CampaignShare();
                camShr.CampaignId = qmspRec.Id;
                camShr.UserOrGroupId = user.Id;
                camShr.CampaignAccessLevel = 'Edit';
                camShr.RowCause = 'Manual';
                Database.SaveResult sr = Database.insert(camShr, false);
                List < VME_Claims__c > all_Claims = [Select Id, (SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize FROM ContentDocumentLinks) from VME_Claims__c];
                if (sr.isSuccess()) {
                        System.debug('Success');
                } else {
                        System.debug('Failed manual sharing of Campaign in test class');
                        System.debug('Error in:::::' + sr);
                        Database.Error err = sr.getErrors()[0];
                        if (err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('CampaignAccessLevel')) {
                                System.debug('Failed to share');
                        }
                }
        }
        @isTest static void get_All_Assets_Testmethod() {
                User user=[Select id from User where username = 'testghjET@submitclaim.com'];
                System.runAs(user) {
                        VME_Submit_Claims.Submit_Claim_Wrapper resulWrapper= VME_Submit_Claims.get_Assets(null, null, null, null, null, null);
                        System.assertEquals(resulWrapper.statusOfTransaction,'NO-FILTER','Checking whether all the Assets are listed without any filter conditions');
                        List<Asset> assetListTest = [Select id,Name from Asset LIMIT 5];
                        System.assertEquals(assetListTest.size(),2,'Checking the number of Assets available');
                }
        }
        @isTest static void get_All_Assets_Testmethod2() {
                User user=[Select id from User where username = 'testghjET@submitclaim.com'];
                String today = String.valueOf(Date.newInstance(2019, 08, 20));
                System.runAs(user) {
                        VME_Submit_Claims.Submit_Claim_Wrapper resulWrapper=VME_Submit_Claims.get_Assets(today, today, 'SADCA2AK3HA087201','Test','null','PENDING');
                        System.assertEquals(resulWrapper.statusOfTransaction,'NO-VIN','There is no VIN with the filtered Asset');
                }
        }
        @isTest static void edit_Claim_Test() {
                Double nonClaimableAmount = 12.4565;
                Double claimAmount = 56.4565;
            	VME_Claims__c claim = [Select id,VME_Amount__c, VME_Retailer_Contribution__c,VME_Submitter_Comments__c from VME_Claims__c where VME_Status__c='Generated' LIMIT 1];
                VME_Submit_Claims.save_Edited_Claim(claim.Id, nonClaimableAmount, 'Please Approve',claimAmount,true);
                VME_Claims__c editClaimAssertionTest = [Select Id,VME_Amount__c, VME_Retailer_Contribution__c,VME_Submitter_Comments__c from VME_Claims__c where id=:claim.Id LIMIT 1];
                System.assertEquals(editClaimAssertionTest.VME_Amount__c,claimAmount,'Checking whether the claim Amount is updated in the respective claim or not');
                System.assertEquals(editClaimAssertionTest.VME_Retailer_Contribution__c,nonClaimableAmount,'Checking whether the retailer contribution is updated in the respective claim or not');
                System.assertEquals(editClaimAssertionTest.VME_Submitter_Comments__c,'Please Approve','Checking whether the Submitter comments is updated inn the respective claim or not');
                        
        }
        @isTest static void delete_Claim_Record_Test() {
            	VME_Claims__c claim = [Select id,VME_Amount__c, VME_Retailer_Contribution__c,VME_Submitter_Comments__c from VME_Claims__c where VME_Status__c='Generated' LIMIT 1];
                VME_Submit_Claims.delete_Claim_Record(claim.Id);
                VME_Claims__c deleteClaimAssertionTest = [Select Id, VME_InActive__c from VME_Claims__c where id=:claim.Id LIMIT 1];                
                System.assertEquals(deleteClaimAssertionTest.VME_InActive__c,true,'Checking whether the claim to be deleted is made as Inactive or not');
        }
        @isTest static void approval_Process_Test() {
            	VME_Claims__c claim = [Select id,VME_Amount__c, VME_Retailer_Contribution__c,VME_Submitter_Comments__c from VME_Claims__c where VME_Status__c='Generated' LIMIT 1];
            	VME_Claims__c claim2 = [Select id,VME_Amount__c, VME_Retailer_Contribution__c,VME_Submitter_Comments__c from VME_Claims__c where VME_Status__c='Rejected' LIMIT 1];
            	VME_Claims__c claim6 = [Select id,VME_Amount__c, VME_Retailer_Contribution__c,VME_Submitter_Comments__c from VME_Claims__c where VME_Status__c='Recalled' LIMIT 1];

                String today = String.valueOf(Date.newInstance(2019, 08, 20));
                List < String > claimIdCommentsMap = new List < String > ();
                claimIdCommentsMap.add(claim.Id);
                claimIdCommentsMap.add(claim2.Id);
                claimIdCommentsMap.add(claim6.Id);
                Test.StartTest();
                VME_Submit_Claims.submitForApproval(claimIdCommentsMap);
                VME_Submit_Claims.Approve_Claim_Wrapper resultWrapper = VME_Submit_Claims.recallOnSubmit(claim.Id);
                Test.stopTest();
                ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN :claimIdCommentsMap
                                                                 AND ProcessInstance.Status = 'Pending' LIMIT 5];
                VME_Submit_Claims.Submit_Claim_Wrapper resulWrapper=VME_Submit_Claims.get_Assets(today, today, 'SADCA2AK3HA087201','Test','null',''); 
                System.assertEquals(piWorkItems.size(),2,'Checking whether the Claim is submitted for approval or not');
                System.assertEquals(resultWrapper.statusOfTransaction,'RECALLSUCCESSFUL','Checking whether the Claim is recalled from approval or not');
        }
         @isTest static void approval_ProcessInstance_Test() {
            	VME_Claims__c claim2 = [Select id,VME_Amount__c, VME_Retailer_Contribution__c,VME_Submitter_Comments__c from VME_Claims__c where VME_Status__c='Rejected' LIMIT 1];
                User user=[Select id from User where username = 'testghjET@submitclaim.com'];
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(claim2.Id);
                req1.setProcessDefinitionNameOrId(System.Label.Approval1); 
                req1.setComments(claim2.VME_Submitter_Comments__c);
                req1.setSubmitterId(user.Id);
                req1.setSkipEntryCriteria(true);
                Approval.ProcessResult result = Approval.process(req1);
                System.assert(result.isSuccess());
                System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus()); 
                 System.runAs(user) {
                VME_Submit_Claims.Submit_Claim_Wrapper resulWrapper=VME_Submit_Claims.get_Assets(null, null, null,null,null,null); 
                 }
             	Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('Rejected request using Trigger');
                req.setAction('Reject');
                Id retVal = null;

                for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
                    where p.ProcessInstance.TargetObjectId =: claim2.Id])
                {
                    retVal  =  workItem.Id;
                }
                Id workItemId = retVal;
        
                if(workItemId == null)
                {
                }
                else
                {
                    req.setWorkitemId(workItemId);
                    // Submit the request for approval
                    Approval.ProcessResult result2 =  Approval.process(req);
                }
             System.runAs(user) {
                VME_Submit_Claims.Submit_Claim_Wrapper resulWrapper=VME_Submit_Claims.get_Assets(null, null, null,null,null,null); 
                 }
        } 
        @isTest static void approval_Process_TestException() {
            	VME_Claims__c claim3 = [Select id,VME_Amount__c, VME_Retailer_Contribution__c,VME_Submitter_Comments__c from VME_Claims__c where VME_Number_Of_Attachments__c=1 AND VME_Status__c='Settled' LIMIT 1];
                List < String > claimIdCommentsMap = new List < String > ();
                claimIdCommentsMap.add(claim3.Id);
                Test.StartTest();
                VME_Submit_Claims.Approve_Claim_Wrapper resultWrapper = VME_Submit_Claims.submitForApproval(claimIdCommentsMap);
                System.assertEquals(resultWrapper.statusOfTransaction,'ERROR','Checking Exception Occurance while Claim Submission'); 
                Test.stopTest();
        }
        @isTest static void delete_Document_Test() {
                ContentVersion contentVersionInsert = new ContentVersion(Title = 'Test', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
                insert contentVersionInsert;
                List < ContentDocument > documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                System.assertEquals(documents.size(), 3,'Checking the document Insertion for a particular claim');
                Id docId = documents[0].Id;
                VME_Submit_Claims.delete_Document(docId);
                List<ContentDocument> deletionTest = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where id=:docId];
                System.assertEquals(deletionTest.size(),0,'Checking whether the document is deleted or not');
        }
        @isTest static void update_Document_Test() {
                ContentVersion contentVersionInsert = new ContentVersion(Title = 'Test', PathOnClient = 'Test.jpg', VersionData = Blob.valueOf('Test Content Data'), IsMajorVersion = true);
                insert contentVersionInsert;
                List < ContentDocument > documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                System.assertEquals(documents.size(), 3,'Checking whether the documents are insert or not for Testing Purpose');
                Id docId = documents[0].Id;
                VME_Submit_Claims.rename_Document(docId, 'Other');
                ContentDocument updationTest = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where id=:docId LIMIT 1];
                System.assertEquals(updationTest.title,'Other','Checking whether the file is renamed according to the Evidence matrix or not');
        }
}