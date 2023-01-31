public class aop_EmailGetTemplate {


    public ID GetQualifyTemplate(Request__c request)
    {
        aop_Area_Configuration__c areaConfig = GetAreaConfig(request.aop_Country__c);
        system.debug(areaConfig);

        List<aop_Area_Email_Configuration__c> areaEmailConfigs = getAreaEmailConfigs(areaConfig.ID, request.Language__c);

        ID emailTemplateId;
        if(areaEmailConfigs != null)
        {
            system.debug('areaEmailConfigs not null');
            aop_Area_Email_Configuration__c areaEmailConfig = areaEmailConfigs[0];

            if(areaEmailConfig.aop_Qualified_Template_Name__c != null)
            {
                string templateApiName = areaEmailConfig.aop_Qualified_Template_Name__c;
                emailTemplateId = GetTemplateId(templateApiName);   
            }
        }
        else
		{
            aop_emailGlobalDefault__c emailGlobalDefault = aop_emailGlobalDefault__c.getValues('emailGlobalDefault');
        	emailTemplateId = emailGlobalDefault.aop_Qualified_Template_ID__c;           
        }

        return emailTemplateId;
    }

    public ID GetWalkInTemplate(Request__c request)
    {
        aop_Area_Configuration__c areaConfig = GetAreaConfig(request.aop_Country__c);
        List<aop_Area_Email_Configuration__c> areaEmailConfigs = getAreaEmailConfigs(areaConfig.ID, request.Language__c);
        ID emailTemplateId;

        if(areaEmailConfigs != null)
        {
            aop_Area_Email_Configuration__c areaEmailConfig = areaEmailConfigs[0];
            if(areaEmailConfig.aop_Walk_in_Template_Name__c != null)
            {
                string templateApiName = areaEmailConfig.aop_Walk_in_Template_Name__c;
                emailTemplateId = GetTemplateId(templateApiName);   
            }
        }
        else
        {
            aop_emailGlobalDefault__c emailGlobalDefault = aop_emailGlobalDefault__c.getValues('emailGlobalDefault');
        	emailTemplateId = emailGlobalDefault.aop_Walk_in_Template_ID__c; 
        }

        return emailTemplateId;
    }

    public ID GetDisqualifiedTemplate(Request__c request)
    {
        aop_Area_Configuration__c areaConfig = GetAreaConfig(request.aop_Country__c);
        List<aop_Area_Email_Configuration__c> areaEmailConfigs = getAreaEmailConfigs(areaConfig.ID, request.Language__c);
        ID emailTemplateId;

        if(areaEmailConfigs != null)
        {
            aop_Area_Email_Configuration__c areaEmailConfig = areaEmailConfigs[0];

	        if(areaEmailConfig.aop_Disqualified_Template_Name__c != null)
	        {
	            string templateApiName = areaEmailConfig.aop_Disqualified_Template_Name__c;
	            emailTemplateId = GetTemplateId(templateApiName);   
	        }
        }
        else
        {
            aop_emailGlobalDefault__c emailGlobalDefault = aop_emailGlobalDefault__c.getValues('emailGlobalDefault');
        	emailTemplateId = emailGlobalDefault.aop_Disqualified_Template_ID__c; 
        }

        return emailTemplateId;
    }

    public ID GetAlreadyKnownTemplate(Request__c request)
    {
        aop_Area_Configuration__c areaConfig = GetAreaConfig(request.aop_Country__c);
        List<aop_Area_Email_Configuration__c> areaEmailConfigs = getAreaEmailConfigs(areaConfig.ID, request.Language__c);
        ID emailTemplateId;

        if(areaEmailConfigs != null)
        {
            aop_Area_Email_Configuration__c areaEmailConfig = areaEmailConfigs[0];

            if(areaEmailConfig.aop_Already_Known_Template_Name__c != null)
            {
                  string templateApiName = areaEmailConfig.aop_Already_Known_Template_Name__c;
                  emailTemplateId = GetTemplateId(templateApiName);
            }
        }
        else
        {
            aop_emailGlobalDefault__c emailGlobalDefault = aop_emailGlobalDefault__c.getValues('emailGlobalDefault');
        	emailTemplateId = emailGlobalDefault.aop_Already_Known_Template_ID__c;
        }

        return emailTemplateId;
    }

    public ID CampaignComplete(Contact contact)
    {
        aop_Area_Configuration__c areaConfig = GetAreaConfig(contact.aop_Country__c);
      	List<aop_Area_Email_Configuration__c> areaEmailConfigs = getAreaEmailConfigs(areaConfig.ID, contact.Language__c);
        ID emailTemplateId;

        if(areaEmailConfigs != null)
        {

        	aop_Area_Email_Configuration__c areaEmailConfig = areaEmailConfigs[0];

	        if(areaEmailConfig.Post_Event_Template_Name__c != null)
	        {
	        	  string templateApiName = areaEmailConfig.Post_Event_Template_Name__c;
	         	  emailTemplateId = GetTemplateId(templateApiName);
	        }
        }
        else
        {
            aop_emailGlobalDefault__c emailGlobalDefault = aop_emailGlobalDefault__c.getValues('emailGlobalDefault');
        	emailTemplateId = emailGlobalDefault.aop_Post_Event_Template_ID__c;
        }
        return emailTemplateId;
    }

    public ID CampaignCompleteSixtyDays(Contact contact)
    {
        aop_Area_Configuration__c areaConfig = GetAreaConfig(contact.aop_Country__c);
      	List<aop_Area_Email_Configuration__c> areaEmailConfigs = getAreaEmailConfigs(areaConfig.ID, contact.Language__c);
        ID emailTemplateId;
        if(areaEmailConfigs != null)
        {
            aop_Area_Email_Configuration__c areaEmailConfig = areaEmailConfigs[0];

	        if(areaEmailConfig.aop_Asset_Reminder_Template_Name__c != null)
	        {
	        	  string templateApiName = areaEmailConfig.aop_Asset_Reminder_Template_Name__c;
	         	  emailTemplateId = GetTemplateId(templateApiName);
	        }
        }
        else
        {
            aop_emailGlobalDefault__c emailGlobalDefault = aop_emailGlobalDefault__c.getValues('emailGlobalDefault');
        	emailTemplateId = emailGlobalDefault.aop_Asset_Reminder_Template_ID__c;
        }

        return emailTemplateId;
    }

    public ID CampaignCreated(Contact contact, List<aop_Area_Configuration__c> areaConfigs, List<aop_Area_Email_Configuration__c> areaEmailConfigs, List<EmailTemplate> emailTemplates)
    {
        ID emailTemplateId;
        aop_Area_Configuration__c areaConfig = GetAreaConfig(contact.aop_Country__c, areaConfigs);
        system.debug('area Config value: ' + areaConfig);

        if(areaConfig != null)
        {

	        if(areaEmailConfigs != null)
            {
	            aop_Area_Email_Configuration__c areaEmailConfig = getAreaEmailConfigs(areaConfig.ID, contact.Language__c, areaEmailConfigs);
                
		        if(areaEmailConfig != null && areaEmailConfig.aop_New_Event_Template_Name__c != null)
		        {
		        	string templateApiName = areaEmailConfig.aop_New_Event_Template_Name__c;
		         	emailTemplateId = GetTemplateId(templateApiName, emailTemplates);
		        }
                else
	        	{
                    aop_emailGlobalDefault__c emailGlobalDefault = aop_emailGlobalDefault__c.getValues('emailGlobalDefault');
                    emailTemplateId = emailGlobalDefault.aop_New_Event_Template_ID__c;
	        	}
	        }


        }
        return emailTemplateId;
    }


    private Id GetTemplateId(string templateApiName)
	{
		System.debug('Get Template ID has been called.');
		Id templateId; 

		try 
        {
			templateId = [SELECT id, name 
						 FROM EmailTemplate 
						 WHERE developername =: templateApiName
						 ].id;
            System.debug('Number of SOQL Queries so far: ' + Limits.getQueries());
            return templateId;
		}
		catch (Exception e) 
		{
			return null;
        }

    }

    private Id GetTemplateId(string templateApiName, List<EmailTemplate> emailTemplates)
	{
		System.debug('Get Template ID has been called.');
		Id templateId; 

        for(EmailTemplate et : emailTemplates)
        {
            if(et.DeveloperName == templateApiName)
            {
                templateId = et.Id;
            }
        }

        System.debug('Number of SOQL Queries so far: ' + Limits.getQueries());
        System.debug('list of emailtemplates: ' + emailTemplates);
        System.debug('returned value: ' + templateId);
        return templateId;



    }

    private List<aop_Area_Email_Configuration__c> getAreaEmailConfigs(ID areaConfigID, string language)
    {
        List<aop_Area_Email_Configuration__c> areaEmailConfigs = new List<aop_Area_Email_Configuration__c>();

        //areaEmailConfigs == where child of Area Configuration and has the matching language
        areaEmailConfigs = [SELECT ID, Name, aop_Already_Known_Template_Name__c, aop_Area_Configuration__c, aop_Asset_Reminder_Template_Name__c,
                           aop_Disqualified_Template_Name__c, Post_Event_Template_Name__c, aop_Qualified_Template_Name__c, aop_Walk_in_Template_Name__c, aop_New_Event_Template_Name__c, aop_Language__c
                           FROM aop_Area_Email_Configuration__c
                           WHERE aop_Area_Configuration__c =: areaConfigID AND aop_Language__c =: language
                           ]; 



        //if there is no matching language use the default language for that country
        if(areaEmailConfigs.isEmpty())
        {

                 areaEmailConfigs = [SELECT ID, Name, aop_Already_Known_Template_Name__c, aop_Area_Configuration__c, aop_Asset_Reminder_Template_Name__c, 
                           aop_Disqualified_Template_Name__c, Post_Event_Template_Name__c, aop_Qualified_Template_Name__c, aop_Walk_in_Template_Name__c, aop_New_Event_Template_Name__c, aop_Language__c
                           FROM aop_Area_Email_Configuration__c
                           WHERE aop_Area_Configuration__c =: areaConfigID AND aop_Is_Area_Default__c =: true
                           ];
            


        }


        //if there is no default langauge for that country use the global default
        if(areaEmailConfigs.isEmpty())
        {
            system.debug('returning null for email config');

            return null;
        }
        system.debug('returning area email configs');
        return areaEmailConfigs;

    }

    private aop_Area_Email_Configuration__c getAreaEmailConfigs(ID areaConfigID, string language, List<aop_Area_Email_Configuration__c> areaEmailConfigs)
    {
        aop_Area_Email_Configuration__c areaEmailConfig;
		System.debug('attempting to getAreaEmailConfigs');

        for(aop_Area_Email_Configuration__c amc : areaEmailConfigs)
        {
            if(amc.aop_Area_Configuration__c == areaConfigID && amc.aop_Language__c == language)
            {
                areaEmailConfig = amc;
            }
        }
		System.debug('value from match check: ' + areaEmailConfig);

        //if there is no matching language use the default language for that country
        if(areaEmailConfig == null)
        {
            for(aop_Area_Email_Configuration__c amc : areaEmailConfigs)
            {
                if(amc.aop_Area_Configuration__c == areaConfigID && amc.aop_Is_Area_Default__c == true)
                {
                    areaEmailConfig = amc;
                }
            }
            System.debug('value from default check: ' + areaEmailConfig);

        }


        //if there is no default langauge for that country use the global default
        if(areaEmailConfig == null)
        {
            system.debug('returning null for email config');
            return null;
        }
        system.debug('returning area email configs');
        return areaEmailConfig;

    }


    private aop_Area_Configuration__c GetAreaConfig(string country)
    {
          if(country != null)
       	  {
            aop_NationalityToISOCode__C countryKey = aop_NationalityToISOCode__c.getValues(country);
            if(countryKey != null)
			{
                string checkfrontInstance = countryKey.aop_Checkfront_Instance__c;

                List<aop_Area_Configuration__C> eventConfig  = [SELECT ID FROM aop_Area_Configuration__c WHERE aop_Checkfront_Instance__c =: checkfrontInstance];

                 if(!eventConfig.isEmpty() && eventConfig[0] != null)
                 {            
                    return eventConfig[0];
                 }
            }
       	  }

        return null;

    }

    private aop_Area_Configuration__c GetAreaConfig(string country, List<aop_Area_Configuration__c> areaConfigs)
    {
          if(country != null)
       	  {

            aop_NationalityToISOCode__C countryKey = aop_NationalityToISOCode__c.getValues(country);
            if(countryKey != null)
            {

                string checkfrontInstance = countryKey.aop_Checkfront_Instance__c;

                aop_Area_Configuration__C eventConfig = new aop_Area_Configuration__c();

                for(aop_Area_Configuration__c ac : areaConfigs)
                {        

                    if(ac.aop_Checkfront_Instance__c == checkfrontInstance)
                    {       
                        eventConfig = ac;
                    }
                }


                 if(eventConfig != null)
                 {                   
                    return eventConfig;
                 }
            }
       	  }
        return null;

    }

}