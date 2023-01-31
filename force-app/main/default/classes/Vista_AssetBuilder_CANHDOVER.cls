public class Vista_AssetBuilder_CANHDOVER extends Vista_AssetBuilder_A {
  private final Vista_Date_Adapter dateAdapter;


  public Vista_AssetBuilder_CANHDOVER(Vista_AssetNonSpecSetter nonSpecSetter, Vista_AssetSpecSetter specSetter, 
      Vista_Date_Adapter dateAdapter)
    {
        super(nonSpecSetter, specSetter);
        this.EventCode = Vista_EventCodes.CANHDOVER;
        this.dateAdapter = dateAdapter;
  }
 
  protected override void Build(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection)
  {
           if(request.VistaVehicleOrder.Misc.CommonStatusPoint=='Customer Handover'){
               if(request.VistaVehicleOrder.EventDateTime!=null){
                   Vista_Date_Adapter vsa = new Vista_Date_Adapter(); 
                   asset.handover_date__c= (Date)vsa.Parse(request.VistaVehicleOrder.EventDateTime); 
            }    
            
        }
         else
         if(request.VistaVehicleOrder.Misc.CommonStatusPoint=='Arrived at Dealer')
             asset.Handover_Date__c=null;  
         
    if(String.isBlank(asset.Registration_Number__c) && request.VistaVehicleOrder.Registration != null && request.VistaVehicleOrder.Registration.RegistrationNo!=null && !String.isblank(request.VistaVehicleOrder.Registration.RegistrationNo)) {
            asset.Registration_Number__c = request.VistaVehicleOrder.Registration.RegistrationNo;
        }
  }
}