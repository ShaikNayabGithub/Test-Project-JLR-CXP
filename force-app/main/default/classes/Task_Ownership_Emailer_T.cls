@IsTest
public class Task_Ownership_Emailer_T  {
	
	static User user1;
	static User user2;

	static User CreateUser(string userNumber){
		
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt' + userNumber, Email='standarduser'+userNumber+'@jaguarlandrover.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserjlr'+userNumber+'@jaguarlandrover.com');
		insert u;
		return u;
	}


	 static testmethod void TaskEmail_SendsEmail_IfTaskCreatedAgainstOtherUser(){
		user1 = CreateUser('1');
		user2 = CreateUser('2');			
		System.runAs(user1){
			Task task = new Task();
			task.OwnerId = user2.Id;
			task.Subject = 'Test Task';
			insert task;
			System.assert(Task_Ownership_Emailer.EmailSent);
		}		
	 }	

	 static testmethod void TaskEmail_DoesNotSendsEmail_IfTaskCreatedAgainstSameUser(){		
		user1 = CreateUser('1');
		System.runAs(user1){
			Task task = new Task();
			task.OwnerId = user1.Id;
			task.Subject = 'Test Task';
			insert task;
			System.assert(!Task_Ownership_Emailer.EmailSent);
		}		
	 }	

	 static testmethod void TaskEmail_DoesNotSendsEmail_IfTaskUpdatedAgainstSameUser(){	
		user1 = CreateUser('1');	
		System.runAs(user1){
			Task task = new Task();
			task.OwnerId = user1.Id;
			task.Subject = 'Test Task';
			insert task;
			System.assert(!Task_Ownership_Emailer.EmailSent);

			task.Subject = 'different subject';
			System.assert(!Task_Ownership_Emailer.EmailSent);

		}		
	 }	

	 static testmethod void TaskEmail_SendsEmail_IfUpdatedAgainstDifferentUser(){	
		user1 = CreateUser('1');
		user2 = CreateUser('2');	
		System.runAs(user1){
			Task task = new Task();
			task.OwnerId = user1.Id;
			task.Subject = 'Test Task';
			insert task;
			System.assert(!Task_Ownership_Emailer.EmailSent);

			task.OwnerId = user2.Id;
			System.debug('updating task');
			update task;
			System.debug('update of task complete');
			System.assert(Task_Ownership_Emailer.EmailSent);
		}		
	 }	
}