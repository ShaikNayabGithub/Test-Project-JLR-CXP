public class OwnerISOCodeSetter {

    Set<Id> ownerIds = new Set<Id>();
    Map<Id,String> ISOCodeByOwnerId = new Map<Id,String>();
    
    public void SetISOCodes (List<Lead> leads)
    {
        
        for (Lead l: leads)
        {
            if (l.OwnerId != null && l.OwnerId.GetSObjectType() == Schema.User.SObjectType) {
                ownerIds.add(l.OwnerId);
            }
        }
        
        for(User user : [SELECT Country_ISO_Code__c FROM User WHERE Id IN: ownerIds]) {
            ISOCodeByOwnerId.put(user.Id, user.Country_ISO_Code__c);
            System.Debug(user.Country_ISO_Code__c);
        }
     
        for(Lead l: leads) {
            if(l.OwnerId != null && l.OwnerId.GetSObjectType() == Schema.User.SObjectType)
            {
                l.Owner_ISO_Code__c = ISOCodeByOwnerId.get(l.ownerId);
            }
        }
    }

}