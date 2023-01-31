public class Vista_AssetBuilder_HANDOVER extends Vista_AssetBuilder_A {
    private final Vista_Date_Adapter dateAdapter;


    public Vista_AssetBuilder_HANDOVER(Vista_AssetNonSpecSetter nonSpecSetter, Vista_AssetSpecSetter specSetter, 
            Vista_Date_Adapter dateAdapter)
    {
        super(nonSpecSetter, specSetter);
        this.EventCode = Vista_EventCodes.HANDOVER;
        this.dateAdapter = dateAdapter;
    }
    

    protected override void Build(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection)
    {
        if(request.VistaVehicleOrder.Customer != null && 
                String.isNotBlank(request.VistaVehicleOrder.Customer.CustomerHandoverDate)) {
            asset.Handover_Date__c = this.dateAdapter.Parse(request.VistaVehicleOrder.Customer.CustomerHandoverDate);
        }

       if(String.isBlank(asset.Registration_Number__c) && request.VistaVehicleOrder.Registration != null && request.VistaVehicleOrder.Registration.RegistrationNo!=null && !String.isblank(request.VistaVehicleOrder.Registration.RegistrationNo)) {
            asset.Registration_Number__c = request.VistaVehicleOrder.Registration.RegistrationNo;
        }
    }
}