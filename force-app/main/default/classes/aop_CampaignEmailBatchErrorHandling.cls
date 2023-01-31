public class aop_CampaignEmailBatchErrorHandling {


	public void retrySendErrorEmails(List<aop_CampaignTracker__c> ErrorCampaignTrackers, List<Contact> contacts, List<CampaignMember> campaignMembers, List<User> userList, List<aop_Area_Configuration__c> areaConfigs, List<aop_Area_Email_Configuration__c> areaEmailConfigs, List<EmailTemplate> emailTemplates)
	{
		List<ID> campaignID = new List<ID>();
		List<Messaging.MassEmailMessage> campaignMassEmailFullSet = new List<Messaging.MassEmailMessage>();
		aop_CampaignTriggerLogic campaignTriggerLogic = new aop_CampaignTriggerLogic();
		List<List<aop_MassEmailInfo>> massEmailInfoListList = new List<List<aop_MassEmailInfo>>();
		List<Messaging.MassEmailMessage> massEmailList = new List<Messaging.MassEmailMessage>();


		//get campaign trackers
		for(aop_CampaignTracker__c campaignTracker : ErrorCampaignTrackers)
		{
			campaignID.add(campaignTracker.Name);
		}

		//for each campaign 
		List<Campaign> campaignList = [SELECT Id, aop_Checkfront_Instance__c
									   FROM Campaign
									   WHERE ID IN: campaignID
									 ];



		Map<aop_CampaignTracker__c, Campaign> campaignTrackerCampaignMap = new Map<aop_CampaignTracker__c, Campaign>();	




		for(aop_CampaignTracker__c campaignTracker : ErrorCampaignTrackers)
		{
			for(Campaign campaign : campaignList)
			{
				if(campaignTracker.Name == campaign.ID)
				{
					campaignTrackerCampaignMap.put(campaignTracker, campaign);
				}
			}
		}

		for(aop_CampaignTracker__c campaignTracker : campaignTrackerCampaignMap.keySet())
		{
			//get campaigncreated massemails
			List<aop_MassEmailInfo> massEmailInfoList = campaignTriggerLogic.SendEmailOnCreateOfCampaign(campaignTrackerCampaignMap.get(campaignTracker), contacts, campaignMembers, userList,
                                                                                                         areaConfigs, areaEmailConfigs, emailTemplates);
			List<aop_MassEmailInfo> campaignEmailsMarkedForKeep = new List<aop_MassEmailInfo>();
			if(massEmailInfoList != null)
			{
				for(aop_MassEmailInfo massEmailInfo : massEmailInfoList)
				{
					//remove whitespace and putinto list for aop_Error_Language__c
					List<String> errorLanguageString = new List<String>();
					errorLanguageString = campaignTracker.aop_Error_Language__c.split('\\s*,\\s*');
					//mark for keep non error mass emails
					for(String s : errorLanguageString)
					{
						if(s == massEmailInfo.language)
						{
							//add to new mass email list
							campaignEmailsMarkedForKeep.add(massEmailInfo); //thos should be getting the Messaging.MassEMail bit and creating a List<List<aop_MassEmailInfo>> massEmailInfoListList = new List<List<aop_MassEmailInfo>>();
							massEmailList.add(massEmailInfo.MassEmail);
						}
					}
				}
				if(campaignEmailsMarkedForKeep != null)
				{
					massEmailInfoListList.add(campaignEmailsMarkedForKeep);
				}
			}
		}

 		//end for
		//send mass email list
		List<Messaging.SendEmailResult> messagingResultsList = aop_EmailBuild.SendMassEmail(massEmailList);		

		//do original error handling
		emailErrorHandling(messagingResultsList, massEmailInfoListList);

	}

	public void emailErrorHandling(List<Messaging.SendEmailResult> messagingResultsList, List<List<aop_MassEmailInfo>> massEmailInfoListList)
	{

		 Integer massEmailInfoListCounter = 0;
		 Set<Id> campaignIdSuccess = new Set<Id>();
         Integer massEmailInfoCounter;
         Map<ID, string> CampaignIDErrorStringMap = new Map<ID, string>();		 

              if(messagingResultsList != null && !messagingResultsList.isEmpty())
              {
	              for(List<aop_MassEmailInfo> massEmailInfoList : massEmailInfoListList)
		          {
		             massEmailInfoCounter = -1;
		             boolean campaignPass = true;
		             string failedLanguageString;
		             for(aop_MassEmailInfo massEmailInfo : massEmailInfoList)
		             {
		              	if(messagingResultsList[massEmailInfoListCounter].success == false)
		              	{
		              		campaignPass = false;
							failedLanguageString = failedLanguageString + massEmailInfo.Language + ', ';       		
						}
						massEmailInfoCounter++;						
		             }

		             if(campaignPass)
		             {
		              	campaignIdSuccess.add(massEmailInfoList[massEmailInfoCounter].CampaignID);                   		
		             }
		             else if (!campaignPass)
		             {
		              	CampaignIDErrorStringMap.put(massEmailInfoList[massEmailInfoCounter].CampaignID, failedLanguageString);
		             }
		             massEmailInfoListCounter++;		             
	             }

	              if(campaignIdSuccess.size() > 0)
	              {
	                     database.delete([SELECT Id FROM aop_CampaignTracker__c WHERE Name IN: campaignIdSuccess], false);
	              }
              }
              List<aop_CampaignTracker__c> campaignTrackersForEdit = [SELECT ID, aop_Error_Language__c, aop_IsError__c  FROM aop_CampaignTracker__c WHERE Name IN: CampaignIDErrorStringMap.KeySet()];

              for(aop_CampaignTracker__c campaignTracker : campaignTrackersForEdit)
              {
              	 campaignTracker.aop_Error_Language__c = CampaignIDErrorStringMap.get(campaignTracker.ID);
              	 campaignTracker.aop_IsError__c = true;
              }

              if(!campaignTrackersForEdit.isEmpty())
              {
              	 insert campaignTrackersForEdit;
              }
	}

}