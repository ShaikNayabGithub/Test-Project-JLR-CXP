public without sharing class LeadDao {
    public static List<Lead> getLeadByAccountId(String accountId){
        return [Select
               		Id
               	From
               		Lead
               	Where
               		Account__c = : accountId
               ];
    }
}