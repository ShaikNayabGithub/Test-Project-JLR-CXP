@isTest
public class Vista_Test_OrderBuilder {
    /*
    static testMethod void buildBasicOrder_ReturnsOrderWithNumberORNUMIfORNUMPassedIn()
    {
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.MetaOrderNumber = 'ORNUM';
        recGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recGroup.VistaVehicleOrder.Manufacture.LastDayForSpecificationChange = '2016-07-07';
        
        Vista_OrderBuilder orderBuilder = new Vista_OrderBuilder();
        Order result = orderBuilder.buildBasicOrder(recGroup);
        
        system.assertEquals('ORNUM', result.Vista_Order_Number__c);
    }
    
    static testMethod void parseEffectiveDate_Returns12Jan2016_If2016_01_12T12_00_18Passed()
    {
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.EventDateTime = '2016-01-12T12:00:18';
        
        Vista_OrderBuilder orderBuilder = new Vista_OrderBuilder();
        Date result = orderBuilder.parseEffectiveDateFromEventDateTime(recGroup.VistaVehicleOrder.EventDateTime);
        
        Date expectedDate = Date.newInstance(2016, 01, 12);
        
        system.assertEquals(expectedDate, result);
    }
    
    static testMethod void setOrderStatus_ReturnsOrderWithDraft_IfDraftPassedIn()
    {
        Account testAcc = new Account(Name = 'newAcc');
        insert testAcc;
        Order newOrder = new Order(AccountId = testAcc.Id, status = 'Deleted', EffectiveDate = Date.today(),
                                  	Vista_Order_Number__c = 'ornum');
        insert newOrder;
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder   = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.EventCode  = 'CONFIRMOK';
        
        Vista_OrderBuilder orderBuilder = new Vista_OrderBuilder();
        Order result = orderBuilder.setOrderStatus(newOrder, 'Draft', 'ornum', recGroup);
        
        system.assertEquals('Draft', result.Status);
    }
    
    static testMethod void updateOrderDetailsFromRequest_UpdatesPlanedDeliveryDate_IfPassed()
    {
        Account testAcc = new Account(Name = 'newAcc');
        insert testAcc;
        Order newOrder = new Order(AccountId = testAcc.Id, status = 'Deleted', EffectiveDate = Date.today());
        insert newOrder;
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recGroup.VistaVehicleOrder.Manufacture.LastDayForSpecificationChange = '2016-07-07';
        recGroup.VistaVehicleOrder.Manufacture.Scheduling = new Vista_OrderService.Scheduling();
        recGroup.VistaVehicleOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate = '2016-08-12';
        
        Vista_OrderBuilder orderBuilder = new Vista_OrderBuilder();
        Order result = orderBuilder.updateOrderDetailsFromRequest(recGroup, newOrder);
        Date expected = Date.newInstance(2016, 08, 12);
        
        system.assertEquals(expected, result.Planned_Delivery_Date__c);
    }
    
    static testMethod void ActivateNewOrder_ReturnsOrderWithStatusFulfilled_GiveHANDOVERCode()
    {
        Order newOrder  = new Order(Status = 'Draft');
        Vista_OrderBuilder orderBuilder = new Vista_OrderBuilder();
        
        Order result = orderBuilder.ActivateNewOrder(newOrder,  'HANDOVER');
        system.assertEquals('Fulfilled', result.Status);
    }
*/
}