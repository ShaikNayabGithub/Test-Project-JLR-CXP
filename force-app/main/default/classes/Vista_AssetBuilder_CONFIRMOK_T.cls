@isTest
public class Vista_AssetBuilder_CONFIRMOK_T {
	static testmethod void Constructor_SetsEventCodeToConfirmOk_WhenCalled()
	{
		Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
		Vista_AssetNonSpecSetter nonSpecSetter = new Vista_AssetNonSpecSetter(dateAdapter);
		Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();

		Vista_AssetBuilder_CONFIRMOK assetBuilder = new Vista_AssetBuilder_CONFIRMOK(nonSpecSetter, specSetter);

		System.assertEquals(Vista_EventCodes.CONFIRMOK, assetBuilder.EventCode);
	}
}