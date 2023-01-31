public class Vista_ExistingRecordRetriever implements Vista_EntityRetriever_I {
	private final Set<Vista_EntityRetriever_I> entityRetrievers;


	public Vista_ExistingRecordRetriever(Set<Vista_EntityRetriever_I> entityRetrievers) 
	{
		this.entityRetrievers = entityRetrievers;
	}


	public void Retrieve(Vista_RequestCollection requestCollection)
	{
		for(Vista_EntityRetriever_I entityRetriever : entityRetrievers) {
			entityRetriever.Retrieve(requestCollection);
		}
	}
}