/*****************************************************
 *  Name        : VME_BatchClassToEndOldSchemesTest
 *  
 *  Company     : ETMarlabs
 *    
 *  Purpose     : Test class To end old schemes - Batch
 * 
 *  Developer   : Tejashree J
 *
 *  Created Date: 01/05/2019
 *
 *  Modified    : 09/07/2019 BY Tejashree J
 *****************************************************/
@isTest
private class VME_BatchClassToEndOldSchemesTest {
        public static Vehicle_Specification__c brand_init;
        public static Product2 prod;
        public static Campaign qmspRec;
        public static VME_Campaign__c vmeCamp;
        @testSetup public static void instantiation() {
                brand_init = VME_TestDataUtilityClass.vehicle_Spec_init('Jaguar');
                insert brand_init;
                prod = VME_TestDataUtilityClass.CreateModelProduct('XJ', '5000341196', 'XE');
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
        @isTest static void successful_scheme_Update() {
            	VME_Campaign__c vmeCamp = [Select id,VME_Brand__c,QMSP_Campaign__c from VME_Campaign__c LIMIT 1];
                Date yesterday = Date.today().addDays(-1);
                List < VME_Schemes__c > lstSchemes = new List < VME_Schemes__c > ();
                VME_Schemes__c schm1 = VME_TestDataUtilityClass.vme_Schemes_Init();
                schm1.VME_End_Date__c = yesterday;
                schm1.VME_Campaign__c = vmeCamp.Id;
                schm1.VME_Available_for_Claims__c = false;
                insert schm1;
                VME_Schemes__c schm2 = VME_TestDataUtilityClass.vme_Schemes_Init();
                schm2.VME_Volume__c = 2;
                schm2.VME_End_Date__c = yesterday;
                schm2.VME_Campaign__c = vmeCamp.Id;
                schm2.VME_Available_for_Claims__c = false;
                insert schm2;
                lstSchemes.add(schm1);
                lstSchemes.add(schm2);
                Test.startTest();
                VME_BatchClassToEndOldSchemes obj = new VME_BatchClassToEndOldSchemes();
                DataBase.executeBatch(obj);
                Test.stopTest();
                List < VME_Schemes__c > schmAssertionList = [Select id, Name, VME_InActive__c, VME_Revise_Check__c, VME_Volume__c,
                        VME_Consumed_Volume__c from VME_Schemes__c where VME_End_Date__c = : yesterday
                ];
                System.assertEquals(schmAssertionList[0].VME_InActive__c, true, 'Checking whether the batch class has made the Scheme Inactive or not');
                System.assertEquals(schmAssertionList[0].VME_Revise_Check__c, true, 'Checking whether the batch class has made the Scheme Revise check to true or not');
                System.assertEquals(schmAssertionList[1].VME_Volume__c, schmAssertionList[1].VME_Consumed_Volume__c, 'Checking whether the batch class has made the volume on Scheme same as that of the Consumed Volume');
        }
        @isTest static void schedulerTest() {
            	VME_Campaign__c vmeCamp = [Select id,VME_Brand__c,QMSP_Campaign__c from VME_Campaign__c LIMIT 1];
                String CRON_EXP = '0 05 00 * * ?';
                Date yesterday = Date.today().addDays(-1);
                List < VME_Schemes__c > lstSchemes = new List < VME_Schemes__c > ();
                VME_Schemes__c schm1 = VME_TestDataUtilityClass.vme_Schemes_Init();
                schm1.VME_End_Date__c = yesterday;
                schm1.VME_Campaign__c = vmeCamp.Id;
                insert schm1;
                VME_Schemes__c schm2 = VME_TestDataUtilityClass.vme_Schemes_Init();
                schm2.VME_End_Date__c = yesterday;
                schm2.VME_Campaign__c = vmeCamp.Id;
                insert schm2;
                lstSchemes.add(schm1);
                lstSchemes.add(schm2);
                Test.startTest();
                String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new VME_BatchClassToEndOldSchemesScheduler());
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
                System.assertEquals(CRON_EXP, ct.CronExpression, 'Checking whether the scheduled job has the required CRON expression');
                System.assertEquals(0, ct.TimesTriggered, 'Checking whether the job is scheduled');
                Test.stopTest();
        }
        @isTest static void scheduledTestRerun() {
                Test.startTest();
                String batchid = VME_BatchClassToEndOldSchemesScheduler.scheduleMe();
                System.debug(batchid);
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : batchid];
                System.assertEquals(0, ct.TimesTriggered, 'Checking whether the job is scheduled or not');
                Test.stopTest();
        }
}