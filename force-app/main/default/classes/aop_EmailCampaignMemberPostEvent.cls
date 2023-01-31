public class aop_EmailCampaignMemberPostEvent {
    
    @InvocableMethod(label='Send Emails' description='Sends Emails for CampaignMembersPostEvent')
    public static void sendEmail(List<CampaignMember> campaignMembers)
    {
        aop_EmailController emailController = new aop_EmailController();

        Set<ID> campaignMemberContactID = new Set<ID>();
        Set<ID> campaignMemberCampaignID = new Set<ID>();
        
        
        
        
        for(CampaignMember cm : campaignMembers)
        {
  			campaignMemberContactID.add(cm.ContactId);
  			campaignMemberCampaignID.add(cm.CampaignID);
        }
        
          List<Contact> contacts = [SELECT ID, Name, Language__c, aop_Country__C
                             FROM Contact
                             WHERE ID IN: campaignMemberContactID
                             LIMIT 1
                            ];
                            
          List<Campaign> campaigns = [SELECT ID, aop_Checkfront_Instance__c
	                                        FROM Campaign
	                                        WHERE ID IN: campaignMemberCampaignID
	                                		];
                    System.debug('contacts is ' + contacts);
           if(!contacts.isEmpty())
           {
           	
	           for(Contact contact : contacts)
	           {
	               if(contact.Language__c != null || contact.aop_Country__c != null)
	               {
	                  for(Campaign campaign : campaigns)
	                  {
		                   aop_Area_Configuration__c areaConfig = aop_EmailCampaignMemberPostEvent.GetAreaConfig(campaign.aop_Checkfront_Instance__c);
		                   
		                   String[] toAddresses;
		                   if(areaConfig != null && areaConfig.aop_New_Record_Owner__c != null)
					       {
					            Id targetId = areaConfig.aop_New_Record_Owner__c;
					            Messaging.SingleEmailMessage newMessage = new Messaging.SingleEmailMessage();
				        	
					        	newMessage.setTargetObjectId(targetId);
					        	newMessage.setSenderDisplayName('Salesforce Error Reporting');
					        	newMessage.setSubject('An error has occurred while sending an email to a Campaign Member');
					        	newMessage.setPlainTextBody('An error was encountered sending an email to Campaign Member ' + contact.Name + ' as they do not have the required language/country fields filled.');
					        	
					        	if(areaConfig != null)
			                    {
			                         Messaging.sendEmail(new Messaging.SingleEmailMessage[] { newMessage });
			                    }
					        }
		                
			               else
			               {
			                    emailController.CampaignComplete(contact);
			               }
	                  }
	               }
	           }
           }
          
        
        
        
    }
    
    public static aop_Area_Configuration__c GetAreaConfig(String checkfrontInstance)
    {
   
       List<aop_Area_Configuration__C> eventConfig  = [SELECT ID, aop_New_Record_Owner__c FROM aop_Area_Configuration__c WHERE aop_Checkfront_Instance__c =: checkfrontInstance];
       if(!eventConfig.isEmpty() && eventConfig[0] != null)
       {            
           return eventConfig[0];
       }
        
       return null;
        
    }

}