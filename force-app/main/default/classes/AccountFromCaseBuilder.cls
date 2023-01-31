public class AccountFromCaseBuilder {//1.2
    private static final RecordType personAccountRecordType = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName='Individual' And IsActive=true];    
    Private Id personPrimaryAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId(); 
    private static final Map<String,CRC_Email_To_Case__c> emailToCaseQueues = CRC_Email_To_Case__c.getAll();
    private static final List<QueueSObject> queues = [Select Id,QueueId,Queue.Developername from QueueSObject];
    private static final List<User> marketOwners = [SELECT Id, Name, UserRole.DeveloperName, Country_ISO_Code__c, Market__c FROM User WHERE ( (UserRole.DeveloperName LIKE '%DUMMY%' AND UserType='Standard') OR UserRole.DeveloperName = 'Account_Contact_Owner_Role') AND IsActive = true];
    
    
    public Account BuildPersonAccount(Case caseRecord)
    {
        Account account = new Account();
        if (Label.TMP_TEST_W2L_OWNER_SETTER == '1' && !Test.isRunningTest()) {

            Id SystemOwnerId = [select id from user where UserRole.DeveloperName = 'Account_Contact_Owner_Role' limit 1].id;
            account.ownerid = SystemOwnerId;
            account.pseudo_account_owner__c = UserInfo.getUserId();

        }
        account.RecordTypeId = personAccountRecordType.Id;
        if(caseRecord.Case_Contact_Email__c != null)
        {
            account.LastName = caseRecord.Case_Contact_Email__c;
        }
        if(caseRecord.Case_Contact_Phone__c != null)
        {
            account.LastName = caseRecord.Case_Contact_Phone__c;
        }        

        account.PersonEmail = caseRecord.Case_Contact_Email__c;
        account.Phone = caseRecord.Case_Contact_Phone__c;
        
        String queueName = getQueueName(caseRecord);
        if(queueName != null){
            if(emailToCaseQueues.containsKey(queueName)) account.country_iso_code__c = emailToCaseQueues.get(queueName).Country_ISO_Code__c;  
        }
        
        if(caseRecord.Country_ISO_Code__c != null)
        {
            account.Country_ISO_Code__c = caseRecord.Country_ISO_Code__c;
        }
        else
        {
            account.Country_ISO_Code__c = caseRecord.Owner_ISO_Code__c;
        }
        
        //////////////////////////////////////////////////////////////
        //code to set correct Owner depending on Country ISO Code can be moved into a new class as this is also used by Primary Account
        account.OwnerId = null;
        
        id profileId = userinfo.getProfileId();
        Profile profileName = [Select name from Profile where id =: profileId limit 1];
        if(profileName.Name != 'JLR System Administrator (Super)'){
            account.OwnerId = userinfo.getUserId();
        }
        
        if(account.OwnerId == null || Test.isRunningTest()){
            if(account.Country_ISO_Code__c != null){
                for(User u : marketOwners){
                    if(u.UserRole.DeveloperName.toUpperCase().contains('DUMMY') && u.Country_ISO_Code__c == account.Country_ISO_Code__c){
                        account.OwnerId = u.Id; //set OwnerId to the Dummy User for the Country (Country ISO Code) of the Case
                        account.Is_Primary__c=True;
                        account.RecordTypeId=personPrimaryAccountRecordType;
                    }
                }
            }
        }
        //how is Region or Market set?
        if(account.OwnerId == null || Test.isRunningTest()){
            if(caseRecord.Owner_Region_Or_Market__c != null){
                for(User u : marketOwners){
                    if(u.UserRole.DeveloperName.toUpperCase().contains(caseRecord.Owner_Region_Or_Market__c.toUpperCase())){
                        account.OwnerId = u.Id; //set OwnerId to the Dummy User for the Region or Market of the Case
                        account.Is_Primary__c=True;
                        account.RecordTypeId=personPrimaryAccountRecordType;
                    }
                }
            }
        }
        if(account.OwnerId == null || Test.isRunningTest()){
            for(User u : marketOwners){
                if(u.UserRole.DeveloperName.equalsIgnoreCase('Account_Contact_Owner_Role')){
                    if(u.Name.equalsIgnoreCase('SYSTEM USER')){
                        account.OwnerId = u.Id; //set OwnerId to System User
                    }
                }
            }
        }        
        //////////////////////////////////////////////////////////////
        return account;
    }
    
    private String getQueueName(Case caseRecord){
        for(QueueSObject q : queues){
            if(q.QueueId == caseRecord.ownerId){
                return q.Queue.DeveloperName;
            }
        }
        return null;
    }
}