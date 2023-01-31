public without sharing class aopcom_LocationCmp {
    @Auraenabled
    public static String getLocation(){
        Campaign camp;
        DateTime startDate;
        //Date myDate;
        //Time myTime;
        String location;
        String googleMaps;
        List <User> us=[SELECT ContactId FROM User WHERE Id=:UserInfo.getUserId()];
        System.debug('xxxxxxxxxxxxxxx Associated contact to logged User: '+us.get(0).ContactId);
        List<CampaignMember> campaignMember=[SELECT Id, CampaignId,aop_Session_Start__c FROM CampaignMember WHERE ContactId =: us.get(0).ContactId limit 1];
        System.debug('xxxxxxxxxxxxxxx Campaign member List size: '+campaignMember.size());
        if(campaignMember.size()>0){
            System.debug('xxxxxxxxxxxxxxx Associated Campaign member to previous contact Id: '+campaignMember.get(0).Id);
            List <Campaign> campaigns = [SELECT aop_Venue_Address__c, aop_Google_Maps_Link__c FROM Campaign WHERE  Id=:campaignMember.get(0).CampaignId  limit 1];
            System.debug('xxxxxxxxxxxxxxx Associated Campaign List size: '+campaigns.size());
            if(campaigns.size()>0 && campaigns!=null){
                camp = campaigns.get(0);
                location = camp.aop_Venue_Address__c;
                System.debug('xxxxxxxxxxxxxxx Campaign Location: '+location);
                startDate = campaignMember.get(0).aop_Session_Start__c;
                System.debug('xxxxxxxxxxxxx Campaign starDate: '+startDate);
                googleMaps= camp.aop_google_maps_link__c;
            }
        }
      
        System.debug('xxxxxxxxxxxxxxx Result: '+location+'#'+string.valueOf(startDate)+'#'+googleMaps);
        return location= location+'#'+string.valueOf(startDate)+'#'+googleMaps;
        //return 'hola#hola';
        
    }
}