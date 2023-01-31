public class LocalNameRetriever {
    public List<Contact> RetrieveContacts(Set<Id> contactIds)
    {
        if(contactIds == null || contactIds.isEmpty()){
            return new List<Contact>();
        }
        return [SELECT FirstNameLocal, LastNameLocal FROM Contact WHERE Id IN: contactIds];
    }
    
    public List<Lead> RetrieveLeads(Set<Id> leadIds)
    {
        if(leadIds == null || leadIds.isEmpty()){
            return new List<Lead>();
        }
        return [SELECT FirstNameLocal, LastNameLocal FROM Lead WHERE Id IN: leadIds];
    }
    
    //START Edit by JSOL 27/04/2017
    public List<Asset> RetrieveAssets(Set<Id> assetIds)
    {
        if(assetIds == null || assetIds.isEmpty()){
            return new List<Asset>();
        }
        return [SELECT VIN__c FROM Asset WHERE Id IN: assetIds LIMIT 1];
    }
    //END Edit by JSOL 27/04/2017
}