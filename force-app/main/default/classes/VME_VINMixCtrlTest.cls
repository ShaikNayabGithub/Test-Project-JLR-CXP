@isTest
public class VME_VINMixCtrlTest {
        @TestSetup
        static void createData() {
              Account ac1 = VME_TestDataUtilityClass.createRetailerByValue('test',null,null,'Jaguar','Trading',null,null,'1234',null,null,null);
                insert ac1;

                   Account ac2 = VME_TestDataUtilityClass.createCustomer();
                      insert ac2;

                Campaign campaignObj = VME_TestDataUtilityClass.init_QMSP_Record();
                insert campaignObj;
                Vehicle_Specification__c jaguarVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
                Insert jaguarVehicle;
                Product2 modelProductJag = VME_TestDataUtilityClass.CreateModelProduct('F-PACE', 'R8', 'F-PACE');
                modelProductJag.Make__c = jaguarVehicle.Id;
                Insert modelProductJag;
                VME_Campaign__c vmeCampObj = VME_TestDataUtilityClass.vme_Camp_init();
                vmeCampObj.QMSP_Campaign__c = campaignObj.Id;
                vmeCampObj.VME_Brand__c = jaguarVehicle.Id;
                vmeCampObj.VME_Model__c = modelProductJag.Id;
                insert vmeCampObj;
                Asset assetObj1 = VME_TestDataUtilityClass.createVIN();
                assetObj1.Model__c = modelProductJag.Id;
                assetObj1.Brand__c = jaguarVehicle.Id;
                assetObj1.Retailer_Name__c = ac1.Id;
                assetObj1.AccountId = ac2.Id;
                assetObj1.VIN__c = 'test1';
                insert assetObj1;
                Asset assetObj2 = VME_TestDataUtilityClass.createVIN();
                assetObj2.Model__c = modelProductJag.Id;
                assetObj2.Brand__c = jaguarVehicle.Id;
                assetObj2.Retailer_Name__c = ac1.Id;
                 assetObj2.AccountId = ac2.Id;
                assetObj2.VIN__c = 'test2';
                insert assetObj2;
                Id parentRecordTypeId = Schema.Sobjecttype.VME_Schemes__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId(); 
                VME_Schemes__c schemeObj = VME_TestDataUtilityClass.vme_Schemes_Init();
                schemeObj.VME_Campaign__c = vmeCampObj.Id;
               schemeObj.recordTypeId = parentRecordTypeId;
                insert schemeObj;
                VME_Bundling__c bundeling = new VME_Bundling__c();
                bundeling.Asset__c = assetObj1.Id;
                bundeling.VME_Scheme__c = schemeObj.Id;
                insert bundeling;
        }
        @isTest
        static void testmethod1() {
                Test.startTest();
                VME_Schemes__c schemeObj = [Select Id,VME_Campaign__r.VME_External_ID__c,VME_Campaign__c from VME_Schemes__c LIMIT 1];
                Account retailer = [Select id from Account LIMIT 1];
                List < Asset > bundeligAstList = [Select id from Asset where VIN__c = 'test1'];
                String astName = '%' + 'test' + '%';
                List < Asset > astList = [Select id from Asset where VIN__c like: astName And Id != : bundeligAstList[0].Id];
                VME_Campaign__c vmeCamp = [Select id, VME_Brand__c, VME_Model__c from VME_Campaign__c LIMIT 1];
                List < VME_Bundling__c > bundlingList = [Select Id, Asset__c, VME_Scheme__c from VME_Bundling__c where VME_Scheme__c = : schemeObj.Id];

                List < VME_VINMixCtrlWrapper > wrap2 = VME_VINMixCtrl.getExistingVINForScheme(schemeObj.Id, VME_Constants.REVISE_VME_MSG, schemeObj.Id,retailer.Id);
                System.assertEquals(bundlingList.size(), wrap2.size(), 'There is  records assets existed for the revising scheme');
                System.assertEquals(wrap2[0].assetObj.Id, bundlingList[0].Asset__c, 'There is  same assets existed for the revising scheme in the bundeling');

                List < VME_VINMixCtrlWrapper > wrap3 = VME_VINMixCtrl.getExistingVINForScheme(schemeObj.Id, VME_Constants.MODIFY_VME_MSG, schemeObj.Id,retailer.Id);
                System.assertEquals(bundlingList.size(), wrap3.size(), 'There is  records assets existed for the  modifying scheme');
                System.assertEquals(wrap3[0].isSelected, true, 'already existed asset in the scheme.Hence isSelected is true');
                System.assertEquals(wrap3[0].assetObj.Id, bundlingList[0].Asset__c, 'Asset is same for the modyfing scheme');

                VME_VINMixCtrlWrapper wrap = new VME_VINMixCtrlWrapper();
                List < VME_VINMixCtrlWrapper > wrap4 = VME_VINMixCtrl.getVINBasedOnName( schemeObj.Id, VME_Constants.REVISE_VME_MSG, retailer.Id, vmeCamp);
                System.assertEquals(wrap4[0].isSelected, false, ' asset is not existed in the scheme.Hence isSelected is true in the case of revising scheme');
                System.assertNotEquals(wrap4[0].assetObj.Id, bundlingList[0].Asset__c, 'Asset is not existed asset in the scheme');
                System.assertEquals(wrap4[0].assetObj.Id, astList[0].Id, 'Asset is not existed for the revising scheme');

                List < VME_VINMixCtrlWrapper > wrap5 = VME_VINMixCtrl.getVINBasedOnName( schemeObj.Id, VME_Constants.MODIFY_VME_MSG, retailer.Id, vmeCamp);
                System.assertEquals(wrap5[0].assetObj.Id, astList[0].Id, 'Asset is existed for the modifying scheme');

                List < VME_VINMixCtrlWrapper > wrap6 = VME_VINMixCtrl.getVINBasedOnName( schemeObj.Id, 'test', retailer.Id, vmeCamp);
                System.assertEquals(bundeligAstList.size() + astList.size(), wrap6.size(), 'All the retailers having test in there name');

                for (VME_VINMixCtrlWrapper obj: wrap3) {
                        obj.isSelected = false;
                }
                //deleting bundling below method
                String result = VME_VINMixCtrl.saveVINMixRecords(wrap3, schemeObj.Id);
                List < VME_Bundling__c > updatedBundeling = [Select Id, Asset__c from VME_Bundling__c where VME_Scheme__c = : schemeObj.Id];
                System.assertEquals(updatedBundeling.size(), 0, 'all existed bundeling got deleted successfully');
                System.assertEquals(result, VME_Constants.SUCCESS_MSG, 'Successfully done');

                String negativeResult = VME_VINMixCtrl.saveVINMixRecords(wrap3, astList[0].Id);
                System.assertNotEquals(negativeResult, VME_Constants.SUCCESS_MSG, 'Exception Occurs');

                String result1 = VME_VINMixCtrl.saveVINMixRecords(wrap2, schemeObj.Id);
                List < VME_Bundling__c > createdBundeling = [Select Id, Asset__c from VME_Bundling__c where VME_Scheme__c = : schemeObj.Id];
                System.assertEquals(createdBundeling[0].Asset__c, bundeligAstList[0].Id, 'new bundeling got created with the product whatever you selected');
                System.assertEquals(result1, VME_Constants.SUCCESS_MSG, 'Successfully done');

                String negativeResult1 = VME_VINMixCtrl.saveVINMixRecords(wrap2, astList[0].Id);
                System.assertNotEquals(negativeResult1, VME_Constants.SUCCESS_MSG, 'Exception Occurs');

                 VME_Category_Adjustment_Ctrl.VMECampaignWrapper updatedWrapper =VME_VINMixCtrl.getUpdatedWrapperofCurrentVME(schemeObj.VME_Campaign__c);
                System.assertEquals(updatedWrapper.vmeCampaignWrap.VME_External_ID__c, schemeObj.VME_Campaign__r.VME_External_ID__c, 'Campaign is returned in the wrapper');

                String result2 =VME_VINMixCtrl.deleteL3(schemeObj.Id);
                System.assertEquals(result2, VME_Constants.SUCCESS_MSG, 'Successfully done');
              
                Test.stopTest();
        }
}