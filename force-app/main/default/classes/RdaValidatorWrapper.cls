public class RdaValidatorWrapper {

    @AuraEnabled public List<ValidationResult> rdaResults {get; set;}
    @AuraEnabled public String RdaType {get; set;}
    @AuraEnabled public Boolean existingRda {get; set;}

    public RdaValidatorWrapper(String rdaType, List<ValidationResult> results, Boolean existing) {
        this.rdaResults = results;
        this.RdaType = rdaType;
        this.existingRda = existing;
    }

    public RdaValidatorWrapper(){
        
    }
}