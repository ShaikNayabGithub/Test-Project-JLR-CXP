public class Vista_AssetNonSpecSetter {
    private final Vista_Date_Adapter dateAdapter;


    public Vista_AssetNonSpecSetter(Vista_Date_Adapter dateAdapter)
    {
        this.dateAdapter = dateAdapter;
    }


    public void Set(Asset asset, Vista_RecordGroup request)
    {
        if(request.VistaVehicleOrder.Misc != null) {
            asset.Vista_Status__c = request.VistaVehicleOrder.Misc.CommonStatusPoint;
        }
        if(request.VistaVehicleOrder.Specification != null) {
            asset.Description_Group_Id__c = request.VistaVehicleOrder.Specification.DescriptionGroupId;
        }
        if(request.VistaVehicleOrder.Contract != null) {
            asset.Vista_Contract_Number__c = request.VistaVehicleOrder.Contract.ContractNumber;
        }
        if(request.VistaVehicleOrder.Registration != null) {
        
            if(asset.Registration_Number__c==null && request.VistaVehicleOrder.Registration.RegistrationNo!=null)
                asset.Registration_Number__c = request.VistaVehicleOrder.Registration.RegistrationNo;
            
        }
        
          if(request.VistaVehicleOrder.EventCode=='CANHDOVER' ){
              
          
              if(request.VistaVehicleOrder.EventDateTime!=null && request.VistaVehicleOrder.Misc.CommonStatusPoint=='Customer Handover'){
                  Vista_Date_Adapter vsa = new Vista_Date_Adapter(); 
                  asset.handover_date__c= (Date)vsa.Parse(request.VistaVehicleOrder.EventDateTime); 
              }    
              else if(request.VistaVehicleOrder.Misc.CommonStatusPoint=='Arrived at Dealer'){
                  asset.Handover_Date__c=null;  
              }
              
          }    
        else    
            if(request.VistaVehicleOrder.Customer != null && request.VistaVehicleOrder.EventCode!='CANHDOVER' &&  
                 String.isNotBlank(request.VistaVehicleOrder.Customer.CustomerHandoverDate)) {
                 asset.Handover_Date__c = this.dateAdapter.Parse(request.VistaVehicleOrder.Customer.CustomerHandoverDate);
            }    
    }        
    
}