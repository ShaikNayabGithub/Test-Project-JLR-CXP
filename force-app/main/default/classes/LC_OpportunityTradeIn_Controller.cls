public class LC_OpportunityTradeIn_Controller {

    @AuraEnabled
    public static List<Vehicle_Specification__c> getTradeInBrand(String typed) {
        if(typed == null || typed.trim() == ''){
            return null;
        }
        String soqlQuery = 'SELECT Id, Name, Make__c, Make_Text__c FROM Vehicle_Specification__c WHERE (Name LIKE \'' + typed + '%\') AND Make_Text__c != \'\' LIMIT 50';
        List<Vehicle_Specification__c> vSpecList = Database.query(soqlQuery);
        return vSpecList;
    }
    
}