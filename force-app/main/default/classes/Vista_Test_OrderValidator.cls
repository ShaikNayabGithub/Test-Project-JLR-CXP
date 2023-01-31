@isTest
public class Vista_Test_OrderValidator {
    
    static testMethod void GetDateFieldsToValidate_ReturnsListOfDateStrings()
    {
        Vista_OrderService.VehicleOrder newOrder = new Vista_OrderService.VehicleOrder();
        newOrder.Manufacture = new Vista_OrderService.Manufacture();
        newOrder.Manufacture.LastDayForSpecificationChange = '2016-02-03';
        newOrder.Manufacture.Scheduling = new Vista_OrderService.Scheduling();
        newOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate  = '2014-02-12';
        newOrder.Manufacture.Scheduling.AcceptedDeliveryDate = '2017-08-02';
        
        Vista_OrderValidator  validator = new Vista_OrderValidator();
        
        List<string> result = validator.GetDateFieldsToValidate(newOrder);
        
        system.assertEquals(3, result.size());
    }
    
    static testMethod void ValidateDates_ThrowsInvalidVistaDataExceptionGivenInvalidDate()
    {
        List<string> stringList = new List<string>{'bananas'};
        Vista_OrderValidator  validator = new Vista_OrderValidator();
        
        try
        {
            validator.ValidateDates(stringList);
        }
        catch(exception ex)
        {
            system.assert(ex instanceOf Vista_OrderValidator.InvalidVistaDataException);
        }
    }
    
    static testMethod void ValidateRequest_ThrowsException_GivenOrderWithInvalidDate()
    {
        
        Vista_OrderService.VehicleOrder newOrder = new Vista_OrderService.VehicleOrder();
        newOrder.Manufacture = new Vista_OrderService.Manufacture();
        newOrder.Manufacture.LastDayForSpecificationChange = '2016-02-03';
        newOrder.Manufacture.Scheduling = new Vista_OrderService.Scheduling();
        newOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate  = 'apple';
        newOrder.Manufacture.Scheduling.AcceptedDeliveryDate = '2017-08-02';
        Vista_OrderService.ExportDetails exportDetails = new Vista_OrderService.ExportDetails();
        exportDetails.VehicleOrders = new List<Vista_OrderService.VehicleOrder>{newOrder};
        
        Vista_OrderValidator  validator = new Vista_OrderValidator();
        
        try
        {
            validator.ValidateRequest(exportDetails);
        }
        catch(exception ex)
        {
            system.assert(ex instanceOf Vista_OrderValidator.InvalidVistaDataException);
        }

    }
        
        /*
    public void ValidateRequest(Vista_OrderService.ExportDetails exportDetail)
    {
        if(exportDetail.VehicleOrders.isEmpty())
        {
            throw new InvalidVistaDataException('One or more mandatory fields were missing information. Enter the mandatory information, and retry.');
        }
        else
        {
            for(Vista_OrderService.VehicleOrder newOrder : exportDetail.VehicleOrders)
            {
                if(newOrder.MetaOrderNumber == null || newOrder.EventCode == null)
                {
                    throw new InvalidVistaDataException('One or more mandatory fields were missing information. Enter the mandatory information, and retry.');
                }
                List<string> datesToValidate = this.GetDateFieldsToValidate(newOrder);
                ValidateDates(datestoValidate);
            }
        }
    }
*/
}