/*
* @description  Helper class for Case.trigger to Filter records based on criteria
* @author       Uvais Komath@Changi Consulting
* @V1.0         Uvais Komath - Created - 02-May-2019 
*/
public class CaseTriggerFilter {
    
    /*
* @description  returns Mena Records
* @author       Uvais Komath@Changi Consulting
*/    
    public static List<Case> getMenaRecords(List<Case> allRecords)
    {
        Set<Id> QueueIds = new Set<Id>();
        List<Case> MenaRecords = new List<Case>();
        List<QueueSobject> menaQueues = [SELECT QueueId FROM QueueSobject WHERE Queue.Name ='E2C - MENA Land Rover' 
                                         OR Queue.Name ='E2C - MENA Jaguar'];
        for(QueueSobject qs : menaQueues)
            QueueIds.add(qs.QueueId);
        
        for(Case cs : allRecords)
        {
            //If owned by a mena user, then the owner market field will have 'MENA' // Or Have a Mena Queue as owner 
            if(cs.Owner_Region_Or_Market__c == 'MENA' || (string.valueOf(cs.OwnerId).startsWith('00G') && QueueIds.contains(cs.OwnerId)))
            {
                MenaRecords.add(cs);
            }
            
        }   
        return MenaRecords;
    }

        /*
* @description  returns Korea Records
* @author       Mike.Backhouse@nttdata.com
*/    
public static List<Case> getKoreaRecords(List<Case> allRecords)
{
    Set<Id> koreaQueueIds = new Set<Id>();
    List<Case> koreaRecords = new List<Case>();
    List<QueueSobject> koreaQueues = [SELECT QueueId FROM QueueSobject WHERE Queue.Name ='Korea CRC Queue' ];
    for(QueueSobject qs : koreaQueues)
        koreaQueueIds.add(qs.QueueId);
    
    for(Case cs : allRecords)
    {
        //If owned by a korea user, then the owner market field will have 'Korea' // Or Have a Korea Queue as owner 
        if(cs.Owner_Region_Or_Market__c == 'Korea' || (string.valueOf(cs.OwnerId).startsWith('00G') && koreaQueueIds.contains(cs.OwnerId)))
        {
            koreaRecords.add(cs);
        }
        
    }   
    return koreaRecords;
}

}