/**
 * Created by caleb on 26/04/2022.
 */

@IsTest
public with sharing class OSBServiceTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        vehicle.Registration_Number__c = '123';
        insert vehicle;
        Account acc = new Account(Id = vehicle.AccountId, Country_ISO_Code__c = 'AU');
        update acc;

        // ACT
        Test.startTest();
        List<OSBService.ResponseDto> res = OSBService.post(null, '123');
        Test.stopTest();

        // ASSERT
        System.assert(res.size() == 1);
    }

    @IsTest
    public static void test2()
    {
        // ARRANGE
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle(true);
        vehicle.Registration_Number__c = '123';
        insert vehicle;
        Account acc = new Account(Id = vehicle.AccountId, Country_ISO_Code__c = 'AU', Phone = '0421000000');
        update acc;

        // ACT
        Test.startTest();
        List<OSBService.ResponseDto> res = OSBService.post('0421000000', null);
        Test.stopTest();

        // ASSERT
        System.assert(res.size() == 1);
    }
}