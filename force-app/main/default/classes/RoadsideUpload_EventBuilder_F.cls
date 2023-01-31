public class RoadsideUpload_EventBuilder_F {
	public RoadsideUpload_EventBuilder Create()
	{
		RoadsideUpload_AssetGetter assetGetter = new RoadsideUpload_AssetGetter();
		RoadsideUpload_WhoGetter whoGetter = new RoadsideUpload_WhoGetter();
		RoadsideUpload_SimpleFieldSetter simpleFieldSetter = new RoadsideUpload_SimpleFieldSetter();

		return  new RoadsideUpload_EventBuilder(assetGetter, whoGetter, simpleFieldSetter);
	}
}