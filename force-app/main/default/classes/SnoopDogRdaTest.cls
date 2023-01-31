/**
 * Created by caleb@argologic.com.au on 26/08/2020.
 */

@IsTest
public with sharing class SnoopDogRdaTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        Asset vehicle = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Vehicle_Specification__c spec =  [SELECT Name FROM Vehicle_Specification__c WHERE Id = :vehicle.Brand__c];
        spec.Name = Constants.MAKE_NAME_LAND_ROVER;
        update spec;
        RDA__c rda = TestClass_RDACreater.BuildRDA(null, TestClass_AccountCreator.GenerateCorporateAccount().Id, TestClass_AccountCreator.createPersonAccount_Australia().Id, vehicle.Id);
        insert rda;

        RestContext.request = new RestRequest();
        RestContext.request.params.put('dateStart', '2019-01-01');
        RestContext.response = new RestResponse();

        // ACT
        Test.startTest();
        SnoopDogRdaService.get();
        Test.stopTest();

        // ASSERT
    }

    @IsTest
    public static void test2()
    {
        // ARRANGE
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        // ACT
        Test.startTest();
        System.debug(Json.serialize(SnoopDogRdaService.get()));
        Test.stopTest();

        // ASSERT
    }
}