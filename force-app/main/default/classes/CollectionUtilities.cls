public class CollectionUtilities {
	public static Set<Id> MergeSets(List<Set<Id>> sets)
	{
		Set<Id> mergedSet = new Set<Id>();
		for(Set<Id> childSet : sets) {
			mergedSet.addAll(childSet);
		}
		return mergedSet;
	}

	public static List<List<SObject>> Batch(List<SObject> inputList, Integer batchSize)
	{
		List<List<SObject>> batchedLists = new List<List<SObject>>();

		for(Integer i = 0; i <= inputList.Size()/batchSize; i++) {
			List<SObject> subList = new List<SObject>();
			Integer recordOffset = i*batchSize;

			for(Integer j = recordOffset; (j < inputList.Size() && j < (recordOffset + batchSize)); j++) {
				subList.add(inputList[j]);
			}
			
			if(subList.Size() > 0) {
				batchedLists.add(subList);
			}
		}

		return batchedLists;
	}
}