@isTest
public class ScheduleOpportunityLineItemAssetLink_T  {

    public static testmethod void testScheduler() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('ScheduleOpportunityLineItemAssetLinker', CRON_EXP, new ScheduleOpportunityLineItemAssetLinker() );   
        Test.stopTest();
    }

    public static testmethod void testBatch() {

        OpportunityLineItem oli = TestClass_OppLineItemCreator.CreateOppLineItem();
        oli.Vista_Order_Number__c = '12345';
        insert oli;

        Asset a = TestClass_AssetBuilder.BuildVehicle(true);
        insert a; 

        Vista_Request__c vr = new Vista_Request__c(MetaOrderNumber__c='12345',VIN__c=a.name);
        insert vr;

        system.assertEquals(null,oli.asset__c);

        Test.startTest();
        Database.executeBatch(new ScheduleOpportunityLineItemAssetLinker(),1);
        Test.stopTest();

        oli = [select asset__c from opportunitylineitem where id = : oli.id limit 1];

        system.assertEquals(a.id,oli.asset__c);

    }
     
}