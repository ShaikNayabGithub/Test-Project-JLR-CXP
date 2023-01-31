public class InsertQueueSObjects {
	
	@future
	public static void performInsert(List<String> queueSObjects) {
		
		List<QueueSObject> queueObjects = new List<QueueSObject>();
		
		for (String queueSer : queueSObjects) {
			
			QueueSObject q = (QueueSObject)JSON.deserialize(queueSer, QueueSObject.class);

			queueObjects.add(q);
			
		}
		
		Database.insert(queueObjects, false);
	}
}