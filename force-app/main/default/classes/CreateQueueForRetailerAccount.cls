public class CreateQueueForRetailerAccount {
	private final QueueNameCreator queueNameCreator = new QueueNameCreator();
	
	public void CreateQueues(List<Account> retailerAccounts)
	{	
		list<Group> retailerQueues = new list<Group>();
		
		Map<String, Account> groupandAccountMap = new Map<String, Account>();
		
		Set<Id> accountIDs = new Set<Id>();

		//List<Account> accountsToProcess = new List<Account>();

		for (Account acct : retailerAccounts)
		{
			accountIDs.add(acct.Id);
		}

		for (Account a: [Select Dealer_CI_Code__c, Dealer_CI_Code_2__c, Queue_ID__c, Id, BillingCity, Name from Account where Id in :accountIDs]){
			String queueName = this.queueNameCreator.BuildQueueName(a);
			Group retailerQueue = new Group(Type = 'Queue', Name = queueName, DoesSendEmailToMembers = true);

			retailerQueues.add(retailerQueue);

			groupandAccountMap.put(retailerQueue.Name, a);
		}

		list<String> queueSObjectsSerialised = new List<String>();

		map<Id, Account> accountsToUpdate = new map<Id, Account>();

		if(retailerQueues.size()>0){

			try{
				Database.insert(retailerQueues, false);
			}catch(DMLException dE){
				//Todo Throw Exception 
			}	
		}

		for(Group g: retailerQueues){ // Check there is an id

			Account a = groupandAccountMap.get(g.Name);
			a.Queue_ID__c = g.Id;

			accountsToUpdate.put(a.Id, a);

			QueueSobject queueSupportedEntity = new QueueSobject(SobjectType = 'Lead', QueueId = g.Id);				
			queueSObjectsSerialised.add(JSON.serialize(queueSupportedEntity));	
		}

		if(accountsToUpdate.size()>0){

			update accountsToUpdate.values();
		}

		if(queueSObjectsSerialised.size()> 0){

			try{
				//insert queueSObjects;
				InsertQueueSObjects.performInsert(queueSObjectsSerialised);
			}catch(DMLException dE){
					system.Debug(dE);
			}

		}

		//update retailerAccounts;
	}
}