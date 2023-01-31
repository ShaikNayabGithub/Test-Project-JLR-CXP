@IsTest
public class VehicleSpecificationByNameRetriever_Test {
	/*@IsTest
	static void Validate_ReturnsEmptyVehicleSpecification_GivenNoneRetrieved()
	{
		VehicleSpecificationByNameRetriever retriever = new VehicleSpecificationByNameRetriever();
		Vehicle_Specification__c vehicleSpec = retriever.RetrieveDerivative('test', 'test', 'test');
		System.assertEquals(vehicleSpec.Name, null); 
	}
	
	@IsTest(seeAllData=true)
	static void Validate_ReturnsCorrectVehicleSpecification_BasedOnDerivative() 
	{
		Vehicle_Specification__c derivative = TestClass_VehicleSpecificationBuilder.BuildDerivative();
		Vehicle_Specification__c make = [Select Name From Vehicle_Specification__c Where Id =:derivative.Make__c ];
		Vehicle_Specification__c model = [Select Name From Vehicle_Specification__c Where Id =:derivative.Model__c ];
		VehicleSpecificationByNameRetriever retriever = new VehicleSpecificationByNameRetriever();
		Vehicle_Specification__c vehicleSpec = retriever.RetrieveDerivative(make.Name, model.Name, derivative.Name);
		System.assertEquals(vehicleSpec.Id, derivative.Id);
	}*/
}