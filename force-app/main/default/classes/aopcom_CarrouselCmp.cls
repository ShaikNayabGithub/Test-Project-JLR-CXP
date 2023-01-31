public without sharing class aopcom_CarrouselCmp {
	@auraenabled   
    public static String bringEventFeatures (){
        System.debug('++++++++++++++++ Starting bringEventFeatures method');
    	String result='';
        List<User> users=[SELECT ContactId FROM User WHERE Id=: UserInfo.getUserId()];
        if(users.size()>0){
            List<CampaignMember> cmember=[SELECT CampaignId FROM CampaignMember WHERE ContactId=:users.get(0).ContactId];
            if(cmember.size()>0){
                List<Campaign> campaigns=[SELECT aop_Event_Features__c FROM Campaign WHERE Id=: cmember.get(0).CampaignId];
                if(campaigns.size()>0){
                    String values=campaigns.get(0).aop_Event_Features__c;
                    String[] valArray=values.split(';');
                    for(Integer i=0;i<valArray.size();i++){
                        result+=valArray[i]+'#';
                    }
                }
            }
        }
        return result;
    }
        
}