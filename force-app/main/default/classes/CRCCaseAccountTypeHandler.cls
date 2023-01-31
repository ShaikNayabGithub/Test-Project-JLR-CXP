public class CRCCaseAccountTypeHandler {
    
    public static Id crcRecordtypeId   = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC').getRecordTypeId();
    public static Id AccountIndividualRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id AccountCorporateRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
   
    
    public  void validateAccountType(List<Case> cases)
    {
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, Id> caseAccountMap = new Map<Id, Id>();
        for(Case c : cases){
            if(c.recordTypeId == crcRecordtypeId)
            {
                caseMap.put(c.id, c);
                caseAccountMap.put(c.id, c.AccountId);
            }
        }
        if(!caseMap.isEmpty())
        {
            User currentUser = [SELECT Id, Market__c, Country_ISO_Code__c FROM User WHERE Id= :UserInfo.getUserId()];
			if(currentUser.Country_ISO_Code__c == 'AU')
            {
            	Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, name, RecordTypeId from Account WHERE Id IN :caseAccountMap.values()]);
              
                for(Case c : cases)
                {
                    if(caseMap.containsKey(c.Id))
                    {
                        Account caseAccount = accountMap.get(c.AccountId);
                        system.debug('caseAccount '+caseAccount.Recordtypeid);
                        if(caseAccount.RecordTypeId == AccountIndividualRecordtypeId || caseAccount.RecordTypeId == AccountCorporateRecordtypeId)
                        {
                            c.addError('Incorrect Account Type: Please associate case to Primary Account');
                        }
                    }
                }
            }
        }
    }
}