@isTest
public class Vista_Test_RequestToRecordGroup_Adapter {
	/*static testMethod void getRecordGroupFromVehicleOrder_ReturnsRecordGroupWithVehicleOrder()
    {
        Vista_OrderService.VehicleOrder newOrder = new Vista_OrderService.VehicleOrder();
        Vista_Request__c vistaReq = new Vista_Request__c();
        
        Vista_RequestToRecordGroup_Adapter requestAdapter = new Vista_RequestToRecordGroup_Adapter();
        Vista_RecordGroup result = requestAdapter.GetRecordGroupFromVehicleOrder(newOrder, vistaReq);
        
        system.assertEquals(vistaReq, result.request);
    }
    
    static testMethod void parseVehicleOrderJSON_ReturnsOrderWithNumberORNUM_WhenORNUMPassedInJSON()
    {
        string mockJSON = '[{"Vehicle":{"VIN":"VIN12","VehicleId":"vehId","ShortVIN":"svi","EngineNumber":"engineNo","ChassisNumber":"ChassisNo"},"Status":{"BrandStatusPoint":"statuspoint"},"specification":{"SpecificationMarket":"specMarket","Features":[{"OptionalityIndicator":"oppInd","FeatureType":"featureType","FeatureCode":"featureCode"}]},"ShippingData":null,"Registration":null,"Misc":{"CommonStatusPoint":"Draft"},"MetaOrderNumber":"ORNUM","Manufacture":{"Scheduling":{"FirstPlannedDeliveryDate":"2016-09-22","CurrentPlannedDeliveryDate":"2016-09-22","CurrentPlannedBuildDate":"2016-09-22","BrandCurrentPlannedDeliveryDate":"2016-09-22","AsapIndicator":"ind","AllocationPeriodStartDate":"2016-09-22","AllocationPeriodEndDate":"2016-09-22","AcceptedDeliveryDate":"2016-09-22","AcceptedBuildDate":"2016-09-22"},"LastDayForSpecificationChange":"2016-09-22","FactoryCompleteDate":"2016-09-22"},"EventDateTime":"2016-10-28T12:00:18","Eventcode":"NONSPEC","Distribution":{"DistributionChannel":{"PartnerUniqueID":"abc"}},"Customer":null,"Contract":null,"DescriptionGroupID":"5000281393"}]';
        
        Vista_RequestToRecordGroup_Adapter requestAdapter = new Vista_RequestToRecordGroup_Adapter();
        List<Vista_OrderService.VehicleOrder>  results = requestAdapter.ParseVehicleOrderFromJSON(mockJSON);
        
        system.assertEquals(results[0].MetaOrderNumber, 'ORNUM');
    }
    
    static testMethod  void Adapt_ReturnsListOf2RecordGroups_WhenDataFor2PassedIn()
    {
        Vista_Request__c vistaReq = new Vista_Request__c();
        vistaReq.Vehicle_Orders__c = '[{"Vehicle":{"VIN":"VIN12","VehicleId":"vehId","ShortVIN":"svi","EngineNumber":"engineNo","ChassisNumber":"ChassisNo"},"Status":{"BrandStatusPoint":"statuspoint"},"specification":{"SpecificationMarket":"specMarket","Features":[{"OptionalityIndicator":"oppInd","FeatureType":"featureType","FeatureCode":"featureCode"}]},"ShippingData":null,"Registration":null,"Misc":{"CommonStatusPoint":"Draft"},"MetaOrderNumber":"ORNUM1","Manufacture":{"Scheduling":{"FirstPlannedDeliveryDate":"2016-09-22","CurrentPlannedDeliveryDate":"2016-09-22","CurrentPlannedBuildDate":"2016-09-22","BrandCurrentPlannedDeliveryDate":"2016-09-22","AsapIndicator":"ind","AllocationPeriodStartDate":"2016-09-22","AllocationPeriodEndDate":"2016-09-22","AcceptedDeliveryDate":"2016-09-22","AcceptedBuildDate":"2016-09-22"},"LastDayForSpecificationChange":"2016-09-22","FactoryCompleteDate":"2016-09-22"},"EventDateTime":"2016-10-28T12:00:18","Eventcode":"NONSPEC","Distribution":{"DistributionChannel":{"PartnerUniqueID":"abc"}},"Customer":null,"Contract":null,"DescriptionGroupID":"5000281393"}]';
		Vista_Request__c vistaReq2 = new Vista_Request__c();
        vistaReq2.Vehicle_Orders__c = '[{"Vehicle":{"VIN":"VIN12","VehicleId":"vehId","ShortVIN":"svi","EngineNumber":"engineNo","ChassisNumber":"ChassisNo"},"Status":{"BrandStatusPoint":"statuspoint"},"specification":{"SpecificationMarket":"specMarket","Features":[{"OptionalityIndicator":"oppInd","FeatureType":"featureType","FeatureCode":"featureCode"}]},"ShippingData":null,"Registration":null,"Misc":{"CommonStatusPoint":"Draft"},"MetaOrderNumber":"ORNUM2","Manufacture":{"Scheduling":{"FirstPlannedDeliveryDate":"2016-09-22","CurrentPlannedDeliveryDate":"2016-09-22","CurrentPlannedBuildDate":"2016-09-22","BrandCurrentPlannedDeliveryDate":"2016-09-22","AsapIndicator":"ind","AllocationPeriodStartDate":"2016-09-22","AllocationPeriodEndDate":"2016-09-22","AcceptedDeliveryDate":"2016-09-22","AcceptedBuildDate":"2016-09-22"},"LastDayForSpecificationChange":"2016-09-22","FactoryCompleteDate":"2016-09-22"},"EventDateTime":"2016-10-28T12:00:18","Eventcode":"NONSPEC","Distribution":{"DistributionChannel":{"PartnerUniqueID":"abc"}},"Customer":null,"Contract":null,"DescriptionGroupID":"5000281393"}]';
        
        List<Vista_Request__c> requests = new List<Vista_Request__c>{vistaReq, vistaReq2};
        
        Vista_RequestToRecordGroup_Adapter requestAdapter = new Vista_RequestToRecordGroup_Adapter();
        List<Vista_RecordGroup> results = requestAdapter.Adapt(requests);
        
        system.assertEquals(2, results.size());
            
    }
      */ 
}