public without sharing class aopcom_MyEventHowToGetThereCmp {
    
    @auraEnabled
    public static String getInitial(){
    	
    	String googleMaps='';
        Campaign camp=new Campaign();
        //It takes an identifier Contact that is related to an user
        List <User> user=[SELECT ContactId FROM User WHERE Id=:UserInfo.getUserId()];
        System.debug('+++++++++++++++ User list: '+user.size());
        //It takes a CampaignMember that is related to the previous user
        List<CampaignMember> campaignMember=[SELECT CampaignId FROM CampaignMember WHERE ContactId =: user.get(0).ContactId];
        System.debug('+++++++++++++++ Campaign member list: '+campaignMember.size());
        //It takes a Campaign that is related to a CampaignMember
        List <Campaign> campaigns = [SELECT aop_Google_Maps_Link__c FROM Campaign WHERE  Id=:campaignMember.get(0).CampaignId  limit 1];
        if(campaigns.size()>0 && campaigns!=null){
            System.debug('+++++++++++++++ Campaign list: '+campaigns.size());
            camp = campaigns.get(0);
            //It stores a google maps link from the Campaign obtained before
            googleMaps= camp.aop_google_maps_link__c;
        }
        //It returns a google maps link
        return googleMaps;
    }
    
}