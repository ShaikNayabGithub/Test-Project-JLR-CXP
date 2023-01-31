@isTest
public class TestClass_NationalityToISOCodeCreator {
    public static aop_NationalityToISOCode__c Create(string code, string country)
    {
    	aop_NationalityToISOCode__c nationalityToISOCode = new aop_NationalityToISOCode__c();
    	
    	nationalityToISOCode.Name = country;
    	nationalityToISOCode.aop_ISO_Code__c = code;
    	nationalityToISOCode.aop_Checkfront_Instance__c = 'http://placeholder.com';
    	
    	insert nationalityToISOCode;
    	return nationalityToISOCode;
    }
}