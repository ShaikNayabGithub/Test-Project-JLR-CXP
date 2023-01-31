/**
 * Created by caleb@argologic.com.au on 16/11/2021.
 */

@IsTest
public with sharing class InvocableSendSemiConductorDelayEmails_T
{
    @IsTest(SeeAllData=true)
    public static void test1()
    {
        InvocableSendSemiConductorDelayEmails.SendEmails();
    }
}