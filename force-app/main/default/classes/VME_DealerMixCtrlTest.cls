@isTest
public class VME_DealerMixCtrlTest {
    
    @TestSetup
    static void createData(){
        User currentUser            = VME_TestDataUtilityClass.createSalesforceUser();
        insert currentUser;
        System.runAs(currentUser) {
            
            Campaign campaignObj        = VME_TestDataUtilityClass.init_QMSP_Record();
            insert campaignObj;
            VME_Campaign__c vmeCampObj  = VME_TestDataUtilityClass.vme_Camp_init();
            vmeCampObj.QMSP_Campaign__c = campaignObj.Id;
            insert vmeCampObj;
            Account ac1 =VME_TestDataUtilityClass.createRetailerByValue('Test1','8867472034',vmeCampObj.VME_Country_ISO_Code__c,'Jaguar','Trading',null,'11818','1234',null,currentUser.Market__c,null);
            ac1.Retailer_Type__c='Main dealer';
            ac1.Queue_ID__c=null;
            ac1.Dealer_CI_Code__c ='102001';
            ac1.Dealer_CI_Code_2__c='102001';
            ac1.Stopped_Trading__c=(Date.today()).addDays(6);
            Account ac2 = VME_TestDataUtilityClass.createRetailerByValue('Test2','8867472035',vmeCampObj.VME_Country_ISO_Code__c,'Jaguar','Trading',null,'11819','12345',null,currentUser.Market__c,null);
            ac2.Retailer_Type__c='Sales Dealer';
            ac2.Queue_ID__c=null;
            ac2.Stopped_Trading__c=(Date.today()).addDays(6);
            ac2.Dealer_CI_Code__c ='102002';
            ac2.Dealer_CI_Code_2__c='102002';
            List<Account> accList   = new List<Account>();
            accList.add(ac1);
            accList.add(ac2);
            insert accList; 
            Id parentRecordTypeId = Schema.Sobjecttype.VME_Schemes__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId(); 
            Id childRecordTypeId = Schema.Sobjecttype.VME_Schemes__c.getRecordTypeInfosByName().get('Child').getRecordTypeId();
            
            VME_Schemes__c schemeObj    = VME_TestDataUtilityClass.vme_Schemes_Init();
            schemeObj.VME_Campaign__c   = vmeCampObj.Id;
            schemeObj.recordTypeId = parentRecordTypeId;
            insert schemeObj;
            
            VME_Schemes__c schemeObj1  = VME_TestDataUtilityClass.vme_Schemes_Init();
            schemeObj1.VME_Campaign__c   = vmeCampObj.Id;
            schemeObj1.VME_Parent_Scheme__c = schemeObj.Id;
            schemeObj.recordTypeId = childRecordTypeId;
            schemeObj1.VME_Retailer__c = ac1.Id;
            insert schemeObj1;
        }
    }
    
