public class Vista_AssetBuilder_Default  extends Vista_AssetBuilder_A{
	public Vista_AssetBuilder_Default(Vista_AssetNonSpecSetter nonSpecSetter, Vista_AssetSpecSetter specSetter,
            String eventCode)
	{
		super(nonSpecSetter, specSetter);
		this.EventCode = eventCode;
	}


	protected override void Build(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection)
	{
		//do nothing
	}
}