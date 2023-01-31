public with sharing class aop_CampaignTriggerHandler 
{
	
		public void InsertAfter(List<SObject> campaignTrigger)
		{
  			aop_CampaignTriggerLogic businessLogic = new aop_CampaignTriggerLogic();
  			
  			List<Campaign> campaigns = campaignTrigger;
  			
    		businessLogic.CampaignMemberStatusAfterInsert(campaignTrigger);
			businessLogic.OnCreateOfVisibleCampaign(campaignTrigger);
		}
		
		public void AfterUpdate(List<SObject> campaignTrigger, Map<ID, Campaign> oldMap, Map<ID, Campaign> newMap)
		{
			aop_CampaignTriggerLogic businessLogic = new aop_CampaignTriggerLogic();
  			
  			List<Campaign> campaigns = campaignTrigger;
			
			for(Campaign campaign : campaigns)
        	{
	            if(oldMap.get(campaign.id).Status != newMap.get(campaign.id).Status)
	            {
	                if(newMap.get(campaign.id).Status == 'Visible' && oldMap.get(campaign.id).Status == 'Hidden')
	                {
	                    businessLogic.AddCustomSetting(campaign);
	                }
	                else if(newMap.get(campaign.id).Status == 'Hidden' && oldMap.get(campaign.id).Status == 'Visible')
	                {
	                	businessLogic.DeleteCustomSetting(campaign);
	                }
	                     
	            }
	                
	            if(oldMap.get(campaign.id).aop_Event_Upload_Complete__c != newMap.get(campaign.id).aop_Event_Upload_Complete__c)
	            {
	                 if(campaign.aop_Event_Upload_Complete__c == true)
	                 {
	                     businessLogic.SetLastQualifiedEventCompleteOfCampaign(campaign);
	                 }
	            }                
         	}
		}
}