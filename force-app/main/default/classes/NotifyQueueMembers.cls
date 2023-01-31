public class NotifyQueueMembers {
    
    public void CheckMembersAndSendEmail(List<Group> allQueues, Map<Lead, Id> leadsWithQueueIds, Map<String, Vehicle_Specification__c> modelsMap,Boolean isPostInsert){
        
        Map<Id, Group> mapqueues = new Map<Id, Group>(allQueues); 
        Map<Id,GroupMember> allGroupMembers = new Map<Id,GroupMember>();        
        Map<Id, User> users = new  Map<Id, User>([Select id, Name, email from user where Web_to_lead_Notification_Opt_in__c = true and isActive = true and email != '' and ID in (select UserOrGroupId from GroupMember where  GroupId IN:mapqueues.keySet()) ]);
        
        Map<String, List<User>> mapQueuewithQueueMembers = mapQueuewithQueueMembersmethod(mapqueues, users);
        map<id,Campaign> CampaignMap = new map<id,Campaign>();
        if(isPostInsert){
            set<id> campaignIdSet = new set<id>();
            for(Lead ld : leadsWithQueueIds.keySet()){
                if(ld != null && ld.NZ_Campaign_Id__c != null){
                    try {
                        campaignIdSet.add(ld.NZ_Campaign_Id__c);
                    } catch(Exception ex) {
                        System.debug('<<< Exception >>> ' + ex.getMessage());
                    }
                }
            }
            if(campaignIdSet != null && !campaignIdSet.isEmpty()){
                for(Campaign camp :[select id,name from Campaign where id IN:campaignIdSet]){
                    CampaignMap.put(camp.id,camp);
                }
            }
        }
        for(Lead ld : leadsWithQueueIds.keySet()){
            List<String> emails = getListOfRecipients( ld, leadsWithQueueIds, mapQueuewithQueueMembers,   mapqueues);     
            Group gr = mapqueues.get(leadsWithQueueIds.get(ld));
            
            if(!emails.isEmpty() && emails.size() > 0 && gr != null ){
                String  First_Name = ''; 
                String Last_Name = ''; 
                String Phone = ''; 
                String Email = '';
                String Enquiry_Type = '';
                String Primary_Model_of_Interest= '';
                String Brand = '';
                String Comments = '';
                String Campaign = '';
                String Test_Drive_Preferred_Date_Time = '';
                String Company='';
                String Mobile='';
                String Description='';
                String Purchase_Type='';
                
                if(ld.FirstName != null){
                    First_Name = ld.FirstName;
                }
                if(ld.LastName != null){
                    Last_Name = ld.lastName;
                }
                if(ld.MobilePhone != null){
                    Phone = ld.MobilePhone;
                } 
                if(ld.Email != null){
                    Email  = ld.Email;
                }  
                if(ld.RecordTypeid != null){
                    Enquiry_Type  = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosById().get(ld.RecordTypeid).getName();
                }  
                if(String.IsNotBlank(ld.Mapping_Primary_Model_of_Interest__c) && modelsMap.containsKey(ld.Mapping_Primary_Model_of_Interest__c.toUpperCase())){
                    Primary_Model_of_Interest = modelsMap.get(ld.Mapping_Primary_Model_of_Interest__c.toUpperCase()).Name;
                }  
                if(ld.Mapping_Brand__c != null){
                    Brand  = ld.Mapping_Brand__c;
                }  
                if(ld.Description != null){
                    Comments = ld.Description;
                }
                if(ld.Campaign__c != null){
                    Campaign = ld.Campaign__c;
                }                
                if(ld.Test_Drive_Preferred_Date_Time__c != null){
                    Test_Drive_Preferred_Date_Time =''+ ld.Test_Drive_Preferred_Date_Time__c;
                } 
                if(ld.Company != null){
                    Company=ld.Company;
                }
                if(ld.MobilePhone != null){
                    Mobile = ld.MobilePhone;
                }
                if(ld.Description != null){
                    Description = ld.Description;
                }
                if(ld.Purchase_Type__c != null){
                    Purchase_Type = ld.Purchase_Type__c;
                }
                             
                System.debug('<<< ModelMaps >>> ' + modelsMap);
                System.debug('<<< Primary_Model_of_Interest >>> ' + Primary_Model_of_Interest);
                
                try{
                    if(ld.Country_ISO_Code__c == 'NZ'){
                        if(isPostInsert){
                            String campName = '';
                            String campId = '';
                            if(ld.NZ_Campaign_Id__c != null && CampaignMap != null && !CampaignMap.isEmpty() && CampaignMap.containskey(ld.NZ_Campaign_Id__c)){
                                campaign campIns = new campaign();
                                campIns = CampaignMap.get(ld.NZ_Campaign_Id__c);
                                if(campIns.Name != null){
                                    campName = campIns.Name;
                                }
                                if(campIns.Id != null){
                                    campId = campIns.Id;
                                }
                            }
                            System.debug('<<< Emails >>> ' + emails);
                            String emailNotification = String.Format(Label.NewZealandLeadNotification,new List<String>{Company,First_Name, Last_Name, Brand,campName,campId,ld.Id, Email, Mobile, Primary_Model_of_Interest, Description});        
                            String emailNotificationSubject = String.Format(Label.NewZealandLeadNotificationSubject,new List<String>{Company,First_Name, Last_Name, Brand,campName});        
                            EmailUtility.SendEmail(emails, 'JLR CXP Notification',emailNotificationSubject, emailNotification.replaceAll('\n','<br/>'),
                                                   '','noreply@jaguarexperience.com',false,null,true);
                        }
                    }
                    else if(ld.Country_ISO_Code__c == 'TW'){
                        String emailNotification = String.Format(Label.taiwanLeadNotification,new List<String>{gr.Name,First_Name, Last_Name, Phone,Email, Enquiry_Type,Primary_Model_of_Interest, Brand, Comments, Purchase_Type});        
                        EmailUtility.SendEmail(emails, 'JLR CXP Notification', Label.taiwanLeadNotificationSubject, emailNotification.replaceAll('\n','<br/>'),
                                               '','noreply@jaguarexperience.com',false,null,true);
                    }else{
                        String emailNotification = String.Format(Label.leadNotificationEmailGeneric,new List<String>{gr.Name,First_Name, Last_Name, Phone,Email, Enquiry_Type,Primary_Model_of_Interest,Brand , Comments, Campaign,Test_Drive_Preferred_Date_Time});        
                        EmailUtility.SendEmail(emails, 'JLR CXP Notification', 'JLR CXP Notification: New Web-to-Lead', emailNotification.replaceAll('\n','<br/>'),
                                               '','noreply@jaguarexperience.com',false,null,true);
                    }                   
                }
                Catch(Exception e){
                    System.debug('ERROR:' + e);
                }
            }
            
        }
    }
    
    public List<String> getListOfRecipients(lead ld, Map<Lead, Id> leadsWithQueueIds, Map<String, List<User>> mapQueuewithQueueMembers,  Map<Id, Group> mapqueues){
        List<String> emails = New List<string>();
        List<User> userAssociatedToLead = new List<User>(mapQueuewithQueueMembers.get(leadsWithQueueIds.get(ld)));
        
        Group gr = mapqueues.get(leadsWithQueueIds.get(ld));            
        if(gr != null && (gr.email != null && gr.email != '')){
            emails.add(gr.Email);                
        }           
        if(userAssociatedToLead != null && userAssociatedToLead.size() > 0 ){
            for(User u : userAssociatedToLead ){
                emails.add(u.email);
            }   
        }
        return emails;
    }
    
    public Map<String, List<User>> mapQueuewithQueueMembersmethod( Map<Id, Group> mapqueues, Map<Id, User> users){
        
        Map<Id,GroupMember> allGroupMembers = new Map<Id,GroupMember>(); 
        Map<String, List<User>> mapQueuewithQueueMembers = new Map<String, List<User>>(); 
        
        for(GroupMember sgm : [SELECT GroupId, Group.Name, UserOrGroupId FROM GroupMember WHERE GroupId IN:mapqueues.keySet() ])
        {
            allGroupMembers.put(sgm.UserOrGroupId,sgm);
        }      
        for(GroupMember gm : allGroupMembers.values()){
            if(mapQueuewithQueueMembers.containsKey(gm.GroupId))
            {
                List<User> lstCont = mapQueuewithQueueMembers.get(gm.GroupId);
                if(users.containsKey(gm.UserOrGroupId)){
                    User lstUser = users.get(gm.UserOrGroupId);
                    lstCont.add(lstUser);
                }             
            }
            else
            {
                if(users.containsKey(gm.UserOrGroupId)){
                    List<User> lstUser = New List<User>();
                    lstUser.add(users.get(gm.UserOrGroupId));                  
                    mapQueuewithQueueMembers.put(gm.GroupId,lstUser);
                }
            }
        }    
        return mapQueuewithQueueMembers;
    } 
}