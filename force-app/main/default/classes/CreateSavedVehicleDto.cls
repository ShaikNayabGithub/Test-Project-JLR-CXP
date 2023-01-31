public with sharing class CreateSavedVehicleDto {
    public CreateSavedVehicleInterface createSavedVehicle;
    public VehicleSearchBean vehicleSearchBean;
    public APOVehicleSearchBean apoVehicleSearchBean;
    public String url;
    public Map<String, String> urlParameterMap;
    public Id assetId;
    public Id userId;
    public Id svid;// Added by Ankita
    public Id assetIdQuery ;
    public string  summaryNotes;
    
    // Reference by checkout page
    public JUDAAN_ProtoProccessor.VehicleWrapper vehicle;
    public JUDAAN_JACCSProccesor.FinanceWrapper finance;
    public SGRedbookProcessor.VehicleWrapper vehicle_sg;
    public String leadId;
    public String accountId;
    public String sbpsId;
    public String retailerId;
    public Boolean IsFirst;
    public String SelectedVehicleBeanStr;
    public Boolean termsAccepted;
    public Boolean IsTradeInSave;
    public Boolean IsPayment;
    
  
    // Handle Soql query
    public Lead relatedLead;
    public Asset relatedAsset;
    public Account relatedAcc;
    public Opportunity relatedOpp;
    public String retailerEmail;
    public String brand;
    public String market;
    public Boolean retailerDone;
    public Boolean paymentDone;
    public Boolean willSend;
    public Integer protoTradeinValue;
    
}