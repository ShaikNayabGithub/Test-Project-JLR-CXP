public class Task_Ownership_Emailer {
    private Task oldTask;
    private Task newTask;

	@TestVisible
	private static Boolean EmailSent = false;

    public Task_Ownership_Emailer(Task newTask){
        this.newTask = newTask;
    }

    public Task_Ownership_Emailer(Task oldTask, Task newTask){
        this.oldTask = oldTask;
        this.newTask = newTask;
    }

    public void Process_Insert(){
        System.debug('Task inserted');
        if(this.newTask.CreatedById == this.newTask.OwnerId) return;

        Map<Id,User> users = new Map<Id,User>( [SELECT Id, Email, Name
                            FROM User
                            WHERE Id =: this.newTask.CreatedById or Id =: this.newTask.OwnerId]);

        if(users.values()[0].email.endsWithIgnoreCase('@jaguarlandrover.com') && 
            users.values()[1].email.endsWithIgnoreCase('@jaguarlandrover.com')){

            SendEmail(users.get(this.newTask.OwnerId).Email,users.get(this.newTask.CreatedById).Name,newTask);
            //Send user an email
        }
    }

    public void Process_Update(){
        System.debug('Task updated');
        if(this.newTask.OwnerId == this.oldTask.OwnerId || this.newTask.OwnerId == UserInfo.getUserId()) return;

        //Ownership of the task has changed
        Map<Id,User> users = new Map<Id,User>([SELECT Id, Email , Name
                            FROM User
                            WHERE Id =: this.newTask.LastModifiedById or Id =: this.newTask.OwnerId]);

        if(users.values()[0].email.endsWithIgnoreCase('@jaguarlandrover.com') && 
            users.values()[1].email.endsWithIgnoreCase('@jaguarlandrover.com')){

            //Send user an email
            SendEmail(users.get(this.newTask.OwnerId).Email, users.get(newTask.LastModifiedById).Name ,newTask);
        }
    }

    private void SendEmail(String emailAddress, String assignedBy,Task task){
		String orgUrl = System.Url.getSalesforceBaseURL().toExternalForm();
		String taskUrl = orgUrl + '/' + task.Id;
        String emailNotification = String.Format(Label.taskEmailNotificationGeneric,new List<String>{assignedBy,task.subject,task.priority,taskUrl});
        system.debug(emailAddress);
        EmailUtility.SendEmail(new List<String>{emailAddress}, 'JLR CXP Notification', Label.taskEmailNotificationSubject, emailNotification.replaceAll('\n','<br/>'),
                            '','noreply@jaguarexperience.com',false,null,true);
		EmailSent = true;
    }
}