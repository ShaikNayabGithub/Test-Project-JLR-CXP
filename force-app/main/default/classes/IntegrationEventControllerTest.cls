/**
 * Created by caleb on 12/09/2019.
 */

@IsTest
public with sharing class IntegrationEventControllerTest
{
    @IsTest
    public static void createEventTest()
    {
        // ARRANGE
        CreateIntegrationEventRequestDto req = new CreateIntegrationEventRequestDto(CreateIntegrationEventRequestDto.EventType.Success , 'This is a Test');

        // ACT
        Test.startTest();
        CreateIntegrationEventResponseDto res = IntegrationEventController.createEvent(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertEquals(true, res.IsSuccess);
    }
}