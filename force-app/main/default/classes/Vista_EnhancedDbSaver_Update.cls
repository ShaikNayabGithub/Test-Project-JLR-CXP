public class Vista_EnhancedDbSaver_Update extends Vista_EnhancedDbSaver_A {
	public Vista_EnhancedDbSaver_Update(Vista_ErrorWriter errorWriter)
	{
		super(errorWriter);
	}


	protected override Database.SaveResult[] ExecuteDml(List<SObject> records)
	{
		return Database.update(records, false);
	}
}