    @isTest
    static void testmethod1(){
        Test.startTest();
        User loggedUser = [SELECT Id, Name, Username, Market__c, Country_ISO_Code__c FROM User where UserName='etadmin@ettestjlr.utiltest' limit 1];   
        System.debug(loggedUser);
        System.runAs(loggedUser) {
            Id parentRecordTypeId = Schema.Sobjecttype.VME_Schemes__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId(); 
            
            VME_Schemes__c schemeObj = [Select Id,VME_Campaign__r.VME_External_ID__c,VME_Campaign__c,VME_Campaign__r.VME_Model__c  from VME_Schemes__c where recordTypeId=:parentRecordTypeId LIMIT 1];
            
            List<VME_Schemes__c> schemeListWithRetailer = [Select Id,VME_Retailer__c from VME_Schemes__c where VME_Retailer__c!=null ];
            
            List<Account> accList =[Select Id,name from Account];
            List<Account> otherAccList =[Select Id,name from Account  where Name ='Test2'];
            
            
            VME_DealerMixCtrl.getRecordTypeOfVMEDiscreationary();      
            
            VME_DealerMixCtrl.relatedBundling(schemeObj.Id,schemeObj.VME_Campaign__r.VME_Model__c,false);
            List<VME_Bundling__c> createdBundlingList =  [Select id,VME_Model_Derivative__c from VME_Bundling__c where VME_Model_Derivative__c=: schemeObj.VME_Campaign__r.VME_Model__c AND VME_Scheme__c=:schemeObj.Id];
            System.assertEquals(createdBundlingList.size(),1,'bundeling got created');
            
            VME_DealerMixCtrl.relatedBundling(schemeObj.Id,schemeObj.VME_Campaign__r.VME_Model__c,true);
            List<VME_Bundling__c> deletedBundlingList =   [Select id,VME_Model_Derivative__c from VME_Bundling__c where VME_Model_Derivative__c=: schemeObj.VME_Campaign__r.VME_Model__c AND VME_Scheme__c=:schemeObj.Id];
            System.assertEquals(deletedBundlingList.size(),0,'bundeling got deleted');
            
            List<VME_DealerMixCtrlWrapper> wrap1 =VME_DealerMixCtrl.getExistingDealersForScheme(schemeObj.Id, 'test',schemeObj.Id);
            System.assertEquals(wrap1.size(),0,'Firstly getting all the selected dealers.');
            
            List<VME_DealerMixCtrlWrapper> wrap2 =VME_DealerMixCtrl.getExistingDealersForScheme(schemeObj.Id, VME_Constants.REVISE_VME_MSG,schemeObj.Id);
            System.assertEquals(wrap2.size(),schemeListWithRetailer.size(),'The count of schemes having dealers existed');
            
            List<VME_DealerMixCtrlWrapper> wrap3 =VME_DealerMixCtrl.getExistingDealersForScheme(schemeObj.Id, VME_Constants.MODIFY_VME_MSG,schemeObj.Id);
            System.assertEquals(wrap3.size(),schemeListWithRetailer.size(),'check the existing dealers for scheme');
            
            
            List<VME_DealerMixCtrlWrapper> respWrap = VME_DealerMixCtrl.getDealersBasedOnName( String.valueOf(schemeObj.Id),'test',loggedUser.Country_ISO_Code__c);
            System.assertEquals(accList.size(),respWrap.size(),'The searched account and the existed account with the name as Test1');
            
            
            List<VME_DealerMixCtrlWrapper> wrap4 =VME_DealerMixCtrl.getDealersBasedOnName(String.valueOf(schemeObj.Id), VME_Constants.REVISE_VME_MSG,loggedUser.Country_ISO_Code__c);
            System.assertEquals(wrap4.size(),otherAccList.size(),'Already  Test1 retailer is there,Hence list will have other retailers');
            System.assertEquals(wrap4[0].accountObj.Id,otherAccList[0].Id,'Already  Test1 retailer is there,Hence list will have other retailer');
            
            List<VME_DealerMixCtrlWrapper> wrap5 =VME_DealerMixCtrl.getDealersBasedOnName( String.valueOf(schemeObj.Id), VME_Constants.MODIFY_VME_MSG,loggedUser.Country_ISO_Code__c);
            
            VME_Category_Adjustment_Ctrl.VMECampaignWrapper updatedWrapper =VME_DealerMixCtrl.getUpdatedWrapperofCurrentVME(schemeObj.VME_Campaign__c);
            System.assertEquals(updatedWrapper.vmeCampaignWrap.VME_External_ID__c, schemeObj.VME_Campaign__r.VME_External_ID__c, 'Campaign is returned in the wrapper');
            
            VME_DealerMixCtrl.loggedInFormat();
            //Changed the wrapper it should change according to user selection
            respWrap[1].isSelected =true;
            
            
            //String result1 =VME_DealerMixCtrl.saveDealerMixRecords(respWrap, schemeObj.Id, 'test');
            //System.assertEquals(result1,VME_Constants.SUCCESS_MSG ,'Successfully done');
            
            String negativeResult1 =VME_DealerMixCtrl.saveDealerMixRecords(respWrap, accList[0].Id, 'test');
            System.assertNotEquals(negativeResult1,VME_Constants.SUCCESS_MSG ,'Exception Occurs');  
            //Changed the wrapper it should change according to user selection
            wrap2[0].recordId=schemeObj.Id;
            wrap2[0].isSelected=false;
         List<VME_Schemes__c> beforeSchListWithRetailer = [Select Id,VME_Retailer__c from VME_Schemes__c where recordTypeId=:parentRecordTypeId ];
            String result =VME_DealerMixCtrl.saveDealerMixRecords(wrap2,  String.valueOf(schemeObj.Id), 'test');
            System.assertEquals(result,VME_Constants.SUCCESS_MSG ,'Successfully done');
            List<VME_Schemes__c> updatedSchList= [Select Id,VME_Retailer__c from VME_Schemes__c where  recordTypeId=:parentRecordTypeId];
            System.assertEquals(updatedSchList.size(),beforeSchListWithRetailer.size()-1,'Scheme got deleted');
            
            String negativeResult =VME_DealerMixCtrl.saveDealerMixRecords(wrap2, accList[0].Id, 'test');
            System.assertNotEquals(negativeResult,VME_Constants.SUCCESS_MSG ,'Exception Occurs');
            
            List<VME_Schemes__c> beforeDeletSchemeList= [Select Id from VME_Schemes__c  ];
            String deletedResult =VME_DealerMixCtrl.deleteL3(beforeDeletSchemeList[0].Id);
            System.assertEquals(deletedResult,VME_Constants.SUCCESS_MSG,'check the existing dealers for scheme');
            List<VME_Schemes__c> afterDeletSchemeList= [Select Id from VME_Schemes__c  ];
            //One Scheme got Deleted
            System.assertEquals(afterDeletSchemeList.size(),beforeDeletSchemeList.size()-1,'Scheme record is deleted');
            
            VME_DealerMixCtrlWrapper wrap = new VME_DealerMixCtrlWrapper();
            
            Test.stopTest();
        }
    }
}