public class Vista_AssetBuilder_NONSPEC extends Vista_AssetBuilder_A {
	private final Vista_AssetNonSpecSetter nonSpecSetter;


	public Vista_AssetBuilder_NONSPEC(Vista_AssetNonSpecSetter nonSpecSetter, Vista_AssetSpecSetter specSetter) 
	{
		super(nonSpecSetter, specSetter);
		this.EventCode = Vista_EventCodes.NONSPEC;
		this.nonSpecSetter = nonSpecSetter;
	}


	protected override void Build(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection)
	{
		this.nonSpecSetter.Set(asset, request);
	}
}