public class ValidationResult {
    
    @AuraEnabled public Boolean Pass { get; set; }
    @AuraEnabled public String Message { get; set; }
    @AuraEnabled public Integer Id {get; set; }

    //Trivial constructor, for server-side Apex -> client-side JavaScript
    public ValidationResult(Boolean pass, String message, Integer id) {
        this.Pass = pass;
        this.Message = message;
        this.Id = id;
        
    }
    // Default, no-arg constructor, for client-side -> server-side
     public ValidationResult() {
     }
}