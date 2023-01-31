public class Vista_AssetBuilder_SPECMEND extends Vista_AssetBuilder_A {
	private final Vista_AssetSpecSetter specSetter;


	public Vista_AssetBuilder_SPECMEND(Vista_AssetNonSpecSetter nonSpecSetter, Vista_AssetSpecSetter specSetter) 
	{
		super(nonSpecSetter, specSetter);
		this.EventCode = Vista_EventCodes.SPECMEND;
		this.specSetter = specSetter;
	}


	protected override void Build(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection)
	{
		this.specSetter.Set(asset, request, requestCollection);
	}
}