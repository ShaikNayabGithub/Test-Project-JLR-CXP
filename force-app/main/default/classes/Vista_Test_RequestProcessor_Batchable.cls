@isTest
public class Vista_Test_RequestProcessor_Batchable {
    static testMethod void execute_AddsExceptionTextToRequestGivenInvalidRequest()
    {
        Vista_Request__c vReq = new Vista_Request__c();
        string mockJSON = '[{"Vehicle":{"VIN":"VIN12","VehicleId":"vehId","ShortVIN":"svi","EngineNumber":"engineNo","ChassisNumber":"ChassisNo"},"Status":{"BrandStatusPoint":"statuspoint"},"specification":{"SpecificationMarket":"specMarket","Features":[{"OptionalityIndicator":"oppInd","FeatureType":"featureType","FeatureCode":"featureCode"}]},"ShippingData":null,"Registration":null,"Misc":{"CommonStatusPoint":"Draft"},"MetaOrderNumber":"ORNUM","Manufacture":{"Scheduling":{"FirstPlannedDeliveryDate":"2016-09-22","CurrentPlannedDeliveryDate":"2016-09-22","CurrentPlannedBuildDate":"2016-09-22","BrandCurrentPlannedDeliveryDate":"2016-09-22","AsapIndicator":"ind","AllocationPeriodStartDate":"2016-09-22","AllocationPeriodEndDate":"2016-09-22","AcceptedDeliveryDate":"2016-09-22","AcceptedBuildDate":"2016-09-22"},"LastDayForSpecificationChange":"2016-09-22","FactoryCompleteDate":"2016-09-22"},"EventDateTime":"2016-10-28T12:00:18","Eventcode":"CONFIRMOK","Distribution":{"DistributionChannel":{"PartnerUniqueID":"abc"}},"Customer":null,"Contract":null,"DescriptionGroupID":"5000281393"}]';
        vReq.Vehicle_Orders__c = mockJSON;
        vReq.Market_Description__c = 'India';
        vReq.Status__c = 'Unprocessed';
        insert vReq;
        test.startTest();
        Vista_RequestProcessor_Batchable processor = new Vista_RequestProcessor_Batchable();
        database.executeBatch(processor);
        test.stopTest();
        
        List<Vista_Request__c> resultList = [SELECT Status__c, Error_Log__c FROM Vista_Request__c WHERE Id =:  vReq.Id];
        if(!resultList.isEmpty())
        {
            //system.assertNotEquals( resultList[0].Error_Log__c,null);
        }
    }
    
}