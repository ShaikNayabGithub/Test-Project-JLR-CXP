@IsTest
public class SObjectCountrySetter_Test {
    static testMethod void EqualiseCountryAndCode_DoesNotChangeISOCode_GivenLeadsWithDifferentCodesAndCountries() {
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
        InsertNationalityToISOCodeSetting('1','1');
        InsertNationalityToISOCodeSetting('2','2');
        InsertNationalityToISOCodeSetting('3','3');

        Lead lead1 = new Lead();
        lead1.Country_ISO_Code__c = '1';
        lead1.Country = '3';

        Lead lead2 = new Lead();
        lead2.Country_ISO_Code__c = '2';
        lead2.Country = '2';

        Schema.DescribeFieldResult countryField = Lead.Country.getDescribe();

        sObjectCountrySetter.EqualiseCountryAndCodes(new List<Lead> {lead1}, new List<Lead> {lead2}, countryField);

        System.assertEquals('1', lead1.Country_ISO_Code__c);
    }

    static testMethod void EqualiseCountryAndCode_DoesNotChangeCountry_GivenLeadsWithDifferentCodesAndCountries() {
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
        InsertNationalityToISOCodeSetting('1','1');
        InsertNationalityToISOCodeSetting('2','2');
        InsertNationalityToISOCodeSetting('3','3');

        Lead lead1 = new Lead();
        lead1.Country_ISO_Code__c = '1';
        lead1.Country = '3';

        Lead lead2 = new Lead();
        lead2.Country_ISO_Code__c = '2';
        lead2.Country = '2';

        Schema.DescribeFieldResult countryField = Lead.Country.getDescribe();

        sObjectCountrySetter.EqualiseCountryAndCodes(new List<Lead> {lead1}, new List<Lead> {lead2}, countryField);

        System.assertEquals('3', lead1.Country);
    }

    static testMethod void EqualiseCountryAndCode_DoesNotChangeCode_GivenLeadWithNullCountryAndMatchingCodes() {
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
        InsertNationalityToISOCodeSetting('2','2');
        InsertNationalityToISOCodeSetting('3','3');

        Lead lead1 = new Lead();
        lead1.Country = '2';

        Lead lead2 = new Lead();
        lead2.Country_ISO_Code__c = '2';
        lead2.Country = '2';

        Schema.DescribeFieldResult countryField = Lead.Country.getDescribe();

        sObjectCountrySetter.EqualiseCountryAndCodes(new List<Lead> {lead1}, new List<Lead> {lead2}, countryField);

        System.assertEquals(null, lead1.Country_ISO_Code__c);
    }

    static testMethod void EqualiseCountryAndCode_DoesNotChangeCountry_GivenLeadWithNullCountryAndMatchingCodes() {
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
        InsertNationalityToISOCodeSetting('2','2');
        InsertNationalityToISOCodeSetting('3','3');

        Lead lead1 = new Lead();
        lead1.Country_ISO_Code__c = '2';

        Lead lead2 = new Lead();
        lead2.Country_ISO_Code__c = '2';
        lead2.Country = '2';

        Schema.DescribeFieldResult countryField = Lead.Country.getDescribe();

        sObjectCountrySetter.EqualiseCountryAndCodes(new List<Lead> {lead1}, new List<Lead> {lead2}, countryField);

        System.assertEquals(null, lead1.Country);
    }


    static testMethod void EqualiseCountryAndCode_SetsCode_GivenLeadWithNewCountryAndMatchingCodes() {
        InsertNationalityToISOCodeSetting('2','2');
        InsertNationalityToISOCodeSetting('3','3');
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();

        Lead lead1 = new Lead();
        lead1.Country = '3';

        Lead lead2 = new Lead();
        lead2.Country_ISO_Code__c = '2';
        lead2.Country = '2';

        Schema.DescribeFieldResult countryField = Lead.Country.getDescribe();

        sObjectCountrySetter.EqualiseCountryAndCodes(new List<Lead> {lead1}, new List<Lead> {lead2}, countryField);

        System.assertEquals('3', lead1.Country_ISO_Code__c);
    }

    static testMethod void EqualiseCountryAndCode_SetsCountry_GivenLeadWithNewCodeAndMatchingCountry() {
        InsertNationalityToISOCodeSetting('2','2');
        InsertNationalityToISOCodeSetting('3','3');
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();

        Lead lead1 = new Lead();
        lead1.Country_ISO_Code__c = '3';

        Lead lead2 = new Lead();
        lead2.Country_ISO_Code__c = '2';
        lead2.Country = '2';

        Schema.DescribeFieldResult countryField = Lead.Country.getDescribe();

        sObjectCountrySetter.EqualiseCountryAndCodes(new List<Lead> {lead1}, new List<Lead> {lead2}, countryField);

        System.assertEquals('3', lead1.Country);
    }

    static testMethod void EqualiseCountryAndCodes_SetsCountry_GivenLeadWithNewCodeAndMatchingCountry() {
        InsertNationalityToISOCodeSetting('2','2');
        InsertNationalityToISOCodeSetting('3','3');
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();

        List<Lead> leads1 = new List<Lead>();
        Lead lead1 = new Lead();
        lead1.Country_ISO_Code__c = '3';
        leads1.add(lead1);

        List<Lead> leads2 = new List<Lead>();
        Lead lead2 = new Lead();
        lead2.Country_ISO_Code__c = '2';
        lead2.Country = '2';
        leads2.add(lead2);

        Schema.DescribeFieldResult countryField = Lead.Country.getDescribe();

        sObjectCountrySetter.EqualiseCountryAndCodes(leads1, leads2, countryField);

        System.assertEquals('3', lead1.Country);
    }

    private static void InsertNationalityToISOCodeSetting(string code, string country)
    {
        aop_NationalityToISOCode__c setting = new aop_NationalityToISOCode__c();
        setting.Name = country;
        setting.aop_ISO_Code__c = code;
        setting.aop_Checkfront_Instance__c = 'http://placeholder.com';
        insert setting;
    }
}