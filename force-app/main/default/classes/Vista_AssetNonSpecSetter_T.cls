@isTest
public class Vista_AssetNonSpecSetter_T {
	static testmethod void Set_DoesNothing_GivenRequestWithNullChildren()
	{
		Vista_AssetNonSpecSetter nonSpecSetter = CreateNonSpecSetter();


		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		Asset asset = new Asset();


		nonSpecSetter.Set(asset, recordGroup);

		System.assert(true);
	}

	static testmethod void Set_SetsAssetVistaStatus_GivenVistaStatus()
	{
		Vista_AssetNonSpecSetter nonSpecSetter = CreateNonSpecSetter();


		String status = 's1';

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.Misc = new Vista_OrderService.Misc();
		recordGroup.VistaVehicleOrder.Misc.CommonStatusPoint = status;
		Asset asset = new Asset();


		nonSpecSetter.Set(asset, recordGroup);

		System.assertEquals(status, asset.Vista_Status__c);
	}

	static testmethod void Set_SetsAssetDescriptionGroup_GivenDescriptionGroupId()
	{
		Vista_AssetNonSpecSetter nonSpecSetter = CreateNonSpecSetter();


		String description = 'd1';

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
		recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = description;
		Asset asset = new Asset();


		nonSpecSetter.Set(asset, recordGroup);

		System.assertEquals(description, asset.Description_Group_Id__c);
	}

	static testmethod void Set_SetsAssetContractNumber_GivenContractNumber()
	{
		Vista_AssetNonSpecSetter nonSpecSetter = CreateNonSpecSetter();


		String contractNumber = 'c1';

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.Contract = new Vista_OrderService.Contract();
		recordGroup.VistaVehicleOrder.Contract.ContractNumber = contractNumber;
		Asset asset = new Asset();


		nonSpecSetter.Set(asset, recordGroup);

		System.assertEquals(contractNumber, asset.Vista_Contract_Number__c);
	}

	static testmethod void Set_SetsAssetRegistrationNumber_GivenRegistrationNo()
	{
		Vista_AssetNonSpecSetter nonSpecSetter = CreateNonSpecSetter();


		String registrationNo = 'r1';

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.Registration = new Vista_OrderService.Registration();
		recordGroup.VistaVehicleOrder.Registration.RegistrationNo = registrationNo;
		Asset asset = new Asset();


		nonSpecSetter.Set(asset, recordGroup);

		System.assertEquals(registrationNo, asset.Registration_Number__c);
	}

	static testmethod void Set_SetsAssetHandoverDate_GivenHandoverDate()
	{
		Vista_AssetNonSpecSetter nonSpecSetter = CreateNonSpecSetter();


		String dateString = '2016-12-17';
		Date expectedDate = Date.newInstance(2016, 12, 17);

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.Customer = new Vista_OrderService.Customer();
		recordGroup.VistaVehicleOrder.Customer.CustomerHandoverDate = dateString;
		Asset asset = new Asset();


		nonSpecSetter.Set(asset, recordGroup);

		System.assertEquals(expectedDate, asset.Handover_Date__c);
	}


	private static Vista_AssetNonSpecSetter CreateNonSpecSetter()
	{
		Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
		return new Vista_AssetNonSpecSetter(dateAdapter);
	}

	private static Vista_RecordGroup CreateEmptyRecordGroup()
	{
		Vista_RecordGroup recordGroup = new Vista_RecordGroup();

		recordGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();

		return recordGroup;
	}
}