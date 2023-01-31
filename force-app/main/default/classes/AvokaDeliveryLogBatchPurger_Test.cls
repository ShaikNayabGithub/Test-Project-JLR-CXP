@isTest
public class AvokaDeliveryLogBatchPurger_Test {
    static testmethod void BatchJob_DoesNotDeleteDelivery_GivenCutOffDateYesterday()
    {
    	AvokaDeliveryLogBatchPurger batchPurger = new AvokaDeliveryLogBatchPurger();
    	batchPurger.cutOffDate = Datetime.now().addDays(-1);
    	
    	avoka__Transact_Delivery__c delivery = new avoka__Transact_Delivery__c(Name='test',avoka__Form_Code__c='t',avoka__Submission_Key__c='t');
    	insert delivery;
    	
    	Test.startTest();
    	Database.executebatch(batchPurger);
    	Test.stopTest();
    	
    	Integer remainingDeliveries = [Select Count() From avoka__Transact_Delivery__c];
    	
    	System.AssertEquals(1, remainingDeliveries);
    }
    
    static testmethod void BatchJob_DeletesDelivery_GivenCutOffDateTomorrow()
    {
    	AvokaDeliveryLogBatchPurger batchPurger = new AvokaDeliveryLogBatchPurger();
    	batchPurger.cutOffDate = Datetime.now().addDays(1);
    	
    	avoka__Transact_Delivery__c delivery = new avoka__Transact_Delivery__c(Name='test',avoka__Form_Code__c='t',avoka__Submission_Key__c='t');
    	insert delivery;
    	
    	Test.startTest();
    	Database.executebatch(batchPurger);
    	Test.stopTest();
    	
    	Integer remainingDeliveries = [Select Count() From avoka__Transact_Delivery__c];
    	
    	System.AssertEquals(0, remainingDeliveries);
    }
}