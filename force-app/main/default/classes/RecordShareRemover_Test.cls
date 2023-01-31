@isTest
public class RecordShareRemover_Test {
    static testmethod void BatchExecute_DeletesObjectShareRecord_GivenOldObjectShareRecord()
    {
    	User user = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'NSC CRC Manager' limit 1][0]);
    	
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		AccountShare accountShare = CreateAccountShare(user);
    		RecordShareRemover recordShareRemover = new RecordShareRemover();
	    	List<ObjectShareRecord__c> objectShareRecords = new List<ObjectShareRecord__c>();
	    	
	    	ObjectShareRecord__c objectShareRecord = CreateObjectShareRecord(accountShare, DateTime.now().AddHours(-2 -Integer.valueOf(System.Label.ShareRecordLifetime)));
	    	objectShareRecords.add(objectShareRecord);
	    	
	    	recordShareRemover.execute(new Dummy_BatchableContext(), objectShareRecords);
	    	
	    	List<ObjectShareRecord__c> retrievedRecords = [Select Id From ObjectShareRecord__c Where Id=:objectShareRecord.Id];
	    	System.assertEquals(0, retrievedRecords.size());
    	}
    }
    
    static testmethod void BatchExecute_DeletesAccountShareRecord_GivenOldObjectShareRecord()
    {
    	User user = TestClass_UserCreator.CreateUser([select Id from Profile where Name = 'NSC CRC Manager' limit 1][0]);
    	
    	System.RunAs(new User(Id=UserInfo.getUserId())){
    		AccountShare accountShare = CreateAccountShare(user);
    		RecordShareRemover recordShareRemover = new RecordShareRemover();
	    	List<ObjectShareRecord__c> objectShareRecords = new List<ObjectShareRecord__c>();
	    	
	    	ObjectShareRecord__c objectShareRecord = CreateObjectShareRecord(accountShare, DateTime.now().AddHours(-2 -Integer.valueOf(System.Label.ShareRecordLifetime)));
	    	objectShareRecords.add(objectShareRecord);
	    	
	    	recordShareRemover.execute(new Dummy_BatchableContext(), objectShareRecords);
	    	
	    	List<AccountShare> retrievedRecords = [Select Id From AccountShare Where Id=:accountShare.Id];
	    	System.assertEquals(0, retrievedRecords.size());
    	}
    }
    
    private class Dummy_BatchableContext implements Database.BatchableContext{
		public Id getChildJobId()
		{
			return Id.valueOf('0068E000002jAG0');//temp
		}

		public Id getJobId()
		{
			return Id.valueOf('0068E000002jAG0');
		}
	}
	
	private static AccountShare CreateAccountShare(User user)
	{
		Account account = new Account();
		account.Name = 'Test';
		insert account;
		
		AccountShare accountShare = new AccountShare();
			
		accountShare.AccountAccessLevel = 'edit';
		accountShare.AccountId = account.Id;
		accountShare.UserOrGroupId = user.Id;
		accountShare.OpportunityAccessLevel = 'none';
		accountShare.CaseAccessLevel = 'none';
		
		insert accountShare;
		return accountShare;
	}
	
	private static ObjectShareRecord__c CreateObjectShareRecord(AccountShare accountShare, DateTime createdDate)
	{
		ObjectShareRecord__c objectShareRecord = new ObjectShareRecord__c();
        objectShareRecord.Name = accountShare.Id;
        objectShareRecord.Created_Date__c = createdDate;
        insert objectShareRecord;
        return objectShareRecord;
	}
}