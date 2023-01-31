public class LC_AssetRoleExtract_Controller {

    @AuraEnabled
    public static List<Role__c> getAssetRoles(Id assetId) {
    	List<Role__c> aroles = [SELECT Id, Name, Account__c, Account__r.Name, Contact__c, Contact__r.Name, Role__c, RecordType.Name FROM Role__c WHERE Vehicle__c = :assetId];
        return aroles;
    }

}