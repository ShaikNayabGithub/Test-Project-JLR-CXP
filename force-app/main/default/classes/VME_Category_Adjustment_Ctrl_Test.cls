/*--
||  Name : VME_Category_Adjustment_Ctrl_Test.apxc
||  Author: Tamanna Shukla
||  Purpose: VME_Category_Adjustment_Ctrl test class 
||  Created Date : 29/04/2018
--*/
@isTest
public class VME_Category_Adjustment_Ctrl_Test {
    @testSetup
    public static void dataCreation() {
       User testUser = VME_TestDataUtilityClass.createSalesforceUser();
        Insert testUser;
        System.runAs(testUser) {

           Account retailer = VME_TestDataUtilityClass.createRetailer();
            Insert retailer;

          Vehicle_Specification__c jaguarVehicle = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
          Insert jaguarVehicle;
            
          //Create Product of Model Type Jaguar
          Product2 modelProductJag = VME_TestDataUtilityClass.CreateModelProduct('F-PACE','R8','F-PACE');
          modelProductJag.Make__c = jaguarVehicle.Id;
          Insert modelProductJag;

           //Create QMSP Master Record
            Campaign QMSPObj = VME_TestDataUtilityClass.init_QMSP_Record();
            QMSPObj.Name = 'Q2 - 2019-20 - Jaguar - INDIA';
            QMSPObj.VME_Brand__c = jaguarVehicle.Id;
            QMSPObj.QMSP_Model__c = modelProductJag.Id;
            Insert QMSPObj;

            //Create VME campaign record
            VME_Campaign__c vme_Camp_Object = VME_TestDataUtilityClass.vme_Camp_init();
            vme_Camp_Object.VME_Brand__c = jaguarVehicle.Id;
            vme_Camp_Object.VME_Model__c = modelProductJag.Id;
            vme_Camp_Object.QMSP_Campaign__c = QMSPObj.Id;
            Insert vme_Camp_Object;

             Id childRecordTypeId = Schema.Sobjecttype.VME_Schemes__c.getRecordTypeInfosByName().get('Child').getRecordTypeId();
             Id parentRecordTypeId = Schema.Sobjecttype.VME_Schemes__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
       
             //Create VME Scheme1 record
            VME_Schemes__c vme_Scheme_Obj1 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.Today().addDays(5),Date.Today().addDays(7),40,40,'Parent','Others','Testing1');
            vme_Scheme_Obj1.VME_Campaign__c = vme_Camp_Object.Id;
            Insert vme_Scheme_Obj1;
            
            VME_Schemes__c vme_ChildScheme_Obj = VME_TestDataUtilityClass.vme_Schemes_Init(Date.Today().addDays(5),Date.Today().addDays(7),40,40,'Child','Others','Testing1');
            vme_ChildScheme_Obj.VME_Campaign__c = vme_Camp_Object.Id;
            vme_ChildScheme_Obj.VME_Retailer__c = retailer.Id;
            vme_ChildScheme_Obj.VME_Parent_Scheme__c = vme_Scheme_Obj1.Id;
            Insert vme_ChildScheme_Obj;

             VME_Schemes__c vme_Scheme_Obj2 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.Today().addDays(2),Date.Today().addDays(5),40,40,'Parent','Others','Testing2');
            vme_Scheme_Obj2.VME_Campaign__c = vme_Camp_Object.Id;
            Insert vme_Scheme_Obj2;
            
        }
    }
     public static testMethod void positive_TestMethods(){
        Test.startTest();

               

           Id parentRecordTypeId = Schema.Sobjecttype.VME_Schemes__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
            Id childRecordTypeId = Schema.Sobjecttype.VME_Schemes__c.getRecordTypeInfosByName().get('Child').getRecordTypeId();


        Campaign camp = [Select Id,Market_ID__c,Name, QMSP_Model__c, QMSP_Model__r.Name,QMSP_Quarter__c, VME_Brand__c, Market__c, VME_Fiscal_Year__c,
                QMSP_Model__r.ProductCode,VME_Brand__r.Name  FROM Campaign  Limit 1 ];

          VME_Campaign__c vmeCamp =  [Select Id,Name,CurrencyIsoCode,QMSP_Campaign__c,VME_Category__c,VME_End_Date__c,VME_Sub_Category__c,VME_Start_Date__c,VME_External_ID__c,VME_Country_ISO_Code__c,VME_Adjusted_Budget__c,VME_Adjusted_PU_Amount__c,
                                    VME_Planned_Budget__c,VME_Planned_PU_Amount__c,VME_Planned_Volume__c,VME_Model__c,VME_Adjusted_Volume__c,VME_L2_Adjustment_Reason__c
            from VME_Campaign__c where QMSP_Campaign__c=:camp.Id limit 1];

            List<VME_Schemes__c> schemesList =[SELECT Name,VME_Consumed_Volume__c, CurrencyIsoCode, Id, VME_Start_Date__c, VME_End_Date__c, VME_Campaign__c, VME_JLR_Share__c, VME_PU_Amount__c, VME_Retailer__c, VME_Claims_Available__c, VME_Claims_Approved__c, VME_Total_Amount_Approved__c, VME_Total_Amount_Available__c, VME_InActive__c, VME_Revise_Check__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, VME_Total_VME__c, 
                                           VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, VME_Retailer_Contribution__c, VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c,VME_Retailer__r.Name 
                     from VME_Schemes__c where VME_Campaign__c =:vmeCamp.Id AND recordTypeId=:parentRecordTypeId AND VME_Start_Date__c >TODAY ORDER BY VME_Scheme_Type__c DESC ];

        VME_Category_Adjustment_Ctrl.getAllQMSPRecords(camp.Market__c,vmeCamp.VME_Country_ISO_Code__c,camp.VME_Fiscal_Year__c,camp.VME_Brand__r.Name,camp.QMSP_Quarter__c,camp.QMSP_Model__r.Name+' ('+camp.QMSP_Model__r.ProductCode+')');
        VME_Category_Adjustment_Ctrl.CampaignWrapper wrapperResult= VME_Category_Adjustment_Ctrl.getAllQMSPRecords(camp.Market__c,vmeCamp.VME_Country_ISO_Code__c,camp.VME_Fiscal_Year__c,camp.VME_Brand__r.Name,camp.QMSP_Quarter__c,camp.QMSP_Model__r.Name);
        System.assertNotEquals(wrapperResult,null,'Filter result');
        List<VME_Campaign__c> createdVMECamp = [Select id,VME_Planned_Volume__c from VME_Campaign__c where QMSP_Campaign__c=:camp.Id];
        System.assertEquals(wrapperResult.vmeCampaignWrapList.size(),createdVMECamp.size(),'Total VME counts');
        System.assertEquals(wrapperResult.vmeCampaignWrapList[0].vmeCampaignWrap.Id,createdVMECamp[0].Id,'Correct VME Campaign record is coming or not');


         VME_Category_Adjustment_Ctrl.getUpdatedWrapperofCurrentVME(vmeCamp.Id);

       VME_Category_Adjustment_Ctrl.VMECampaignWrapper wrapperResult1 = VME_Category_Adjustment_Ctrl.saveVMERecord(vmeCamp, System.Label.VME_Edit);  
        System.assertNotEquals(wrapperResult1,null,'Edited record list is not null');
        System.assertEquals(wrapperResult1.vmeCampaignWrap.Id,vmeCamp.Id,'Edited records');
        System.assertEquals(wrapperResult1.vmeCampaignWrap.VME_Planned_Volume__c,vmeCamp.VME_Planned_Volume__c,'After editing  Planned Volume values');
        List<VME_Schemes__c> createdSch =[Select id from VME_Schemes__c where VME_Campaign__c=:vmeCamp.Id AND recordTypeId=:parentRecordTypeId];
        System.assertEquals(wrapperResult1.schemeList.size(), createdSch.size(),'Total scheme count is equal to wrapper filtered scheme records.');

         List<VME_Schemes__c> retailerList = VME_Category_Adjustment_Ctrl.getAllRetailerofScheme(schemesList[0].Id); 
        List<VME_Schemes__c> createdRetailerList =[Select id from VME_Schemes__c where VME_Campaign__c=:vmeCamp.Id AND recordTypeId=:childRecordTypeId AND VME_Parent_Scheme__c=:schemesList[0].Id  AND VME_InActive__c=false];
        System.assertEquals(retailerList.size(),createdRetailerList.size(),'get all the retailer scheme tagged to the scheme');

        VME_Category_Adjustment_Ctrl.schemeRecordToEnd(schemesList[0],true);
        VME_Schemes__c endedSch=   [Select id,VME_InActive__c from VME_Schemes__c where id=:schemesList[0].Id ];
         System.assertEquals(endedSch.VME_InActive__c, true,'Scheme will become inActive');

            VME_Schemes__c scheme1 = new VME_Schemes__c();
            scheme1.VME_Campaign__c = vmeCamp.Id;
            scheme1.VME_JLR_Share__c = 70;
            scheme1.VME_PU_Amount__c =10;
          scheme1.VME_Start_Date__c=Date.Today().addDays(1);
            scheme1.VME_End_Date__c=Date.Today().addDays(2);
             scheme1.recordTypeId = parentRecordTypeId;
            insert scheme1;

               VME_Schemes__c scheme2 = new VME_Schemes__c();
              scheme2.VME_Campaign__c = vmeCamp.Id;
            scheme2.VME_JLR_Share__c = 70;
            scheme2.VME_PU_Amount__c =10;
          scheme2.VME_Start_Date__c=Date.Today().addDays(7);
            scheme2.VME_End_Date__c=Date.Today().addDays(8);
             scheme2.recordTypeId = parentRecordTypeId;
            insert scheme2;


             VME_Schemes__c vme_Scheme_Obj2 = VME_TestDataUtilityClass.vme_Schemes_Init(Date.Today().addDays(2),Date.Today().addDays(5),40,40,'Child','Others','Testing7');
            vme_Scheme_Obj2.VME_Campaign__c = vmeCamp.Id;
            vme_Scheme_Obj2.VME_Parent_Scheme__c = scheme2.Id;
            vme_Scheme_Obj2.VME_InActive__c=false;
            Insert vme_Scheme_Obj2;

            VME_Category_Adjustment_Ctrl.getUpdatedChildSchemeList(vme_Scheme_Obj2,scheme2.Id);
            
             Integer bundlingExisted = VME_Category_Adjustment_Ctrl.getBundeling(scheme1,vmeCamp.VME_Model__c);
             System.assertEquals(bundlingExisted,0,'No bundeling record');
              VME_Category_Adjustment_Ctrl.createBundling(scheme1.Id,vmeCamp.VME_Model__c);
               Integer bundExistedNew = VME_Category_Adjustment_Ctrl.getBundeling(scheme1,vmeCamp.VME_Model__c);
                   System.assertEquals(bundExistedNew,1,'Bundeling record got created');


         VME_Category_Adjustment_Ctrl.getAllRetailerofScheme(scheme1.Id); 

        VME_Category_Adjustment_Ctrl.VMECampaignWrapper wrap3 =VME_Category_Adjustment_Ctrl.saveSplitSchemeRecord(scheme1,schemesList[1]);
         VME_Schemes__c endedScheme=[SELECT Id,VME_InActive__c from VME_Schemes__c where Id=:schemesList[1].Id limit 1];
         System.assertEquals(endedScheme.VME_InActive__c,true,'After ending  the scheme');

         VME_Category_Adjustment_Ctrl.getRecordTypeOfScheme();
       

          VME_Campaign__c currentVME =VME_Category_Adjustment_Ctrl.getCurrentVMECampaign(vmeCamp.Id);
          System.assertEquals(currentVME.name,vmeCamp.Name,'The VME Campaign is same' );
      
        VME_Category_Adjustment_Ctrl.VMECampaignWrapper wrapperResult2 =VME_Category_Adjustment_Ctrl.saveVMERecord(vmeCamp,System.Label.VME_End);
          System.assertNotEquals(wrapperResult2,null,'The  updated wrapper after saving records');
          System.assertEquals(wrapperResult2.schemeList.size(),0,'Ended all schemes.Hence Available scheme List is null' );

        VME_Category_Adjustment_Ctrl.getQuarterInfos();
        VME_Category_Adjustment_Ctrl.getAmountConvertedValue('INR');
       


 
        Test.stopTest();
      }
      public static testMethod void negative_TestMethods(){
        Test.startTest();
        VME_Category_Adjustment_Ctrl.getUserDefaultCurrency();
        VME_Category_Adjustment_Ctrl.CampaignWrapper wrapperResult =VME_Category_Adjustment_Ctrl.getAllQMSPRecords('VME_testRegion','VME_testMarket','VME_testyear','VME_testBrand','VME_testQuarter','VME_testModel');
         System.assertEquals(wrapperResult,null,'Filter values are not yielding any data');
        VME_Campaign__c vmeCamp ;//
        VME_Schemes__c scheme = new VME_Schemes__c();
        try{VME_Category_Adjustment_Ctrl.saveVMERecord(vmeCamp,System.Label.VME_Edit);
            }Catch(Exception e){

            }
        VME_Category_Adjustment_Ctrl.createBundling('test','test');
        VME_Category_Adjustment_Ctrl.getUpdatedChildSchemeList(scheme,'test');
        VME_Category_Adjustment_Ctrl.schemeRecordToEnd(scheme,true);
        VME_Category_Adjustment_Ctrl.endSchemeOnVMECampaignEnd(vmeCamp,System.Label.VME_End);
         VME_Category_Adjustment_Ctrl.VMECampaignWrapper wrap =VME_Category_Adjustment_Ctrl.saveSplitSchemeRecord(scheme,scheme);
         System.assertEquals(wrap,null,'Ended the scheme');
        
        
       Test.stopTest();
    }
    
     public static testMethod void negative_TestMethods1(){
         Test.startTest();
          List<VME_Schemes__c> retailerList =VME_Category_Adjustment_Ctrl.getAllRetailerofScheme('testSchemeId');
           System.assertEquals(retailerList.size(),0,'all the retailer list which is tagged to testSchemeId');
         VME_Campaign__c vmeCamp =VME_Category_Adjustment_Ctrl.getCurrentVMECampaign('testVMEId');
         System.assertEquals(vmeCamp,null,'VME Campaign with id testVMEId');
         VME_Category_Adjustment_Ctrl.getUpdatedWrapperofCurrentVME('testVMEId');
        
         Test.stopTest();
     }
    
    public static testMethod void VME_NewVMECampaignCtrl(){
         Test.startTest();
         List<VME_CXP_Market_Codes__mdt> VME_MarketCodeList = [Select id,Label,Market__c from VME_CXP_Market_Codes__mdt ];
         List<VME_CXP_Brand_Code__mdt> brandCodeMap = [Select Label,Brand_Name__c from VME_CXP_Brand_Code__mdt];
        
        VME_NewVMECampaignCtrl.getAllRecordTypesOfVME();
        Map<String,String> cat_subcatMap =VME_NewVMECampaignCtrl.getCat_SubCat();
          System.assertNotEquals(cat_subcatMap,null,'Category and subcategory from fields');
        Map<String,String> marketMap =VME_NewVMECampaignCtrl.getMarketCode();
        System.assertNotEquals(marketMap,null,'Market code details from fields');
        System.assertEquals(true, marketMap.containsKey(VME_MarketCodeList[0].Market__c), 'Checking the market details are present in the map ');
       
        Map<String,String> brandmap =VME_NewVMECampaignCtrl.getBrandCode();
         System.assertNotEquals(brandmap,null,'Brand code details from fields');
        System.assertEquals(true, brandmap.containsKey(brandCodeMap[0].Brand_Name__c), 'Checking the market details are present in the map ');
       
        VME_NewVMECampaignCtrl.getUserDetails();
          Test.stopTest();
    }
}