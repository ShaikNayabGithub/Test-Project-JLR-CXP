/**
 * @description       : Test class for KORDupAccountController.cls
 * @author            : HK
 * @group             :
 * @last modified on  : 2022. 12. 10
 * @last modified by  : HK
 **/
@isTest
public with sharing class KORDupAccountControllerTest {


    @isTest
    public static void testCase1(){

        Test.startTest();
        KORDupAccountController.getDupAccountByNamePhone('Kim', '010');
        KORDupAccountController.getCurrentUserRole();
        Test.stopTest();
    }



}