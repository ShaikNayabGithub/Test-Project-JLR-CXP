public class FinanceContractWrapper{
    @AuraEnabled public Account acc;
    @AuraEnabled public Contract cont;
    @AuraEnabled public String currUserName;
    @AuraEnabled public String vin;
    @AuraEnabled public String accType;
    @AuraEnabled public String salutation;
    @AuraEnabled public String firstName;
    @AuraEnabled public String lastName;
    @AuraEnabled public String email;
    @AuraEnabled public String phone;
    @AuraEnabled public String mobile;
    @AuraEnabled public String accName;
    @AuraEnabled public String oppName;
    @AuraEnabled public String accId;
    @AuraEnabled public String fchId;
    @AuraEnabled public Boolean isFCHChanged;
    @AuraEnabled public String fchContactId;
    @AuraEnabled public boolean isWon;
    @AuraEnabled public boolean isValidStage;
    @AuraEnabled public boolean isPerson;
    @AuraEnabled public boolean isFchPerson;
    @AuraEnabled public String contactId;
    @AuraEnabled public String message;
    @AuraEnabled public String language;
    @AuraEnabled public String gender;
    @AuraEnabled public String userRegion;
    @AuraEnabled public String countryCode;
    @AuraEnabled public List<pickWrap> dealerList;
    
    public class dmlWrap{
        @AuraEnabled public Boolean hasErr;
        @AuraEnabled public String recId;
        @AuraEnabled public String message;
        @AuraEnabled public String contNumber;
    }
    
    public class pickWrap{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
}