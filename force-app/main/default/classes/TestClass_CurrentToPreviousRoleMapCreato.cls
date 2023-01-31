@isTest
public class TestClass_CurrentToPreviousRoleMapCreato {
    public static CurrentToPreviousRoleMap__c Create(String body)
    {
        CurrentToPreviousRoleMap__c setting = new CurrentToPreviousRoleMap__c();
        setting.Name = 'Current ' + body;
        setting.Previous_Role__c = 'Previous ' + body;
        
        insert setting;
        return setting;
    }
}