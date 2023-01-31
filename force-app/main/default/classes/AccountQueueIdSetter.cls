public class AccountQueueIdSetter {
	private final QueueNameCreator queueNameCreator = new QueueNameCreator();
	private Integer uniqueIndex = 0;
	
	private final static RecordType RETAILER_RECORD_TYPE = AccountUtilities.RecordTypes.get('Retailer');
	private final static String RECORD_SUBTYPE = 'Dual Brand';
	
    public void CreateQueues(List<Account> accounts)
	{	
		Map<Integer, Account> accountMap = this.CreateParentRetailerMap(accounts);
		
		Map<Integer, String> queueNamesByAccountIndex = this.BuildQueueNames(accountMap);
		Map<String, Group> queuesByName = this.RetrieveExistingQueuesByName(queueNamesByAccountIndex.Values());
		
		List<Group> queuesInserted = this.CreateNewQueues(accountMap, queueNamesByAccountIndex, queuesByName);
		this.SetAccountQueueId(accountMap, queueNamesByAccountIndex, queuesByName);
		this.CreateQueueSObjects(queuesInserted);
	}
	
	
	private Map<Integer, Account> CreateParentRetailerMap(List<Account> accounts)
	{
		Map<Integer, Account> accountMap = new Map<Integer, Account>();
		for(Account account : accounts){
			if(account.RecordTypeId != RETAILER_RECORD_TYPE.Id || account.Record_Sub_Type__c != RECORD_SUBTYPE) { continue; }
			accountMap.put(uniqueIndex, account);
			uniqueIndex++;
		}
		return accountMap;
	}
	
	private Map<Integer, String> BuildQueueNames(Map<Integer, Account> accounts)
	{
		Map<Integer, String> queueNamesByAccountId = new Map<Integer, String>();
		for(Integer index : accounts.KeySet()){
			Account account = accounts.get(index);
			String queueName = this.queueNameCreator.BuildQueueName(account);
			queueNamesByAccountId.put(index, queueName);
		}
		return queueNamesByAccountId;
	}
	
	private Map<String, Group> RetrieveExistingQueuesByName(List<String> names)
	{
		Map<String, Group> existingQueuesByName = new Map<String, Group>();
		List<Group> existingQueues = [SELECT Name FROM Group WHERE Type = 'Queue' AND Name IN: names];
		
		for(Group existingQueue : existingQueues) {
			existingQueuesByName.put(existingQueue.Name, existingQueue);
		}
		return existingQueuesByName;
	}
	
	private List<Group> CreateNewQueues(Map<Integer, Account> accountMap, Map<Integer, String> queueNamesByAccountId, Map<String, Group> queuesByName)
	{
		List<Group> queuesForInsert = new List<Group>();
		for(Integer accountIndex : accountMap.KeySet()) {
			String queueName = queueNamesByAccountId.get(accountIndex);
			Group queue = queuesByName.get(queueName);
			if(queue == null) {
				queue = new Group(Type = 'Queue', Name = queueName, DoesSendEmailToMembers = true);
				queuesForInsert.Add(queue);
				queuesByName.put(queueName, queue);
			}
		}
		insert queuesForInsert;
		return queuesForInsert;
	}
	
	private void SetAccountQueueId(Map<Integer, Account> accountMap, Map<Integer, String> queueNamesByAccountId, Map<String, Group> queuesByName)
	{
		for(Integer accountIndex : accountMap.KeySet()) {
			String queueName = queueNamesByAccountId.get(accountIndex);
			Group queue = queuesByName.get(queueName);
			Account account = accountMap.get(accountIndex);
			account.Queue_Id__c = queue.Id;
		}
	}
	
	private void CreateQueueSObjects(List<Group> queuesInserted)
	{
		List<String> queueSObjectsSerialised = new List<String>();
		for(Group queueInserted : queuesInserted) {
			QueueSobject queueSupportedEntity = new QueueSobject(SobjectType = 'Lead', QueueId = queueInserted.Id);				
			queueSObjectsSerialised.add(JSON.serialize(queueSupportedEntity));
		}
		if(queueSObjectsSerialised.size() == 0){ return; }
		InsertQueueSObjects.performInsert(queueSObjectsSerialised);
	}
}