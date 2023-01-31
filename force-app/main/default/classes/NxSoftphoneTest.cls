@isTest
public with sharing class NxSoftphoneTest {
    
    @TestSetup
    static void makeData(){
        Account acct = new Account();
        acct.LastName = 'HK Kim';
        acct.PersonMobilePhone = '01012341234';
        acct.recordTypeId = '0121o000000TjjTAAS';
        insert acct;
    }

    @isTest
    public static void testCase1(){

        Id accntId = [
            SELECT Id
            FROM Account
            LIMIT 1
        ]?.Id;
        
        Test.startTest();
        NxSoftphone nx = new NxSoftphone();
        nx.createSoftphone('0101234', '0104321', '1111', false, 'Account', accntId);
        nx.updateSoftphone('1111', 30, 'http://test.recordurl.test');
        nx.updateSoftphone('', 30, 'http://test.recordurl.test');
        nx.createSoftphone('0101234', '0104321', '', false, 'Account', accntId);
        nx.createSoftphone('', '', '1111', false, 'Account', accntId);
        nx.createSoftphone('0101234', '', '1111', false, 'Account', accntId);
        Test.stopTest();

    }
}