public without sharing class aopcom_CountdownCmp {
 
    @auraenabled   
    public static datetime bringDate (){       
        
        datetime eventDate=Datetime.now(); 
        System.debug('++++++++++++++++++INITIAL DATE '+eventDate);
        Id identifier;
        campaignmember aux;
        User idd;
        list<campaignmember> campaignlist;
        list<User> idlist = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('++++++++++++++++++USER IDENTIFIER '+UserInfo.getUserId());
        if(idlist!=null && idlist.size()>0){
        	idd= idlist.get(0);
            identifier= idd.ContactId;
        }
        System.debug('++++++++++++++++++CONTACT IDENTIFIER '+identifier);
        if(Identifier!=null){
            campaignlist = [SELECT aop_Session_Start__c FROM campaignmember WHERE  ContactId =: identifier AND aop_Session_Start__c> TODAY limit 1];            
            if(campaignlist!=null && campaignlist.size()>0){
                aux= campaignlist.get(0);
                eventDate= aux.aop_Session_Start__c;                       
                }        
               
            }
         System.debug('++++++++++++++++++FINAL EVENT DATE '+eventDate);
         return eventDate;
    }
}