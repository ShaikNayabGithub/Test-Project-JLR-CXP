@isTest
public class OpportunityCICodeClearer_Test {
    static testmethod void Clear_RemovesDealerCICode_GivenOpportunityLineItemForOpportunityWithNoOthers()
    {
        User user = CreateRetailerUser();
        
        System.runAs(user){
            Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
            insert opportunity;
            
            Pricebook2 pricebook = TestClass_PricebookCreator.CreatePricebook();
            
            OpportunityLineItem opportunityLineItem = TestClass_OpportunityProductBuilder.BuildLineItem(opportunity, pricebook);
            insert opportunityLineItem;
            
            BrandDealerCICodeMapping__c brandFieldInfo = new BrandDealerCICodeMapping__c();
            brandFieldInfo.Name = ((String)(opportunityLineItem.Brand__c)).left(15);
            brandFieldInfo.FieldName__c = 'Dealer_CI_Code__c';
            insert brandFieldInfo;
            
            Test.startTest();
            
            delete opportunityLineItem;
            
            Test.stopTest();
            
            opportunity = [Select Dealer_CI_Code__c From Opportunity Where Id =: opportunity.Id];
        
            System.assert(String.isEmpty(opportunity.Dealer_CI_Code__c));
        }
    }
    
    static testmethod void Clear_DoesNotRemoveDealerCICode_GivenOpportunityLineItemForOpportunityWithNoMappedBrand()
    {
        User user = CreateRetailerUser();
        
        System.runAs(user){
            Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
            insert opportunity;
            
            Pricebook2 pricebook = TestClass_PricebookCreator.CreatePricebook();
            
            OpportunityLineItem opportunityLineItem = TestClass_OpportunityProductBuilder.BuildLineItem(opportunity, pricebook);
            insert opportunityLineItem;
            
            Test.startTest();
            
            delete opportunityLineItem;
            
            Test.stopTest();
            
            opportunity = [Select Dealer_CI_Code__c From Opportunity Where Id =: opportunity.Id];
            
            System.assert(String.isNotEmpty(opportunity.Dealer_CI_Code__c));
        }
    }
    
    private static User CreateRetailerUser()
    {
        Contact retailerContact;
        
        System.RunAs(new User(Id=UserInfo.getUserId())){
            Account retailAccount = TestClass_AccountCreator.CreateRetailer();
            retailerContact = TestClass_ValidContactBuilder.Build(retailAccount);
        }
        
        return TestClass_UserCreator.CreateRetailerUser(retailerContact);
    }
}