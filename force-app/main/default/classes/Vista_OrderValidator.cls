public class Vista_OrderValidator {
    
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
                if(newOrder.MetaOrderNumber == null || newOrder.MetaOrderNumber == '' || newOrder.EventCode == null || newOrder.EventCode == '')
                {
                    throw new InvalidVistaDataException('One or more mandatory fields were missing information. Enter the mandatory information, and retry.');
                }
                List<string> datesToValidate = this.GetDateFieldsToValidate(newOrder);
                ValidateDates(datestoValidate);
            }
        }
    }
    
    @testVisible private List<string> GetDateFieldsToValidate(Vista_OrderService.VehicleOrder newOrder)
    {
        List<string> datesToTry = new List<string>();
        if(newOrder != null && newOrder.Manufacture != null)
        {
            if(newOrder.Manufacture.LastDayForSpecificationChange != null)
            {
                datesToTry.add(newOrder.Manufacture.LastDayForSpecificationChange);
            }
            if(newOrder.Manufacture.Scheduling != null && newOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate != null)
            {
                datesToTry.add(newOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate);
            }
            if(newOrder.Manufacture.Scheduling != null && newOrder.Manufacture.Scheduling.AcceptedDeliveryDate != null)
            {
                datesToTry.add(newOrder.Manufacture.Scheduling.AcceptedDeliveryDate);
            }
        }
        return datesToTry;
    }
    
    @testVisible private void ValidateDates(List<string> datesToValidate)
    {
        for(string dateString : datesToValidate)
        {
            try
            {
                Date newDate = Date.valueOf(dateString);
            }
            catch(System.TypeException e)
            {
                throw new InvalidVistaDataException('One or more mandatory fields were missing information. Enter the mandatory information, and retry.');
            }
        }
    }
    
    public class InvalidVistaDataException extends Exception
    {        
    }

}