public class Vista_EnhancedDbDeleter implements Vista_EnhancedDbSaver_I {
	private final Vista_ErrorWriter errorWriter;


	public Vista_EnhancedDbDeleter(Vista_ErrorWriter errorWriter)
	{
		this.errorWriter = errorWriter;
	}


	public Set<String> Save(List<String> keys, List<SObject> records, 
			Vista_RequestCollection requestCollection)
	{
		Database.DeleteResult[] deleteResults = Database.delete(records, false);

		Set<String> erroneousKeys = new Set<String>();
		for(Integer i = 0; i < deleteResults.Size(); i++) {
			if(!deleteResults[i].isSuccess()) {
				erroneousKeys.add(keys[i]);
				Database.Error[] errors = deleteResults[i].getErrors();
				this.errorWriter.WriteErrors(keys[i], errors, requestCollection);
			}
		}

		return erroneousKeys;
	}
}