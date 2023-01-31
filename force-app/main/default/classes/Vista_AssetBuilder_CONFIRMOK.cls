public class Vista_AssetBuilder_CONFIRMOK extends Vista_AssetBuilder_A{
	public Vista_AssetBuilder_CONFIRMOK(Vista_AssetNonSpecSetter nonSpecSetter, Vista_AssetSpecSetter specSetter)
	{
		super(nonSpecSetter, specSetter);
		this.EventCode = Vista_EventCodes.CONFIRMOK;
	}


	protected override void Build(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection)
	{
		//do nothing
	}
}