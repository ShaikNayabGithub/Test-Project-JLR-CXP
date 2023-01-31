public abstract class Vista_EnhancedDbSaver_A implements Vista_EnhancedDbSaver_I {
	private final Vista_ErrorWriter errorWriter;


	public Vista_EnhancedDbSaver_A(Vista_ErrorWriter errorWriter)
	{
		this.errorWriter = errorWriter;
	}


	public Set<String> Save(List<String> keys, List<SObject> records, 
			Vista_RequestCollection requestCollection)
	{
		Database.SaveResult[] insertResults = this.ExecuteDml(records);

		Set<String> erroneousKeys = new Set<String>();
		for(Integer i = 0; i < insertResults.Size(); i++) {
			if(!insertResults[i].isSuccess()) {
				erroneousKeys.add(keys[i]);
				Database.Error[] errors = insertResults[i].getErrors();
				this.errorWriter.WriteErrors(keys[i], errors, requestCollection);
			}
		}

		return erroneousKeys;
	}

	protected abstract Database.SaveResult[] ExecuteDml(List<SObject> records);
}