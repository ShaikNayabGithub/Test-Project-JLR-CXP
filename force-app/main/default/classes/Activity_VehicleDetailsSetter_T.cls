@isTest
public class Activity_VehicleDetailsSetter_T {
	static testmethod void SetVehicleDetails_DoesNothing_GivenEmptyList()
	{
		Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();

		List<Event> events = new List<Event>();

		vehicleDetailsSetter.SetVehicleDetails(events);

		System.assert(true);
	}

	static testmethod void SetVehicleDetails_DoesNotSetVIN_GivenEventWithNoAsset()
	{
		Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();

		Event event1 = new Event();
		List<Event> events = new List<Event> { event1 };

		vehicleDetailsSetter.SetVehicleDetails(events);

		System.assert(String.isEmpty(event1.VIN__c));
	}

	static testmethod void SetVehicleDetails_SetsVINToV1_GivenEventWithAssetWithVINV1()
	{
		Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();

		String vin1 = 'V1';

		Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
		asset1.VIN__c = vin1;
		insert asset1;

		Event event1 = new Event(WhatId = asset1.Id);
		List<Event> events = new List<Event> { event1 };


		vehicleDetailsSetter.SetVehicleDetails(events);


		System.assertEquals(vin1, event1.VIN__c);
	}

	static testmethod void SetVehicleDetails_SetsModelYearToY1_GivenEventWithAssetWithModelYearY1()
	{
		Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();

		String modelYear1 = 'Y1';

		Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
		asset1.Model_Year__c = modelYear1;
		insert asset1;

		Event event1 = new Event(WhatId = asset1.Id);
		List<Event> events = new List<Event> { event1 };


		vehicleDetailsSetter.SetVehicleDetails(events);


		System.assertEquals(modelYear1, event1.VIN_Model_Year__c);
	}

	static testmethod void SetVehicleDetails_SetsBrandToAssetBrand_GivenEventWithAssetWithBrand()
	{
		Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();

		Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
		insert asset1;
		Vehicle_Specification__c brand = [SELECT Name FROM Vehicle_Specification__c WHERE Id =: asset1.Brand__c];

		Event event1 = new Event(WhatId = asset1.Id);
		List<Event> events = new List<Event> { event1 };


		vehicleDetailsSetter.SetVehicleDetails(events);


		System.assertEquals(brand.Name, event1.VIN_Brand__c);
	}

	static testmethod void SetVehicleDetails_SetsModelToAssetModel_GivenEventWithAssetWithModel()
	{
		Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();

		Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
		insert asset1;
		Product2 model = [SELECT Name FROM Product2 WHERE Id =: asset1.Model__c];

		Event event1 = new Event(WhatId = asset1.Id);
		List<Event> events = new List<Event> { event1 };


		vehicleDetailsSetter.SetVehicleDetails(events);


		System.assertEquals(model.Name, event1.VIN_Model__c);
	}

	static testmethod void SetVehicleDetails_SetsDerivativeToAssetDerivative_GivenEventWithAssetWithDerivative()
	{
		Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();

		Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
		insert asset1;
		Product2 derivative = [SELECT Name FROM Product2 WHERE Id =: asset1.Derivative__c];

		Event event1 = new Event(WhatId = asset1.Id);
		List<Event> events = new List<Event> { event1 };


		vehicleDetailsSetter.SetVehicleDetails(events);


		System.assertEquals(derivative.Name, event1.VIN_Derivitive_Name__c);
	}

	static testmethod void SetVehicleDetails_SetsProductToAssetProduct_GivenEventWithAssetWithProduct()
	{
		Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();

		String derivativeName = 'TestDerivative';
		String product1Name = 'p1';
		Product2 product1 = new Product2(Name = product1Name);
		insert product1;

		Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
		asset1.Product2Id = product1.Id;		
		insert asset1;

		Event event1 = new Event(WhatId = asset1.Id);
		List<Event> events = new List<Event> { event1 };

		vehicleDetailsSetter.SetVehicleDetails(events);

		
		System.assertEquals(derivativeName, event1.VIN_Product_Name__c);
	}
}