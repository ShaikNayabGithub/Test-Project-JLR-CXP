@IsTest
public class OpportunityControllerDMSExtension_Test {
    
    @IsTest(SeeAllData=true)
    public static void UpdateDMS_IsCalledThrowingADmsOutboundException(){
        
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);
        OpportunityControllerDMSExtension oppControllerDmsExtension = new OpportunityControllerDMSExtension(stdController);
        Boolean result = true;
        
        try{
    		oppControllerDmsExtension.UpdateDMS();
    	}
        catch(Exception e){
            result = false;
        }
        
        System.assert(result);
    }
    
    @IsTest
    public static void UpdateDMS_IsCalledThrowingAnyException(){
        
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        ApexPages.StandardController stdController = new ApexPages.StandardController(opportunity);
        OpportunityControllerDMSExtension oppControllerDmsExtension = new OpportunityControllerDMSExtension(stdController);       
        Boolean result = true;
        
        try{
    		oppControllerDmsExtension.UpdateDMS();
    	}
        catch(Exception e){
            result = false;
        }
        
        System.assert(result);
    }

    @IsTest
    public static void UpdateDMS_IsCalledForKR(){
        
        Account personAccount = TestClass_AccountCreator.createPersonAccount();
        personAccount.Country_ISO_Code__c = 'KR';
        personAccount.PersonMobilePhone = '01111111';
        update personAccount;  
        
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        opp.AccountId = personAccount.Id;

        insert opp;
        
        
        Boolean result = true;
        
        try{
    		OpportunityControllerDMSExtension.SendToDMS(opp.Id);
    	}
        catch(Exception e){
           result = false;
        }
        
        System.assert(result);
    }

    @IsTest
    public static void UpdateDMS_IsCalledForBR(){
        
        Account personAccount = TestClass_AccountCreator.createPersonAccount();
        personAccount.Country_ISO_Code__c = 'BR';
        personAccount.PersonMobilePhone = '01111111';
        update personAccount;  
        
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        opp.AccountId = personAccount.Id;

        insert opp;
        
        
        Boolean result = true;
        
        try{
    		OpportunityControllerDMSExtension.SendToDMS(opp.Id);
    	}
        catch(Exception e){
           result = false;
        }
        
        System.assert(result);
    }

    @IsTest
    public static void UpdateDMS_IsCalledForBR_withoutDmsOppId(){
        
        Account personAccount = TestClass_AccountCreator.createPersonAccount();
        personAccount.Country_ISO_Code__c = 'BR';
        personAccount.PersonMobilePhone = '01111111';
        update personAccount;  
        
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        opp.AccountId = personAccount.Id;
        opp.DMS_Opportunity_ID__c = null;

        insert opp;
        
        
        Boolean result = true;
        
        try{
    		OpportunityControllerDMSExtension.SendToDMS(opp.Id);
    	}
        catch(Exception e){
           result = false;
        }
        
        System.assert(result);
    }

    @isTest 
    public static void Test_OppNotFoundError() {
        Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
        insert opp;
        Id oppId = opp.Id;
        delete opp;

        Test.startTest();
            OpportunityControllerDMSExtension.SendToDMS(oppId);
        Test.stopTest();
    }
}