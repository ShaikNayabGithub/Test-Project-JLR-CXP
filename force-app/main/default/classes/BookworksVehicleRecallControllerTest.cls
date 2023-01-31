/**
 * Created by caleb on 30/09/2022.
 */

@IsTest
public with sharing class BookworksVehicleRecallControllerTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        Test.setMock(HttpCalloutMock.class, new BookworksVehicleRecallMock());

        // ACT
        BookworksVehicleRecallController.sendRecalledVehiclesToBookworks(new List<String> { '123' });
    }
}