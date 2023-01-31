public class Vista_AssetBuilder_RETRY extends Vista_AssetBuilder_A{
	public Vista_AssetBuilder_RETRY(Vista_AssetNonSpecSetter nonSpecSetter, Vista_AssetSpecSetter specSetter)
	{
		super(nonSpecSetter, specSetter);
		this.EventCode = Vista_EventCodes.RETRY;
	}


	protected override void Build(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection)
	{
		//do nothing
	}
}