global class RecordShareRemover implements Database.Batchable<SObject>, Database.Stateful, Schedulable{
	public DateTime cutoffTime;
	
	
    global void execute(SchedulableContext SC) 
    {
    	this.cutoffTime = DateTime.now().AddHours(-Integer.valueOf(System.Label.ShareRecordLifetime));
    	Database.executebatch(this);
    }
    
    
	global Database.QueryLocator start(Database.BatchableContext info)
    {
    	return Database.getQueryLocator([Select Name, Created_Date__c From ObjectShareRecord__c Where Created_Date__c <:cutoffTime]);
	}
	
	global void execute(Database.BatchableContext info, List<ObjectShareRecord__c> objectShareRecords)
	{
		List<SObject> objectsForDelete = new List<SObject>();
		
		for(ObjectShareRecord__c objectShareRecord : objectShareRecords){
			Schema.SObjectType sobjectType = ((Id)objectShareRecord.Name).getSObjectType();
			SObject sharedRecord = sobjectType.newSObject(objectShareRecord.Name);
			objectsForDelete.add(sharedRecord);
		}
		
		Database.delete(objectsForDelete, false);//merging 2 deletes might break limit
		delete objectShareRecords;
	}

	global void finish(Database.BatchableContext info)
	{
		
    }
}