global class aop_CampaignEmailBatch implements Database.Batchable<sObject> {

global Database.QueryLocator start(Database.BatchableContext BC)
       {
              Map<string, aop_CampaignTracker__c> trackers = aop_CampaignTracker__c.getall();

              string query = 'SELECT Id ,Name, aop_IsError__c, aop_Error_Language__c  FROM aop_CampaignTracker__c';

              return Database.getQueryLocator(query);
       }

       global void execute(Database.BatchableContext  BC, List<aop_CampaignTracker__c> scope)
       {
       	      Set<Id> NonErrorCampaignIds = new set<Id>();
			  List<aop_CampaignTracker__c> ErrorCampaignTrackers = new List<aop_CampaignTracker__C>(); 




			  aop_CampaignTriggerLogic businessLogic = new aop_CampaignTriggerLogic();


              List<aop_Area_Configuration__c> areaConfigs = businessLogic.getAreaConfigs();
              List<aop_Area_Email_Configuration__c> areaEmailConfigs = businessLogic.getAreaEmailConfigs();
              List<EmailTemplate> emailTemplates = businessLogic.getEmailTemplates(areaEmailConfigs);

              List<aop_CampaignTracker__c> toDelete = new List<aop_CampaignTracker__c>();
              List<List<aop_MassEmailInfo>> massEmailInfoListList = new List<List<aop_MassEmailInfo>>();
              aop_CampaignEmailBatchErrorHandling batchEmailErrorHandling = new aop_CampaignEmailBatchErrorHandling();
              List<Messaging.MassEmailMessage> massEmailList = new List<Messaging.MassEmailMessage>();


              //seperating errors and nonerrors
              for(aop_CampaignTracker__c tracker : scope)
              {
              	if(!tracker.aop_IsError__c)
              	{
              		NonErrorCampaignIds.add(tracker.Name);
              	}
              	if(tracker.aop_IsError__c)
              	{
              		ErrorCampaignTrackers.add(tracker);
              	}
              }

 			  //getting campaigns from nonerrorList IDS
              List<Campaign> campaignNonErrorList = [SELECT Id, aop_Checkfront_Instance__c FROM Campaign WHERE Id IN:NonErrorCampaignIds];
              System.debug('Batch Apex Email Scope is: ' + campaignNonErrorList);


              //find counturies from campaignnonErrorList and campaignNonErrorLIst so if I just get the cErrorCampaignTrackers campaigns from that
              //then I add the errorcampaigntrackerscampaigns to the campaign non error list, find all the countries and then put that into the datamap getter I can limit
              //the contacts and therefore everything else
              List<string> countryList = new List<string>();

              List<string> ErrorCampaignTrackerCountries = businessLogic.getCountriesFromCampaignTracker(ErrorCampaignTrackers);
              countryList.addall(ErrorCampaignTrackerCountries); 
              System.debug('ErrorCampaignTrackerCountries List 1: ' + ErrorCampaignTrackerCountries);

              List<string> CampaignNonErrorListStringList = businessLogic.getCountriesFromCampaigns(campaignNonErrorList);
              countryList.addall(CampaignNonErrorListStringList); 
              System.debug('CampaignNonErrorListStringList List 2: ' + CampaignNonErrorListStringList);
           
              System.debug('countryList: ' + countryList);

              if(countryList != null)
              {

	              Map<string, List<sObject>> dataMap = aop_CampaignTriggerLogic.GetContactsCampaignMembersUsers(countryList);

	              System.debug('dataMap: ' + dataMap);


	              //error version work
	              batchEmailErrorHandling.retrySendErrorEmails(ErrorCampaignTrackers, dataMap.get('contacts'), dataMap.get('campaignMembers'), dataMap.get('users'), areaConfigs, areaEmailConfigs, emailTemplates);


	              //for every campaign get all of the massemails and add them to massEmailInfoListList
	              for(Campaign camp : campaignNonErrorList)
	              {
	                     List<aop_MassEmailInfo> massEmailInfoList = businessLogic.SendEmailOnCreateOfCampaign(camp, dataMap.get('contacts'), 
                                                                                                               dataMap.get('campaignMembers'), dataMap.get('users'), 
                                                                                                               areaConfigs, areaEmailConfigs, emailTemplates);

	                     if(massEmailInfoList != null)
	                     {
		                     for (aop_MassEmailInfo massEmailInfo : massEmailInfoList)
		                     {
		                     	Messaging.MassEmailMessage massEmail = massEmailInfo.MassEmail;
		                     	massEmailList.add(massEmail);
		                     }
		                     massEmailInfoListList.add(massEmailInfoList);
	                     }
	              }

	              System.debug('Batch Apex massEmailInfoListList is: ' + massEmailInfoListList);
	              System.debug('Batch Apex massEmailList is: ' + massEmailList);

	              //send email
	              List<Messaging.SendEmailResult> messagingResultsList = aop_EmailBuild.SendMassEmail(massEmailList);

	              batchEmailErrorHandling.emailErrorHandling(messagingResultsList, massEmailInfoListList);

              }


       }

       global void finish(Database.BatchableContext BC)
       {
       }

}