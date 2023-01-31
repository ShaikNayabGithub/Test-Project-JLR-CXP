public class Vista_EnhancedDbSaver_Insert extends Vista_EnhancedDbSaver_A {
	public Vista_EnhancedDbSaver_Insert(Vista_ErrorWriter errorWriter)
	{
		super(errorWriter);
	}


	protected override Database.SaveResult[] ExecuteDml(List<SObject> records)
	{
		return Database.insert(records, false);
	}
}