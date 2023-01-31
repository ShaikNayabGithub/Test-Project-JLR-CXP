public with sharing class CustomerRegistrationFlowController {
    
    // Yes
    @AuraEnabled(cacheable=true)
    public static List<Campaign> getRetailerCampaigns() {
        return [
            SELECT Id, Name 
            FROM Campaign 
            WHERE IsActive = true 
            ORDER BY Name
            LIMIT 200
        ];
    }
    
    //Yes
    @AuraEnabled(cacheable=true)
    public static List<Vehicle_Specification__c> getVechicleSpecificationData() {
        return [
            SELECT Id, Name, aop_JLR_Owned__c , RecordType.DeveloperName, Make__c
            FROM Vehicle_Specification__c  
            WHERE Is_Korea__c = true
            ORDER BY Name ASC
        ];
    }
    /*
// to remove
@AuraEnabled(cacheable=true)
public static String getSalutationPicklistData() {
return 'To Remove';
}
//to remove
@AuraEnabled(cacheable=true)
public static String getOccupationPicklistData() {
List<PicklistWrapper> pickListValuesList= new List<PicklistWrapper>();
Schema.DescribeFieldResult fieldResult = Lead.Occupation__c.getDescribe();
List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
for( Schema.PicklistEntry pickListVal : ple){
System.debug(pickListVal);

PicklistWrapper pickWrapper = new PicklistWrapper();
pickWrapper.apiName = pickListVal.getValue();
pickWrapper.label = pickListVal.getLabel();
pickListValuesList.add(pickWrapper);
System.debug('wrapper:');
System.debug(pickWrapper);
}     
return JSON.serialize(pickListValuesList);
}

*/
    
    //Yes
    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getCampaignMembers(String campaignId) {
        return [
            SELECT Id, Name, FirstName, LastName, Email, MobilePhone, LeadId 
            FROM CampaignMember 
            WHERE CampaignId = :campaignId
            ORDER BY LastName
            LIMIT 500
        ];
    }
    
    // Yes
    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> searchCampaignMembers(String campaignId, String searchTerm) {
        if(searchTerm == null || searchTerm == '') {
            return getCampaignMembers(campaignId);
        }
        
        String preparedSearchTerm = '%' + searchTerm.trim() + '%';
        return [
            SELECT Id, Name, FirstName, LastName, Email, MobilePhone, LeadId 
            FROM CampaignMember 
            WHERE CampaignId = :campaignId
            AND Name LIKE :preparedSearchTerm
            ORDER BY LastName
        ];
    }
    
    
    //Yes
    @AuraEnabled(cacheable=true)
    public static String getRetailerData() {
       // Map<String, String> ownerIdToName = new Map<String, String>();
        Map<Id, Account> retailerAccounts = new Map<Id, Account>([SELECT Id, Name, NameLocal, Parent.NameLocal, Default_Lead_Owner_Id__c FROM Account WHERE RecordType.Name = 'Retailer' AND Record_Sub_Type__c  = 'Dual Brand']);
        system.debug('retaileraccounts');
        system.debug(retailerAccounts);
        Map<Id,User> retailerUsers = new Map<Id,user>([SELECT Id, LastName,Contact.AccountId FROM User WHERE Id  = :UserInfo.getUserId() or (Contact.AccountId IN :retailerAccounts.keySet() AND IsActive = true AND profile.Name IN ('Sales Manager/Receptionist MENA','Sales Executive MENA')) order by lastName ]);
        system.debug('retaileruser');
        system.debug(retailerAccounts.keySet());
        system.debug(retailerUsers);
       
        RetailerData outputData = new RetailerData();
       // outputData.ownerIdToDescription = retailerUsers;
        outputData.retailerAccounts = retailerAccounts.values();
        outputData.currentUser = retailerUsers.get(UserInfo.getUserId());
        outputData.userList = retailerUsers.values();
       // outputData.accountUsers = accountUsers;
               // system.debug(JSON.serialize(outputData.accountUsers));
        system.debug( '@@output@@'+JSON.serialize(outputData));
        return JSON.serialize(outputData);
    }
    
    
    // GuestBook method. Yes
    @AuraEnabled
    public static id insertLead(String leadData){
        Lead newLead = (Lead) JSON.deserialize(leadData,Lead.class);
        //newLead.ownerId = '00G1q000005FsudEAC';
        insert newLead;
        
        //added for CXPD-2523 :Lead Capture Form: Marketing Pref Change.This is specific for Korea
        //List<Lead> leadLocal = new List<Lead>();
        //leadLocal.add(newLead);
        //system.debug(leadLocal[0].DoNotCall);
        //System.debug('newLead :'+ leadLocal);
        //ConsentHandler.setConsentsCustom(leadLocal, leadLocal[0].DoNotCall);
        
        //end for CXPD-2523
        
        
        CampaignMember cm = new CampaignMember();
        cm.LeadId = newLead.Id;
        cm.CampaignId = newLead.Campaign__c;
        cm.Status = 'Responded';
        cm.CurrencyIsoCode = 'KRW';
        try {
            insert cm;
        } catch(Exception e) {
            system.debug(e);
        }
        
        return newLead.id;
        
        
        
    }
    
    //Yes
    @AuraEnabled
    public static String setCampaignMemberAsResponded(String campaignMemberId){
        CampaignMember cm = new CampaignMember();
        cm.Id = campaignMemberId;
        cm.Status = 'Responded';
        cm.CurrencyIsoCode = 'KRW';
        
        update cm;
        
        return '200';
    }
    /*
@AuraEnabled
public static void insertProduct2Method(String Product2Data){
Product2 newProduct2 = (Product2) JSON.deserialize(Product2Data,Product2.class);
insert newProduct2;
}

@AuraEnabled
public static void createLead(String leadData){
System.debug('lead data in apex');
System.debug(leadData);
Lead newLead = (Lead) JSON.deserialize(leadData, Lead.class);

insert newLead;
}
*/
    
    public class PicklistWrapper {
        String apiName;
        String label;
    }
    public class salutationpickWrapper{
        String apiName;
        String label;   
    }
    
    public class RetailerData {
        // List<User> ownerIdToDescription;
        @AuraEnabled
         public List<Account> retailerAccounts;
        @AuraEnabled
        public User currentUser;
        //Map<Id, List<Map<String, String>>> accountUsers;
       // List<AccountDTO> retailerAccounts;
        @AuraEnabled
       public List<user> userList;
        
        
    }
    
    
    
}