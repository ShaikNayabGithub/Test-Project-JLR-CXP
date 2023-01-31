public class aopcom_RedirectController {
    
    public PageReference redirect() {
        String res='';
        Id userId=UserInfo.getUserId();
        List<aop_Area_Configuration__c> aconf;
        //It selects several attributes from some users whose Id is equal to userId
        List <User> userList = [SELECT FirstName, LastName, ContactId FROM User WHERE Id =: userId];
        //It creates some contacts that is related to the previous users
        List <Contact> contactList= [SELECT Id, aop_Is_Qualified_for_Events__c,aop_Last_Qualifying_Event__c,aop_Suspended_for_Events__c,aop_Country__c FROM Contact WHERE Id =: userList.get(0).ContactId ];
        
        aop_NationalityToISOCode__c aop_aux=aop_NationalityToISOCode__c.getValues(contactList.get(0).aop_Country__c);
        //If there is an Area Configuration related to this contact, we are going in
        if(aop_aux !=null){
            System.debug('************ COUNTRY MAPPING CHECKFRONT INSTANCE '+aop_aux.aop_Checkfront_Instance__c);
            aconf=[SELECT aop_Checkfront_Instance__c,aop_Rebooking_Window__c FROM aop_Area_Configuration__c WHERE aop_Checkfront_Instance__c=:aop_aux.aop_Checkfront_Instance__c];
        //If there is no Area Configuration related to this contact, we are going in
        }else{
            System.debug('************ There is no Area Configuration related to this contact: '+contactList.get(0).Id+' - Contry mapping: '+contactList.get(0).aop_Country__c);
        }
        
        //It takes a record type whose DeveloperName is eaqul to aop_Event_Booking
        List<RecordType> rt= [SELECT Id FROM RecordType WHERE DeveloperName='aop_Event_Booking'];
        //It selects several attributes from CampaingMember
        List<CampaignMember> campaignMemberList = [SELECT aop_Session_Start__c, RecordTypeId,aop_CF_Status__c 
                                FROM CampaignMember 
                                WHERE ContactId =: contactList.get(0).Id AND RecordTypeId=:rt.get(0).Id 
                                AND aop_CF_Status__c != 'Cancelled' AND aop_CF_Status__c != 'Void' AND aop_CF_Status__c != 'NSC Cancelled' AND aop_CF_Status__c != 'No-Show' 
                                AND aop_CF_Status__c != 'Attended' limit 1];
        //If campaignMemberList is not null and its size is greater than 0, we are going in
        if(campaignMemberList !=null && campaignMemberList.size()>0){
            System.debug('************ REDIRECTION TO MY PROFILE PAGE');
            res= '/s/my-profile' ;
            
            
        }else{
            //If campaignMemberList either is null or its size is greater than 0, we are going in
            System.debug('************ there is no campaign member related to this contact: '+ contactList.get(0).Id);
            //Contact is qualified and not suspended
            if(contactList.get(0).aop_Is_Qualified_for_Events__c && !contactList.get(0).aop_Suspended_for_Events__c){   
                System.debug('************ CONTACT IS QUALIFIED AND IS NOT SUSPENDED');
                System.debug('************ CONTACT aop_Last_Qualifying_Event__c  '+contactList.get(0).aop_Last_Qualifying_Event__c);
                if(aconf !=null && aconf.size()>0 && (contactList.get(0).aop_Last_Qualifying_Event__c!=null 
                                                      && DateTime.now()> contactList.get(0).aop_Last_Qualifying_Event__c.addDays(Integer.valueOf(aconf.get(0).aop_Rebooking_Window__c*7)))  || contactList.get(0).aop_Last_Qualifying_Event__c == null){
                    System.debug('************ CONTACT IS OUT OF REBOOKING WINDOW AFTER THE LAST QUALIFYING EVENT');
                    res= '/s/book-event';
                                                          
                }
            }else if(contactList.get(0).aop_Is_Qualified_for_Events__c){
              
                if(aconf !=null && aconf.size()>0 && (contactList.get(0).aop_Last_Qualifying_Event__c!=null 
                && DateTime.now()< contactList.get(0).aop_Last_Qualifying_Event__c.addDays(Integer.valueOf(aconf.get(0).aop_Rebooking_Window__c*7)))  ){
            
                    System.debug('************ Contact is into rebooking window after the kas qualifying event ');
                    res= '/s/my-profile';
                }                   
         	}             
    	}
        system.debug('Site.getPathPrefix(): '+Site.getPathPrefix());
        PageReference landingPage=new PageReference(Site.getPathPrefix()+res);
        return landingPage;  
	}
}