/**
 * Created by GrantMillgate-EasyTe on 2020-03-04.
 */
@IsTest
public with sharing class RecordTypeUtilityTest {

@IsTest
public static void doTest(){
    //ARRANGE

    //ACT
    Id corporate = RecordTypeUtility.getRecordTypeId_Account_Corporate();
    Id individual = RecordTypeUtility.getRecordTypeId_Account_Individual();
    Id goldenCorporate = RecordTypeUtility.getRecordTypeId_Account_CorporateGoldenRecord();
    Id goldenIndividual = RecordTypeUtility.getRecordTypeId_Account_IndividualGoldenRecord();
    //ASSERT
}
}