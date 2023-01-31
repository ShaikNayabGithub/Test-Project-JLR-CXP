public class FinanceUpload_ContractRetriever {
    public List<Contract> Retrieve(Set<String> financeReferences)
    {
        return [SELECT Finance_Reference__c,Contract_Status__c,accountId,asset__c,salutation__c,message__c FROM Contract WHERE Finance_Reference__c IN: financeReferences];
    }
}