@isTest
public class Vista_AssetBuilder_SPECMEND_T {
	static testmethod void Constructor_SetsEventCodeToSpecMend_WhenCalled()
	{
		Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
		Vista_AssetNonSpecSetter nonSpecSetter = new Vista_AssetNonSpecSetter(dateAdapter);
		Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();
		
		Vista_AssetBuilder_SPECMEND assetBuilder = new Vista_AssetBuilder_SPECMEND(nonSpecSetter, specSetter);

		System.assertEquals(Vista_EventCodes.SPECMEND, assetBuilder.EventCode);
	}
}