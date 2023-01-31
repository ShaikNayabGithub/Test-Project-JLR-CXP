public without sharing class aopcom_CommunityLayoutCmp {
     
    @auraEnabled
    public static  void logout(){
        logout();
    }
    
    @auraEnabled
    public static List<aop_NationalityToISOCode__c> initial(){
        Id communityId=Network.getNetworkId();
        List<Network> networks= [SELECT UrlPathPrefix FROM Network WHERE Id =: String.valueOf(communityId)];
        //System.debug('++++++++++++ Community context: '+networks.get(0).UrlPathPrefix);
        
        String res='';
        String error='false';
        List<User> userList;
        List<Contact> contactList;
        List<CampaignMember> campaignMemberList;
        List<CampaignMember> campaignMember;
        List<Campaign> campaign;
        Id userId=UserInfo.getUserId();
        List<aop_Area_Configuration__c> aconf2;
        aop_NationalityToISOCode__c aop=new aop_NationalityToISOCode__c();
        
        List<aop_NationalityToISOCode__c> lista= new List<aop_NationalityToISOCode__c>();
        
        System.debug('+++++++++++There is no cache information');
        
        lista=[SELECT aop_ISO_Code__c, Name, aop_Checkfront_Instance__c FROM aop_NationalityToISOCode__c ORDER BY Name];
        List<aop_Area_Configuration__c> aconf=[SELECT aop_Checkfront_Instance__c,aop_NSC_Contact_Email__c,aop_NSC_Contact_Phone__c FROM aop_Area_Configuration__c ];    
        System.debug('++++++++++++++ ACONF SIZE : '+aconf.size());
        
        Map<String,String> mapa=new Map<String, String>();
        
        for(integer i=0;i<aconf.size();i++){
            System.debug('++++++++++++++ extraction map : '+mapa.get(aconf.get(i).aop_Checkfront_Instance__c));
            if(mapa.get(aconf.get(i).aop_Checkfront_Instance__c)==null){
                mapa.put(aconf.get(i).aop_Checkfront_Instance__c,aconf.get(i).aop_NSC_Contact_Email__c+' - '+aconf.get(i).aop_NSC_Contact_Phone__c);
                System.debug('+++++++++++++++Checkfront instance: '+aconf.get(i).aop_Checkfront_Instance__c);
                System.debug('+++++++++++++++Contact Information: '+aconf.get(i).aop_NSC_Contact_Email__c+' - '+aconf.get(i).aop_NSC_Contact_Phone__c);
            }
        }
        System.debug('+++++++++++Final Map Size: '+mapa.size());
        for (integer i=0;i<lista.size();i++){
            String contacto=mapa.get(String.valueOf(lista.get(i).aop_Checkfront_Instance__c));
            System.debug('+++++++++++++++++Checkfront instance searched: ' +lista.get(i).aop_Checkfront_Instance__c);
            System.debug('++++++++++++++++++ Contact: '+contacto);
            if(contacto != null){
                lista.get(i).aop_Checkfront_Instance__c= contacto;    
            }else{
                lista.get(i).aop_Checkfront_Instance__c= 'Not available';    
            }
            
        }
        
        System.debug('************ User Id: ************ '+userId);
        userList = [SELECT ContactId FROM User WHERE Id =: userId];
        
        System.debug('************ Result first stage: '+res);
        contactList= [SELECT Id, FirstName, LastName, aop_Is_Qualified_for_Events__c,aop_Last_Qualifying_Event__c,aop_Suspended_for_Events__c,aop_Country__c FROM Contact WHERE Id =: userList.get(0).ContactId ];
        res=res+contactList.get(0).FirstName+' '+contactList.get(0).LastName+'#';
        res=res+Site.getPathPrefix()+'#';
        System.debug('************ Contact SObject obtained: '+contactList.get(0).Id);
        System.debug('************ CONTACT CHECKFRONT COUNTRY: '+contactList.get(0).aop_Country__c);
        aop_NationalityToISOCode__c aop_aux=aop_NationalityToISOCode__c.getValues(contactList.get(0).aop_Country__c);
        if(aop_aux !=null){
            System.debug('************ COUNTRY MAPPING CHECKFRONT INSTANCE '+aop_aux.aop_Checkfront_Instance__c);
            aconf=[SELECT aop_Checkfront_Instance__c,aop_Rebooking_Window__c,aop_AWS_Path__c,aop_Spotify_Link__c FROM aop_Area_Configuration__c WHERE aop_Checkfront_Instance__c=:aop_aux.aop_Checkfront_Instance__c.replace('http://','')];
            System.debug('************ ACONF SIZE  '+aconf.size());
            if(aconf !=null && aconf.size()>0 ){
                System.debug('************ AWS PATH  '+aconf.get(0).aop_AWS_Path__c);
                System.debug('************ SPOTIFY PATH  '+aconf.get(0).aop_Spotify_Link__c);
                res=res+aconf.get(0).aop_AWS_Path__c+'#'+aconf.get(0).aop_Spotify_Link__c+'#';
            }
        }else{
            System.debug('************ There is no Area Configuration related to this contact: '+contactList.get(0).Id+' - Contry mapping: '+contactList.get(0).aop_Country__c);
        }
        
        
        
        if(contactList!=null && contactList.size()>0){ 
            System.debug('************ CONTACT EXIST: '+contactList.get(0).Id);
            List<RecordType> rt= [SELECT Id FROM RecordType WHERE DeveloperName='aop_Event_Booking'];
            System.debug('************ Record Type Id '+ rt.get(0).Id);
            campaignMemberList = [SELECT aop_Session_Start__c, RecordTypeId,aop_CF_Status__c 
                                  FROM CampaignMember 
                                  WHERE ContactId =: contactList.get(0).Id AND RecordTypeId=:rt.get(0).Id 
                                  AND aop_CF_Status__c != 'Cancelled' AND aop_CF_Status__c != 'Void' AND aop_CF_Status__c != 'NSC Cancelled' AND aop_CF_Status__c != 'No-Show' 
                                  AND aop_CF_Status__c != 'Attended' limit 1];
            if(campaignMemberList !=null && campaignMemberList.size()>0){
                System.debug('************ CAMPAIGN MEMBER FOR THAT CONTACT EXIST');
                res= res+'myprofile#myevent#amendbooking';
                System.debug('************ Result second stage: '+res);
                
            }else{
                System.debug('************ there is no campaign member related to this contact: '+ contactList.get(0).Id);
                if(contactList.get(0).aop_Is_Qualified_for_Events__c && !contactList.get(0).aop_Suspended_for_Events__c){   
                    System.debug('************ CONTACT IS QUALIFIED AND IS NOT SUSPENDED');
                    System.debug('************ CONTACT aop_Last_Qualifying_Event__c  '+contactList.get(0).aop_Last_Qualifying_Event__c);
                    if(aconf !=null && aconf.size()>0 && (contactList.get(0).aop_Last_Qualifying_Event__c!=null 
                                                          && DateTime.now()> contactList.get(0).aop_Last_Qualifying_Event__c.addDays(Integer.valueOf(aconf.get(0).aop_Rebooking_Window__c*7)))  || contactList.get(0).aop_Last_Qualifying_Event__c == null){
                                                              System.debug('************ CONTACT IS OUT OF REBOOKING WINDOW AFTER THE LAST QUALIFYING EVENT');
                                                              res= res+'bookevent';
                                                              System.debug('************ Result third stage: '+res);
                                                              
                                                          }else{
                                                              System.debug('************ Contact is into rebooking window after the kas qualifying event or has no Area Configuration');
                                                              error='true';
                                                          }
                }
            }
        }else{
            System.debug('************ User has no contact associated *************** error -> true ');
            error='true';
        }
        system.debug('Valor de networks: '+networks);
        if(networks.size()>0){
        res=res+'#'+networks.get(0).UrlPathPrefix+'#'+error;
        }
        System.debug('************ Final result '+ res);
        aop.Name=res;
        lista.add(aop);
        return lista;
    }
   
     @auraEnabled
    public static String loadCheckFront(){
        String res='';
        List<aop_Area_Configuration__c> aconf;
        List<User> userList = [SELECT FirstName, LastName, ContactId, LanguageLocaleKey FROM User WHERE Id =: UserInfo.getUserId()];
        res=UserList.get(0).ContactId+'#';
        List<Contact> contactList= [SELECT Id,aop_Is_Qualified_for_Events__c,aop_Last_Qualifying_Event__c,aop_Suspended_for_Events__c,aop_Country__c FROM Contact WHERE Id =: userList.get(0).ContactId ];
        List<aop_Locale_Mapping__c> aop_localeList=aop_Locale_Mapping__c.getAll().values();
        aop_NationalityToISOCode__c aop_aux=aop_NationalityToISOCode__c.getValues(contactList.get(0).aop_Country__c);
        System.debug('*************** aop_localeList size: '+aop_localeList.size());
        if(aop_localeList.size()>0 && aop_localeList != null){
           boolean found=false;
            for (integer i=0; i<aop_localeList.size(); i++){
                if(aop_localeList.get(i).aop_Salesforce_Language__c ==userList.get(0).LanguageLocaleKey){
                    found=true;
                    System.debug('************ userList.get(0).LanguageLocaleKey: '+userList.get(0).LanguageLocaleKey);
                    System.debug('************ aop_Locale found: '+aop_localeList.get(i).aop_Salesforce_Language__c);
                    if(aop_aux !=null){
                        System.debug('************ COUNTRY MAPPING CHECKFRONT INSTANCE '+aop_aux.aop_Checkfront_Instance__c);
                        aconf=[SELECT aop_Checkfront_Instance__c,aop_Checkfront_AOP_Id__c FROM aop_Area_Configuration__c WHERE aop_Checkfront_Instance__c=:aop_aux.aop_Checkfront_Instance__c.replace('http://','')];
                         System.debug('************ Checkfront Instance '+aconf.get(0).aop_Checkfront_Instance__c);
                        if(aconf!=null && aconf.size()>0){
                            System.debug('************ Previous RES '+res);
                            res=res+aconf.get(0).aop_Checkfront_Instance__c+'#'+aconf.get(0).aop_Checkfront_AOP_Id__c+'#'+aop_localeList.get(i).aop_Checkfront_Language_Code__c;
                            
                            System.debug('************ Checkfront Instance '+aconf.get(0).aop_Checkfront_Instance__c);
                            System.debug('************ aop_Checkfront_AOP_Id__c '+aconf.get(0).aop_Checkfront_AOP_Id__c);
                            System.debug('************ aop_Checkfront_Language_Code__c '+aop_localeList.get(i).aop_Salesforce_Language__c);
                            break;
                        }
                    }else{
                        System.debug('************ ERROR: There is no Area Configuration related to this contact: '+contactList.get(0).Id+' - Contry mapping: '+contactList.get(0).aop_Country__c);
                    }
                }
            }
            if(!found)
                    System.debug('************ ERROR: aop_Locale not found');
            
        }else{
            System.debug('************ ERROR: There is no aop_Locale_Mapping__c entries');    

        }
        System.debug('************ Final footer result: '+res);
        return res;
    }

}