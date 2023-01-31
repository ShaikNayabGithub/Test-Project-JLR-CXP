public class MarketByOwnerIdRetriever {
    
    public static Map < Id, User > userMap = new Map < Id, User > ();
    
    public Map<Id, String> Retrieve(Set<String> ownerIds) {
        Map<Id, String> marketsByOwnerId = new Map<Id, String>();
        
        Boolean runUserQuery = false;
        for(String ownerId: ownerIds) {
            if(!userMap.containsKey(ownerId)) {
                runUserQuery = true;
            }
        }
        
        if(runUserQuery) {
            for(User userObj: [SELECT Id, Market__c FROM User WHERE Id IN: ownerIds]) {
                userMap.put(userObj.Id, userObj);
            }
        }
        
        for(String ownerId: ownerIds) {
            if(userMap.containsKey(ownerId)) {
                User userObj = userMap.get(ownerId);
                marketsByOwnerId.put(userObj.Id, userObj.Market__c);
            }
        }
        
        /* for(User user : [SELECT Market__c FROM User WHERE Id IN: ownerIds]) {
            marketsByOwnerId.put(user.Id, user.Market__c);
        } */

        /***
        RecordType retailerRecordType = [SELECT id FROM RecordType WHERE developername ='Retailer'and sObjectType='Account'];
        
        for(Account account : [SELECT Queue_ID__c, Region_or_Market__c FROM Account WHERE Recordtypeid =:retailerRecordType.id and Queue_ID__c IN: ownerIds]) {
            marketsByOwnerId.put((Id)account.Queue_ID__c, account.Region_or_Market__c);
        }
        **/
        
        for(Account account : [SELECT Queue_ID__c, Region_or_Market__c FROM Account WHERE Recordtype.DeveloperName = 'Retailer' and Queue_ID__c IN: ownerIds]) {
            marketsByOwnerId.put((Id)account.Queue_ID__c, account.Region_or_Market__c);
        }
        
        return marketsByOwnerId;
    }
}