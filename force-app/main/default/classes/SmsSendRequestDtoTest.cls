/**
 * Created by caleb@argologic.com.au on 15/06/2020.
 */

@IsTest
public with sharing class SmsSendRequestDtoTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        SmsSendRequestDto req = new SmsSendRequestDto();

        // ACT
        Test.startTest();
        req.To = '+614 21000000';
        req.SenderName = 'Test';
        req.Text = 'This is a message';
        Test.stopTest();

        // ASSERT
        System.assertEquals('+61421000000', req.To);
        System.assertEquals('This is a message', req.Text);
    }

    @IsTest
    public static void test2()
    {
        // ARRANGE
        SmsSendRequestDto req = new SmsSendRequestDto();

        // ACT
        Test.startTest();
        req.To = '+614 21000000';
        req.SenderName = 'Test';
        req.Text = 'This is a message';
        Test.stopTest();

        // ASSERT
        System.assertEquals('+61421000000', req.To);
        System.assertEquals('This is a message', req.Text);
    }

    @IsTest
    public static void test3()
    {
        // ARRANGE
        SmsSendRequestDto req = new SmsSendRequestDto();

        // ACT
        Test.startTest();
        req.To = '0488368628';
        req.SenderName = 'Test';
        req.Text = 'This is a message';
        Test.stopTest();

        // ASSERT
        System.assertEquals('+61488368628', req.To);
        System.assertEquals('This is a message', req.Text);
    }

    @IsTest
    public static void test4()
    {
        // ARRANGE
        SmsSendRequestDto req = new SmsSendRequestDto();

        // ACT
        Test.startTest();
        try
        {
            req.To = '02 2100 0000';
            System.assert(false);
        }
        catch (JlrCustomException ex)
        {

        }
        Test.stopTest();

        // ASSERT

    }

    @IsTest
    public static void test5()
    {
        // ARRANGE
        SmsSendRequestDto req = new SmsSendRequestDto();

        // ACT
        Test.startTest();
        try
        {
            req.Text = ''.rightPad(SmsSendRequestDto.SMS_CHARACTER_LIMIT + 1, 'a');
            System.assert(false);
        }
        catch (JlrCustomException ex)
        {

        }
        Test.stopTest();

        // ASSERT
    }
}