@isTest(SeeAllData=True)
public class testCustomSettings {

    static testMethod void TriggerFramework_JLRSysAdminInstance_ExistsAndValuesAreSet() {
        /*
        String profileToTest = 'JLR System Administrator (Super)';
        User u = TestClass_UserCreator.CreateUser([select id,name from Profile where name = : profileToTest ]);
        System.runAs(u) {
            TriggerFramework__c tf = TriggerFramework__c.getInstance(UserInfo.getProfileId());
            system.assertNotEquals(null,tf.id,'Expected to find a Trigger Framework custom setting for the ' + profileToTest + ' profile but it was not found.');
            system.assertEquals(true,tf.Account_PreUpdate__c,'Expected a TRUE value for Account_PreUpdate__c but instead found: '+tf.Account_PreUpdate__c);

        }
    */
    }
    
    static testMethod void TriggerFramework_OrgDefaultInstance_ExistsAndValuesAreSet() {
        String profileToTest = 'Standard User';
        User u = TestClass_UserCreator.CreateUser([select id,name from Profile where name = : profileToTest ]);
        System.runAs(u) {
            TriggerFramework__c tf = TriggerFramework__c.getInstance(UserInfo.getProfileId());
            system.assertEquals(null,tf.id,'Expected not to find a specific Trigger Framework custom setting for '+profileToTest+' but one was found.');
            system.assertEquals(true,tf.Account_PreUpdate__c,'Expected a TRUE value for Account_PreUpdate__c but instead found: '+tf.Account_PreUpdate__c);
        }
    } //

}