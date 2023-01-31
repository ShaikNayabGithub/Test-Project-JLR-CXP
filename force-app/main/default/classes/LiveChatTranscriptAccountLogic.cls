public class LiveChatTranscriptAccountLogic {
    
    public id convertContactIntoPersonAccount(Id contactId, id ownerId){
        System.debug('LiveChatTranscriptAccountLogic.convertContactIntoPersonAccount START');
        
       Contact cont = [Select id, name,isPersonAccount, accountid, ownerId,owner.name, owner.Country_ISO_Code__c from contact where id =:contactId];
        System.debug('Cont '+ JSON.serializePretty(cont));
       id corporateRecordType =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
          id individualRecordType =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        if(!cont.isPersonAccount){
            
            Account emptyAccount = new Account();
        emptyAccount.recordTypeid = corporateRecordType;
        emptyAccount.name = contactid;
        emptyAccount.OwnerId = ownerId;
        emptyAccount.Country_ISO_Code__c =  cont.owner.Country_ISO_Code__c;

      insert emptyAccount;
        cont.accountid= emptyAccount.id;
        cont.OwnerId = ownerId; 
        System.debug('Country_ISO_Code__c '+ cont.owner.Country_ISO_Code__c);  
                System.debug('Owner '+ cont.owner.name);  
        if(cont.owner.Country_ISO_Code__c != null){
           cont.Country_ISO_Code__c = cont.owner.Country_ISO_Code__c;  
        }   
     
update cont;
            
       

              
         
        Account accToConvert = new Account();
        accToConvert.Id =emptyAccount.Id;
        accToConvert.RecordTypeId = individualRecordType;
  update accToConvert;
         System.debug('LiveChatTranscriptAccountLogic.convertContactIntoPersonAccount FINISHED');
        return accToConvert.id;            
        }else{
            return cont.AccountId;
        }
        
         }
  
        
        
    //}

}