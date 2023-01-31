public class aop_EmailBuild {

    public void BuildEmail(ID targetObjId, ID emailTemplateId)
    {

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@jaguarexperience.com'];
        
        System.debug('owea:' + owea);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		if ( owea.size() > 0 ) {
   		 email.setOrgWideEmailAddressId(owea.get(0).Id);
		}
        
        System.debug('email:' + email);

    	email.setTargetObjectId(targetObjId);
    	email.setTemplateId(emailTemplateId);
        email.setSaveAsActivity(false);
        //email.setSenderDisplayName('The Art of Performance Tour');
        try 
        {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    	}

        catch (EmailException e) {}
    }

    public Messaging.MassEmailMessage BuildMassEmail(List<ID> targetObjIdList, ID emailTemplateID)
    {

        Messaging.MassEmailMessage email = new Messaging.MassEmailMessage();

    	email.setTargetObjectIds(targetObjIdList);
    	email.setTemplateId(emailTemplateId);
        email.setSaveAsActivity(false);
        email.setSenderDisplayName('The Art of Performance Tour');


        
       // try 
        //{
       		//Messaging.sendEmail(new Messaging.MassEmailMessage[] {email});
    	//}



        //catch (EmailException e) {}

        return email;
    	}

    public static List<Messaging.SendEmailResult> SendMassEmail(List<Messaging.MassEmailMessage> massEmailList)
    {
    	List<Messaging.SendEmailResult> messagingResults;
    	try
    	{
    		 messagingResults = Messaging.sendEmail(massEmailList);
    	}
    	catch(EmailException e) 
    	{
    		System.Debug('Mass Email Failed, Exception message is: ' + e.getMessage());
    	}

    	return messagingResults;
    }

}