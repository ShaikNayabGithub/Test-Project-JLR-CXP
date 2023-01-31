public class aop_EmailController {

	public void CheckIfDisqualifiedOrNoQualificationRequired(Request__c request)
	{

		aop_EmailGetTemplate EmailTemplateGetter = new aop_EmailGetTemplate();
		aop_EmailBuild emailBuilder = new aop_EmailBuild();

        ID targetObjId = request.aop_Customer__c; //id of the object being used to send email to

		ID emailTemplateId;

        if(request.aop_Status__c == System.label.aop_disqualified) 
        {
            emailTemplateId = EmailTemplateGetter.GetDisqualifiedTemplate(request);
            Lead tempLead = new Lead(Purchase_Type__c = 'New Vehicle', Salutation = request.Salutation__c, LastName = request.Last_Name__c, FirstName = request.First_Name__c, Email = request.Email__c);

            insert tempLead;

            emailBuilder.BuildEmail(tempLead.ID, emailTemplateId);

            delete tempLead;
            Database.emptyRecycleBin(tempLead);

        }
        else if(request.aop_Status__c != null)
        {


            if(request.aop_Status__c == System.label.aop_No_Qualification_Required && request.aop_Source__c != System.label.aop_Walk_in)
            {
                List<User> u = [SELECT aop_Has_AoP_Community_Access__c
                       FROM User
                       WHERE Contactid =: request.aop_Customer__c
                       Limit 1
                       ];

                if(u[0].aop_Has_AoP_Community_Access__c)
                {
                    emailTemplateId = EmailTemplateGetter.GetAlreadyKnownTemplate(request);
                    emailBuilder.BuildEmail(u[0].Id, emailTemplateId);

                }
            }

		}
    }

    public boolean SendQualifiedEmail(Request__c request)
    {

            aop_EmailGetTemplate EmailTemplateGetter = new aop_EmailGetTemplate();
            aop_EmailBuild emailBuilder = new aop_EmailBuild();

            User user = getUserFromContact(request.aop_Customer__c);
            if(user != null)
        	{
            resetUserTempPassword(user);

	            ID targetObjId = user.id;

	            ID emailTemplateId = EmailTemplateGetter.GetQualifyTemplate(request); 

	            emailBuilder.BuildEmail(targetObjId, emailTemplateId);
	            DeleteUserTempPassword(user);
     			return true;
        	}
        	return false;

    }

    public boolean SendWalkInEmail(Request__c request)
    {
        aop_EmailGetTemplate EmailTemplateGetter = new aop_EmailGetTemplate();
		aop_EmailBuild emailBuilder = new aop_EmailBuild();

        User user = getUserFromContact(request.aop_Customer__c);
        if(user != null)
        {
        resetUserTempPassword(user);

	        ID targetObjId = user.id;


	        ID emailTemplateId = EmailTemplateGetter.GetWalkInTemplate(request);

	        emailBuilder.BuildEmail(targetObjId, emailTemplateId);
	        DeleteUserTempPassword(user);

        return true;
        }
        return false;
    }


    public boolean SendDisqualifiedEmail(Request__c request)
    {
        aop_EmailGetTemplate EmailTemplateGetter = new aop_EmailGetTemplate();
		aop_EmailBuild emailBuilder = new aop_EmailBuild();

        User user = getUserFromContact(request.aop_Customer__c);
        if(user != null)
        {
	        ID targetObjId = user.id;

	        ID emailTemplateId = EmailTemplateGetter.GetDisqualifiedTemplate(request);

	        emailBuilder.BuildEmail(targetObjId, emailTemplateId);
	        return true;
        }
        return false;
    }

    public boolean SendAlreadyKnownEmail(Request__c request)
    {
        aop_EmailGetTemplate EmailTemplateGetter = new aop_EmailGetTemplate();
		aop_EmailBuild emailBuilder = new aop_EmailBuild();

        User user = getUserFromContact(request.aop_Customer__c);
        if(user != null)
        {
	        ID targetObjId = user.id;

	        ID emailTemplateId = EmailTemplateGetter.GetAlreadyKnownTemplate(request);

	        emailBuilder.BuildEmail(targetObjId, emailTemplateId);
	        return true;
        }
        return false;
    }

    public boolean CampaignComplete(Contact contact)
    {
		aop_EmailGetTemplate EmailTemplateGetter = new aop_EmailGetTemplate();
		aop_EmailBuild emailBuilder = new aop_EmailBuild();

        User user = getUserFromContact(contact.ID); //id of the object being used to send email to
        if(user != null)
        {
	        ID targetObjId = user.id;

			ID emailTemplateId = EmailTemplateGetter.CampaignComplete(contact);
	        if(emailTemplateId != null)
	        {
	        	emailBuilder.BuildEmail(targetObjId, emailTemplateId);
	        	return true;
	        }
        }
		return false;
    }

    public boolean CampaignCompleteSixtyDays(Contact contact)
    {
		aop_EmailGetTemplate EmailTemplateGetter = new aop_EmailGetTemplate();
		aop_EmailBuild emailBuilder = new aop_EmailBuild();

        User user = getUserFromContact(contact.ID); //id of the object being used to send email to
        if(user != null)
        {
	        ID targetObjId = user.id;

			ID emailTemplateId = EmailTemplateGetter.CampaignCompleteSixtyDays(contact);

			emailBuilder.BuildEmail(targetObjId, emailTemplateId);
	        return true;
        }
        return false;
    }

    public List<aop_MassEmailInfo> CampaignCreated(List<Contact> contacts, List<User> userList, ID campaignID, List<aop_Area_Configuration__c> areaConfigs, List<aop_Area_Email_Configuration__c> areaEmailConfigs, List<EmailTemplate> emailTemplates)
    {
		aop_EmailGetTemplate EmailTemplateGetter = new aop_EmailGetTemplate();
		aop_EmailBuild emailBuilder = new aop_EmailBuild();
        List<ID> targetObjIdList = new List<ID>();
        Set<string> languages = new Set<string>();
        List<List<Contact>> listOfContactlistsByLanguage = new List<List<Contact>>();
        List<aop_MassEmailInfo> massEmailInfoList = new List<aop_MassEmailInfo>();
        Integer languageCounter = 0;

        for(Contact c : contacts)
        {
            languages.add(c.Language__c);
        }

        for(string language : languages)
        {
            List<Contact> tempContactList = new List<Contact>();
            for(Contact c : contacts)
        	{
                if(c.Language__c == language)
                {
                    tempContactList.add(c);
                }
       		}
            listOfContactlistsByLanguage.add(tempContactList);
        }

        List<String> languageList = new List<String>(languages); //set was used to remove duplicates now need list functionality


        for(List<Contact> contactList : listOfContactlistsByLanguage)
        {
            ID emailTemplateId = EmailTemplateGetter.CampaignCreated(contactList[0], areaConfigs, areaEmailConfigs, emailTemplates);
            List<ID> tempContactIDList = new List<ID>();
            for(Contact contact : contactList)
            {
                ID targetObjId = getUserFromContact(contact.ID, userList);
                tempContactIDList.add(targetObjId);
            }            

            aop_MassEmailInfo massEmailInfo = new aop_MassEmailInfo();

            massEmailInfo.MassEmail = emailBuilder.BuildMassEmail(tempContactIDList, emailTemplateId);
            massEmailInfo.CampaignID = campaignID;
            massEmailInfo.Language = languageList[languageCounter];

            massEmailInfoList.add(massEmailInfo);
            languageCounter++;

        }
		System.debug('This is a count of languages per campaign: ' + languageCounter);
        return massEmailInfoList;

    }

    private User getUserFromContact(ID contact)
    {
        list<User> users = [SELECT ID
                           FROM User
                           WHERE ContactID =: contact
                           limit 1];

        if(!users.isEmpty())
        {
            return users[0];
        }

         return null;
    }

    private boolean resetUserTempPassword(User user)
    {
    	ResetPasswordResult passwordResult = system.resetPassword(user.id, false);
    	user.aop_TempPassword__c = passwordResult.getPassword();
    	update user;
    	return true;
    }

    private boolean DeleteUserTempPassword(User user)
    {
    	user.aop_TempPassword__c = '';
    	update user;
    	return true;

    }

    private ID getUserFromContact(ID contact, List<User> userList)
    {

        if(!userList.isEmpty())
        {                  
	        for(User u : userList)
	        {
	        	if(u.ContactID == contact)
	        	{
	        		return u.id;
	        	}
	        }
        }
        return null;
    }

}