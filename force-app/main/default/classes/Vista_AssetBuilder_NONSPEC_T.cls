@isTest
public class Vista_AssetBuilder_NONSPEC_T {
	static testmethod void Constructor_SetsEventCodeToNonSpec_WhenCalled()
	{
		Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
		Vista_AssetNonSpecSetter nonSpecSetter = new Vista_AssetNonSpecSetter(dateAdapter);
		Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();

		Vista_AssetBuilder_NONSPEC assetBuilder = new Vista_AssetBuilder_NONSPEC(nonSpecSetter, specSetter);

		System.assertEquals(Vista_EventCodes.NONSPEC, assetBuilder.EventCode);
	}
}