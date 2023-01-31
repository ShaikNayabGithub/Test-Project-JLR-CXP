public class VME_ProductMixFilterWrapper {
    
    @AuraEnabled public String modelValue {get; set;}
    @AuraEnabled public List<String> modelYearValuesList {get; set;}
    @AuraEnabled public List<String> fuelTypeValuesList {get; set;}
    @AuraEnabled public List<String> trimValuesList {get; set;}
    @AuraEnabled public Map<String,String> engineValuesList {get; set;}
    @AuraEnabled public Map<String,String> doorsValuesList {get; set;}
    @AuraEnabled public List<String> activeValuesList {get; set;}
    @AuraEnabled public List<VME_ProductMixReqWrapper> exitingProductsList {get; set;}

    public VME_ProductMixFilterWrapper(String modelValue, List<String> modelYearValuesList,
                                       List<String> fuelTypeValuesList, List<String> trimValuesList,
                                       Map<String,String> engineValuesList, Map<String,String> doorsValuesList,
                                       List<String> activeValuesList, List<VME_ProductMixReqWrapper> exitingProductsList){
        this.modelValue             = modelValue;
        this.modelYearValuesList    = modelYearValuesList;
        this.fuelTypeValuesList     = fuelTypeValuesList;
        this.trimValuesList        = trimValuesList;
        this.engineValuesList       = engineValuesList;
        this.doorsValuesList        = doorsValuesList;
        this.activeValuesList       = activeValuesList;
        this.exitingProductsList    = exitingProductsList;
    }
}