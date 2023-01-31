@isTest
public class Vista_OrderService_Test {
	static testmethod void UpsertVistaOrders_InsertsVistaRequest_GivenValidOrder()
    {
    	List<Vista_OrderService.ExportDetails> exportDetails = new List<Vista_OrderService.ExportDetails>();
        Vista_OrderService.ExportDetails vistaExport = BuildValidVistaExport();
        exportDetails.add(vistaExport);
        
        system.debug('@@@@ 1'+exportDetails);
        
        Vista_OrderService.UpsertVistaOrders(exportDetails);
        
        Integer retrievedRequestCount = [Select COUNT() From Vista_Request__c];
        
        System.AssertEquals(1, retrievedRequestCount);
    }
    
    static testMethod void UpsertVistaOrders_ReturnsTechnicalErrorCode_GivenInvalidOrder()
    {
        List<Vista_OrderService.ExportDetails> exportDetails = new List<Vista_OrderService.ExportDetails>();
        Vista_OrderService.ExportDetails vistaExport = BuildValidVistaExport();
        vistaExport.VehicleOrders = new List<Vista_OrderService.VehicleOrder>();
        Vista_OrderService.VehicleOrder vehicleOrder = new Vista_OrderService.VehicleOrder();
        vistaExport.VehicleOrders.Add(vehicleOrder);
        exportDetails.add(vistaExport);
        
        Vista_OrderService.Response response = Vista_OrderService.UpsertVistaOrders(exportDetails);
        
        System.AssertEquals(System.Label.Vista_DataErrorCode, response.ErrorCode);
    }
    
    static testMethod void UpsertVistaOrders_ReturnsResponseWithIsSuccessFalse_GenericExceptionThrown()
    {
        Vista_OrderService.ExportDetails details = new Vista_OrderService.ExportDetails();
        List<Vista_OrderService.ExportDetails> exportDetails = new List<Vista_OrderService.ExportDetails>{details};
        Vista_OrderService.Response response = Vista_OrderService.UpsertVistaOrders(exportDetails);
        
        system.assertEquals(false, response.isSuccess);
    }


    private static Vista_OrderService.ExportDetails BuildValidVistaExport()
    {
        Vista_OrderService.ExportDetails vistaExport = new Vista_OrderService.ExportDetails();
        list<Vista_OrderService.VehicleOrder> vistaVehOrder = new list<Vista_OrderService.VehicleOrder>();
        Vista_OrderService.Distribution vistaDist = new Vista_OrderService.Distribution();
        Vista_OrderService.VehicleOrder vistaVehOrderobj = new Vista_OrderService.VehicleOrder();
        Vista_OrderService.DistributionChannel vistaDistCh = new Vista_OrderService.DistributionChannel();
        vistaDistCh.BrandOrderType='Test';
        vistaDistCh.DistributorUniqueID='TT';
        vistaDistCh.PartnerUniqueID='HKS';
        vistaDist.DistributionChannel=vistaDistCh;
        vistaVehOrderobj.Distribution=vistaDist;
        vistaVehOrderobj.MetaOrderNumber = '1';
        vistaVehOrderobj.EventCode = 'DELETE';
        vistaVehOrder.add(vistaVehOrderobj);
        //vistaExport.Serial = 1234;
        vistaExport.Market = 'te';
        vistaExport.MarketDescription = 'MarketDescription';
        vistaExport.Brand = 'Test';
        vistaExport.VehicleOrders=vistaVehOrder;
        
        system.debug('@@@ '+vistaExport.VehicleOrders);
        return vistaExport;
    }
}