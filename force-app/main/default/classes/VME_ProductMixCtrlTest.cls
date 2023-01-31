@isTest
public class VME_ProductMixCtrlTest {
        @TestSetup
        static void createData() {
                Vehicle_Specification__c jaguarVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
                Insert jaguarVehicle;
                Vehicle_Specification__c landRoverVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Land Rover');
                Insert landRoverVehicle;
                Product2 modelProductJag = VME_TestDataUtilityClass.CreateModelProduct('F-PACE', 'R8', 'F-PACE');
                modelProductJag.Make__c = jaguarVehicle.Id;
                Insert modelProductJag;
                Product2 derivativeProductJag = VME_TestDataUtilityClass.CreateDerivativeProduct('F-Pace 3.0', '5000291712', 'F-PACE');
                derivativeProductJag.Make__c = jaguarVehicle.Id;
                derivativeProductJag.Model__c = modelProductJag.Id;
                Insert derivativeProductJag;
                //Create Product of Model Type Land Rover
                Product2 modelProductLR = VME_TestDataUtilityClass.CreateModelProduct('L494 - Range Rover Sport', 'F5', 'RANGE ROVER SPORT');
                modelProductLR.Make__c = landRoverVehicle.Id;
                Insert modelProductLR;
                Product2 derivativeProductLR = VME_TestDataUtilityClass.CreateDerivativeProduct('RangeRover Product', '500029089', 'L494 - Range Rover Sport');
                derivativeProductLR.Make__c = landRoverVehicle.Id;
                derivativeProductLR.Model__c = modelProductLR.Id;
                Insert derivativeProductLR;
                Campaign campaignObj = VME_TestDataUtilityClass.init_QMSP_Record();
                campaignObj.VME_Brand__c = jaguarVehicle.Id;
                campaignObj.QMSP_Model__c = modelProductJag.Id;
                insert campaignObj;
                VME_Campaign__c vmeCampObj = VME_TestDataUtilityClass.vme_Camp_init();
                vmeCampObj.QMSP_Campaign__c = campaignObj.Id;
                vmeCampObj.VME_Brand__c = jaguarVehicle.Id;
                vmeCampObj.VME_Model__c = modelProductJag.Id;
                insert vmeCampObj;

                Id parentRecordTypeId = Schema.Sobjecttype.VME_Schemes__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId(); 
              
                VME_Schemes__c schemeObj = VME_TestDataUtilityClass.vme_Schemes_Init();
                schemeObj.VME_Campaign__c = vmeCampObj.Id;
                schemeObj.recordTypeId = parentRecordTypeId;
                insert schemeObj;
                VME_Bundling__c bundeling = new VME_Bundling__c();
                bundeling.VME_Model_Derivative__c = derivativeProductJag.Id;
                bundeling.VME_Scheme__c = schemeObj.Id;
                insert bundeling;
        }
        @isTest
        static void testmethod1() {
                 Test.startTest();
                VME_Schemes__c schemeObj = [Select Id,VME_Campaign__c,VME_Campaign__r.VME_External_ID__c, VME_Campaign__r.VME_Model__c from VME_Schemes__c LIMIT 1];
                List < Product2 > proList = [Select Id, ProductCode from Product2 where ProductCode = '5000291712'];
                List < Product2 > modelProList = [Select Id, ProductCode from Product2 where Name = : 'F-PACE'];
                List < Product2 > proListLR = [Select Id, ProductCode from Product2 where ProductCode = '500029089'];
                List < Product2 > modelLRProList = [Select Id, ProductCode from Product2 where Name = : 'L494 - Range Rover Sport'];
                List < VME_Bundling__c > bundeling = [Select Id, VME_Model_Derivative__c from VME_Bundling__c where VME_Scheme__c = : schemeObj.Id];
               
                List < String > fuelData = VME_Utility_Class.getAllPickListValue('Product2', 'Fuel_Type_Alternative__c').values();
                Set < String > doorData = VME_Utility_Class.getAllPickListValue('Product2', 'Body_Style__c').keySet();
                List<String> doorDataList = new List<String>();
                doorDataList.addAll(doorData);
                VME_ProductMixFilterWrapper filterWrapper = VME_ProductMixCtrl.getFilterValues(schemeObj.Id, schemeObj.Id);
                System.assertEquals(true, filterWrapper.fuelTypeValuesList.contains(fuelData[0]), 'Checking fuel details are present in the filtered list');
                System.assertEquals(true, filterWrapper.doorsValuesList.containsKey(doorDataList[0]), 'Checking door details are present in the filtered list');
                System.assertEquals(true, filterWrapper.modelValue.equals(schemeObj.VME_Campaign__r.VME_Model__c), 'Checking model id is present in the filtered list');
                System.assertNotEquals(filterWrapper, null, 'Get all the filter crietria from the product metadata fields');
                //when I am refining the selected product on L3
                List < VME_ProductMixReqWrapper > wrap2 = VME_ProductMixCtrl.searchProducts(modelLRProList[0].Id, 'RangeRover', null, null, null, null, null, VME_Constants.MODIFY_VME_MSG, String.valueOf(schemeObj.Id));
                System.assertEquals(proListLR[0].ProductCode, wrap2[0].productObj.ProductCode, 'The searched product and existed products are same');
                //when I am revising the L3 and refinding the selected product on L3
                List < VME_ProductMixReqWrapper > wrap1 = VME_ProductMixCtrl.searchProducts(modelProList[0].Id, 'F-Pace', null, null, null, null, null, VME_Constants.REVISE_VME_MSG, String.valueOf(schemeObj.Id));
                System.assertEquals(proList[0].ProductCode, wrap1[0].productObj.ProductCode, 'The searched product and existed products are same ');
                System.assertEquals(wrap1[0].isSelected, true, 'The product already have the bundeling(preselected product)');
                //Adding product into L3
                List < VME_ProductMixReqWrapper > wrap4 = VME_ProductMixCtrl.searchProducts(modelProList[0].Id, 'F-PACE', null, null, null, null, null, 'test', String.valueOf(schemeObj.Id));
                System.assertEquals(wrap4[0].isSelected, false, 'The new product   selected');
                //Adding product into L3 but product not present in org
                List < VME_ProductMixReqWrapper > wrap3 = VME_ProductMixCtrl.searchProducts(modelProList[0].Id, 'test', 'test', 'test', 'test', 'test', 'test', 'test', String.valueOf(schemeObj.Id));
                System.assertEquals(wrap3.size(), 0, 'no product are there with the test name and no crietra matched');
                //Adding record id into lightning wrapper as id is not coming from lightning wrapper.
                for (VME_ProductMixReqWrapper obj: wrap2) {
                        obj.recordId = bundeling[0].Id;
                }
                String result = VME_ProductMixCtrl.saveProductMixRecords(wrap2, schemeObj.Id, VME_Constants.REVISE_VME_MSG);
                List < VME_Bundling__c > updatedBundeling = [Select Id, VME_Model_Derivative__c from VME_Bundling__c where VME_Scheme__c = : schemeObj.Id];
                System.assertEquals(updatedBundeling.size(), 0, 'all existed bundeling got deleted successfully');
                System.assertEquals(result, VME_Constants.SUCCESS_MSG, 'Successfully done');

                String negativeResult = VME_ProductMixCtrl.saveProductMixRecords(wrap1, modelProList[0].Id, VME_Constants.REVISE_VME_MSG);
                System.assertNotEquals(negativeResult, VME_Constants.SUCCESS_MSG, 'Exception Occurs');

                String result1 = VME_ProductMixCtrl.saveProductMixRecords(wrap1, schemeObj.Id, VME_Constants.REVISE_VME_MSG);
                List < VME_Bundling__c > createdBundeling = [Select Id, VME_Model_Derivative__c from VME_Bundling__c where VME_Scheme__c = : schemeObj.Id];
                System.assertEquals(createdBundeling[0].VME_Model_Derivative__c, proList[0].Id, 'new bundeling got created with the product whatever you selected');
                System.assertEquals(result1, VME_Constants.SUCCESS_MSG, 'Successfully done');

                String negativeResult1 = VME_ProductMixCtrl.saveProductMixRecords(wrap2, modelProList[0].Id, VME_Constants.REVISE_VME_MSG);
                System.assertNotEquals(negativeResult1, VME_Constants.SUCCESS_MSG, 'Exception Occurs');
                //calling constructor coverage
                VME_ProductMixReqWrapper wrap = new VME_ProductMixReqWrapper();

                VME_Category_Adjustment_Ctrl.VMECampaignWrapper updatedWrapper =VME_ProductMixCtrl.getUpdatedWrapperofCurrentVME(schemeObj.VME_Campaign__c);
                System.assertEquals(updatedWrapper.vmeCampaignWrap.VME_External_ID__c, schemeObj.VME_Campaign__r.VME_External_ID__c, 'Campaign is returned in the wrapper');
                Test.stopTest();
        }
}