public class FinanceUpload_AssetRetriever {
    public List<Asset> Retrieve(Set<String> vins, Set<String> registrationNumbers)
    {

        return [SELECT VIN__c, Registration_Number__c, Account.Id,apo__c, Account.RecordTypeId,Account.RecordType.DeveloperName,Account.Pseudo_Account_Owner__r.accountid,Account.owner.accountid,Mileage__c,name FROM Asset 
                WHERE VIN__c IN: vins OR Registration_Number__c IN: registrationNumbers];
    }
}