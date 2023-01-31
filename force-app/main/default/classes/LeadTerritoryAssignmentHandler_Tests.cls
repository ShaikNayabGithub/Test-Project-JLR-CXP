@isTest
public class LeadTerritoryAssignmentHandler_Tests {
    
    @TestSetup
    static void makeData(){
        Territory2Model model = new Territory2Model();
        model .DeveloperName = 'JLR_Territory_Model'; 
        model.Name = 'JLR_Territory_Model'; 
        insert model ;

        Territory2Type dealerSubGroupType  = [SELECT id, DeveloperName from Territory2Type where  DeveloperName = 'Dealer_Sub_Group' LIMIT 1];

        Territory2 territory = new Territory2();
        territory.DeveloperName = 'KR_01074_01074_Bundang_Team_2';
        territory.Name = 'KR-01074-01074-Bundang Team 2';
        territory.Territory2ModelId = model.Id;
        territory.Territory2TypeId = dealerSubGroupType.Id;
        insert territory;
        
    }

    @isTest 
    public static void Test_LeadTerritoryAssignments() {
        Account testRetailer = TestClass_AccountCreator.BuildRetailer();
        testRetailer.Record_Sub_Type__c = 'Dual Brand';
        insert testRetailer;
        Contact testContact = TestClass_ValidContactBuilder.Build(testRetailer);

        User currentUser = new User(Id=UserInfo.getUserId());
        //User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        User testUser = new User();
        System.runAs(currentUser) {
            testUser = TestClass_UserCreator.CreateRetailerUser(testContact);
            testUser.Market__c = 'Korea';
            testUser.Country_ISO_Code__c = 'KR';
            testUser.Division = 'Bundang Team 2';
            testUser.Dealer_CI_Code__c = '01074';
            testUser.Dealer_CI_Code_2__c = '01074';
            update testUser;
        }

        

        

        Test.startTest();

        Lead myLead;
        System.runAs(testUser) {
            myLead = TestClass_LeadCreator.CreateConvertableLead('Private');

        }
        Test.stopTest();

        List<ObjectTerritory2Association> output = [SELECT ObjectId FROM ObjectTerritory2Association WHERE AssociationCause = 'Territory2Manual' AND ObjectId = :myLead.Id]; 
        Assert.areEqual(1, output.size());
        
    }
}