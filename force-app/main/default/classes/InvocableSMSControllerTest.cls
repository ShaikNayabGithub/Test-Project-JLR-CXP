/**
 * Created by Ethan Sargent on 24/2/20.
 */

@IsTest
public class InvocableSMSControllerTest
{
    static final String REQUEST_FAILURE = '{ "body": "invalid"}';

    @TestSetup static void setup()
    {
        // Create test data here
    }

    @IsTest
    static void createSMSActivity()
    {
        // ARRANGE

        Contact con = TestClass_ValidContactBuilder.Build();
        Case newCase = TestClass_CaseCreator.Create('Facebook');
        // ACT

        Test.startTest();
        InvocableSmsController.CreateSMSActivity(con.Id, newCase.Id, 'test');
        Test.stopTest();

        // ASSERT
    }

    @IsTest
    static void SendToMailjet()
    {
        // ARRANGE
        SmsSendRequestDto request = new SmsSendRequestDto();
        request.To = '+61411000000';
        request.SenderName = 'TEST SENDER';
        request.ContactId = null;
        request.CaseId = null;
        request.Text = 'TEST SMS DATA';

        // ACT
        Test.setMock(HttpCalloutMock.class, new InvocableSMSControllerTestMock());
        Test.startTest();
        InvocableSmsController.SendToMailjet(request);
        Test.stopTest();

        // ASSERT

    }

    @IsTest
    static void invalidRequest()
    {
        // ARRANGE
        SmsSendRequestDto request = new SmsSendRequestDto();
        request.To = '+61411000000';
        request.SenderName = 'TEST SENDER';

        // ACT
        Test.setMock(HttpCalloutMock.class, new InvocableSMSControllerTestMock());
        Test.startTest();
        JlrCustomException expectedException;
        try
        {
            InvocableSmsController.SendToMailjet(request);
        } catch (JlrCustomException e) {
            expectedException = e;
        }
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, expectedException, 'Exception expected in this situation');
    }



}