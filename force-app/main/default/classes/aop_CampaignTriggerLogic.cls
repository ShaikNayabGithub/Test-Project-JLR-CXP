public class aop_CampaignTriggerLogic {

    public void CampaignMemberStatusAfterInsert(Campaign[] campaigns)
    {
        List<CampaignMemberStatus> toDelete = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> toInsert = new List<CampaignMemberStatus>();
        List<Campaign> toUpdate = new List<Campaign>();
        List<RecordType> rts = [SELECT Id FROM RecordType WHERE Name = 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
        RecordType rt;
        if(!rts.isEmpty())
        {
              rt = rts[0];
        }
       for (Campaign c: campaigns){
            if(!rts.isEmpty() && c.RecordTypeId == rt.Id)
            {
                CampaignMemberStatus newCMS = new CampaignMemberStatus(CampaignId=c.Id, HasResponded=true, Label='CF', IsDefault=true, SortOrder=3);       
                toInsert.add(newCMS);
                List<CampaignMemberStatus> defaultCMSList = [SELECT  Id, Label FROM CampaignMemberStatus WHERE CampaignId =: c.Id];
                for(CampaignMemberStatus cms: defaultCMSList)
                {
                    if(cms.Label != 'CF')
                    {
                     toDelete.add(cms);
                    }
                }
                aop_CheckfrontItemLogic configGetter = new aop_CheckfrontItemLogic();
                aop_Area_Configuration__c areaConfig = configGetter.GetAreaConfig(c.aop_Checkfront_Instance__c);
                if(areaConfig != null && areaConfig.aop_New_Record_Owner__c != null)
                {
                    List<Campaign> camps = [SELECT Id, OwnerId FROM Campaign WHERE Id =: c.Id LIMIT 1];
                    if(!camps.isEmpty())
                    {
                        Campaign camp = camps[0];
                        camp.OwnerId = areaConfig.aop_New_Record_Owner__c;
                        toUpdate.add(camp);
                    }

                }
            }

        }
        if(!toInsert.isEmpty())
        {
              insert toInsert;
        }
        if(!toDelete.isEmpty()){
              delete toDelete;
        }
        if(!toUpdate.isEmpty())
        {
            update toUpdate;
        }


}

    public void SendEmailOnCompleteOfCampaign(Campaign campaign) 
    {
        System.debug('Send EmailOnCompleteOfCampaign Running');
        aop_EmailController emailController = new aop_EmailController();

        List<CampaignMember> CampaignMembers = [SELECT ID, Name, ContactId
                                               FROM CampaignMember
                                               WHERE CampaignId =: campaign.id AND aop_CF_Status__c = 'Attended'
                                               ];

        System.debug('Found Campaign Members' + CampaignMembers);


        if(CampaignMembers != null)
        {

            for(CampaignMember cm : CampaignMembers)
            {
                List<Contact> Contacts = [SELECT ID, Name, Language__c, aop_Country__C
                                         FROM Contact
                                         WHERE ID =: cm.ContactId
                                         ];

                if(!Contacts.isEmpty())
                {
                    System.debug('Trying to send Email');
                    emailController.CampaignComplete(Contacts[0]);
                }


            }
        }
    }


    public List<aop_MassEmailInfo> SendEmailOnCreateOfCampaign(Campaign campaign, List<Contact> contactsAll, List<CampaignMember> campaignMembers, List<User> users, List<aop_Area_Configuration__c> areaConfigs, List<aop_Area_Email_Configuration__c> areaEmailConfigs, List<EmailTemplate> emailTemplates)
    {

              aop_EmailController emailController = new aop_EmailController();
               System.debug('Send SendEmailOnCreateOfCampaign Running');
              /* string country;

               if(campaign.aop_Checkfront_Instance__c != null)
               {
                    country = GetCountryFromCheckFrontInstance(campaign.aop_Checkfront_Instance__c);
               }
                System.debug('Returned Country is ' + country);

               if(country != null)
               {
                    List<Contact> contacts = new List<Contact>();

                    for (Contact c : contactsAll)
                    {
                        if(c.aop_Country__c == country)
                        {
                            contacts.add(c);
                        }
                    }*/

                   List<contact> criteriaMetContacts = new List<contact>();

                   System.debug('contact list is ' + contactsAll);

                   for(Contact c : contactsAll)
                   {
                       List<CampaignMember> matchingCampaignMembers = new List<CampaignMember>();
                       List<User> matchingUsers = new List<User>();

                       for(CampaignMember cm : campaignMembers)
                       {
                           if(cm.ContactId == c.id && (cm.aop_CF_Status__c == 'Attended' 
                                                       || cm.aop_CF_Status__c == 'Pending' 
                                                       || cm.aop_CF_Status__c == 'Reserved'
                                                       || cm.aop_CF_Status__c == 'Deposit'
                                                       || cm.aop_CF_Status__c == 'Paid'
                                                       || cm.aop_CF_Status__c == 'Waiting'
                                                       || cm.aop_CF_Status__c == 'Pre-Booking'
                                                       || cm.aop_CF_Status__c == 'No-Show'))

                           {
                               matchingCampaignMembers.add(cm); 
                           }
                       }


                       //System.debug('matchingCampaignMembers list is ' + matchingCampaignMembers);

                       if (matchingCampaignMembers.isEmpty() || matchingCampaignMembers == null)
                       {
                           for(User u : users)
                           {
                               if(u.ContactID == c.id)
                               {
                                   matchingUsers.add(u);
                               }
                           }

                           if(!matchingUsers.isEmpty())
                           {
                               User user = matchingUsers[0];


                               if(user.aop_Has_AoP_Community_Access__c)
                               {
                                   System.debug('Trying to send Email');
                                   criteriaMetContacts.add(c);
                               }

                           }                
                        }   
                    }
                    return emailController.CampaignCreated(criteriaMetContacts, users, campaign.id, areaConfigs, areaEmailConfigs, emailTemplates);




        return null;


    }

    public static Map<string, List<sObject>> GetContactsCampaignMembersUsers(List<String> Country)
    {

         List<Contact> contacts = [SELECT ID, Name, Language__c, aop_Country__c
                                         FROM Contact
                                         WHERE aop_Suspended_for_Events__c =: false AND aop_Is_Qualified_for_Events__c =: true 
                                         And aop_Country__c IN: Country And RecordType.DeveloperName !=: 'Employee_Contact'
                                        ];


         List<ID> contactID = new List<ID>();
         for(Contact c : contacts)
         {
         	contactID.add(c.id);
         }


         List<CampaignMember> campaignMembers = [SELECT ID, Name, aop_CF_Status__c, ContactId
                                                          FROM CampaignMember
                                                          WHERE ContactId IN: contactID
                                                          ];

         List<User> users = [SELECT ID, Name, ContactId, aop_Has_AoP_Community_Access__c
                                     FROM User
                                     WHERE ContactId IN: contactID
                            ];


         Map<string, List<sObject>> dataMap = new Map<string, List<SObject>>();

         dataMap.put('contacts', contacts);
         dataMap.put('campaignMembers', campaignMembers);
         dataMap.put('users', users);

         return dataMap;



    }




    private List<string> GetCountryFromCheckFrontInstance(string checkFrontURL) 
    {
        Map<string,aop_NationalityToISOCode__c> countryMappings = aop_NationalityToISOCode__c.getAll();
		List<string> countries = new List<string>();
        
        if(checkFrontURL != null)
        {

            for(aop_NationalityToISOCode__c countryMapping : countryMappings.Values())
            {
                if(countryMapping.aop_Checkfront_Instance__c == checkFrontURL)
                {
                    
                    countries.add(countryMapping.Name);
                }
            }
        }

        return countries;
    }

     public void SetLastQualifiedEventCompleteOfCampaign(Campaign campaign)
    {
        If(campaign.Status == 'Visible'){ 
        //if campaign is not hidden then update all last qualified of the start date of campaign session
        List<CampaignMember> CampaignMembers = [SELECT ID, Name, ContactId, aop_Session_Start__C
                                               FROM CampaignMember
                                               WHERE CampaignId =: campaign.id 
                                               ];

        if(CampaignMembers != null)
        {

            for(CampaignMember cm : CampaignMembers)
            {
              if(cm.aop_Session_Start__c != null)
              {
                List<Contact> tobeUpdated = [Select ID From Contact Where Id =: cm.ContactId];
                if(!tobeUpdated.isEmpty())
                {
                    tobeUpdated[0].aop_Last_Qualifying_Event__c = cm.aop_Session_Start__c;
                    update(tobeUpdated[0]);
                    //update last qualified 
                }          
              }

            }
        }

    }
      }

    public Boolean AddCustomSetting(Campaign newCamp)
    {
       aop_CampaignTracker__c campaignTracker = new aop_CampaignTracker__c();
       campaignTracker.Name = newCamp.Id;
       insert campaignTracker;
       return true;
    }

    public void DeleteCustomSetting(Campaign camp)
    {
        aop_CampaignTracker__c campaignTracker = aop_CampaignTracker__c.getInstance(camp.Id);
        if(campaignTracker != null)
        {
            delete campaignTracker;
        }
    }

    public void OnCreateOfVisibleCampaign(List<campaign> newTrigger)
    {
       List<RecordType> rts = [SELECT Id FROM RecordType WHERE Name = 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
        RecordType rt;
        if(!rts.isEmpty())
        {
          rt = rts[0];
        }
        for(Campaign campaign : newTrigger)
        {          
          if(rt != null && campaign.RecordTypeId == rt.Id && campaign.Status == System.label.aop_Visible)
          {
              System.debug('Record type is game event');
              AddCustomSetting(campaign);              
          }
        }
    }

    public List<String> getCountriesFromCampaigns(List<Campaign> campaigns)
    {
    	List<String> countryList = new List<String>();
    	for(Campaign c : campaigns)
    	{
	    	if(c.aop_Checkfront_Instance__c != null)
	        {
	             List<String> countries = GetCountryFromCheckFrontInstance(c.aop_Checkfront_Instance__c);
	             countryList.addAll(countries);
	        }
    	}
    	return countryList;
    }

    public List<String> getCountriesFromCampaignTracker(List<aop_CampaignTracker__c> trackers)
    {
    	List<ID> campaignID = new List<ID>();
    	for(aop_CampaignTracker__c campaignTracker : trackers)
		{
			campaignID.add(campaignTracker.Name);
		}
		List<Campaign> campaignList = [SELECT Id, aop_Checkfront_Instance__c
									   FROM Campaign
									   WHERE ID IN: campaignID
									 ];
		return getCountriesFromCampaigns(campaignList);
    }

    public List<aop_Area_Configuration__c> getAreaConfigs()
    {
        return [SELECT ID, aop_Checkfront_Instance__c 
                FROM aop_Area_Configuration__c
               ];
    }

    public List<aop_Area_Email_Configuration__c> getAreaEmailConfigs()
    {
        return [SELECT ID, Name, aop_Already_Known_Template_Name__c, aop_Area_Configuration__c, aop_Asset_Reminder_Template_Name__c,
                           aop_Disqualified_Template_Name__c, Post_Event_Template_Name__c, aop_Qualified_Template_Name__c, aop_Walk_in_Template_Name__c, aop_New_Event_Template_Name__c, aop_Language__c, aop_Is_Area_Default__c
                           FROM aop_Area_Email_Configuration__c];
    }

    public List<EmailTemplate> getEmailTemplates(List<aop_Area_Email_Configuration__c> areaEmailConfiguration)
    {

        //make 6 lists one for each field
        aop_Area_Email_Configuration__c blah = new aop_Area_Email_Configuration__c();
        List<string> requiredTemplates = new List<string>();

        
        for(aop_Area_Email_Configuration__c aec : areaEmailConfiguration)
        {
            requiredTemplates.add(aec.aop_Already_Known_Template_Name__c);
        	requiredTemplates.add(aec.aop_Asset_Reminder_Template_Name__c);
            requiredTemplates.add(aec.aop_Disqualified_Template_Name__c);
            requiredTemplates.add(aec.aop_New_Event_Template_Name__c);
            requiredTemplates.add(aec.aop_Qualified_Template_Name__c);
            requiredTemplates.add(aec.aop_Walk_in_Template_Name__c);
            requiredTemplates.add(aec.Post_Event_Template_Name__c);

        }
        
        aop_emailGlobalDefault__c emailGlobalDefault = aop_emailGlobalDefault__c.getValues('emailGlobalDefault');
        
		List<string> listOfGlobalIDs = new List<string>();

		listOfGlobalIDs.add(emailGlobalDefault.aop_Already_Known_Template_ID__c);
        listOfGlobalIDs.add(emailGlobalDefault.aop_Asset_Reminder_Template_ID__c);
        listOfGlobalIDs.add(emailGlobalDefault.aop_Disqualified_Template_ID__c);
        listOfGlobalIDs.add(emailGlobalDefault.aop_New_Event_Template_ID__c);
        listOfGlobalIDs.add(emailGlobalDefault.aop_Post_Event_Template_ID__c);
        listOfGlobalIDs.add(emailGlobalDefault.aop_Qualified_Template_ID__c);
        listOfGlobalIDs.add(emailGlobalDefault.aop_Walk_in_Template_ID__c);
        
        List<EmailTemplate> emailTemplates = [SELECT developername 
                                              FROM EmailTemplate
                                              WHERE id IN: listOfGlobalIDs
                                             ];
        
        for(EmailTemplate em : emailTemplates)
        {
            requiredTemplates.add(em.developername);
        }

        return [SELECT id, name, developername 
					  FROM EmailTemplate 
				      WHERE developername IN: requiredTemplates
                     ];
    }



}