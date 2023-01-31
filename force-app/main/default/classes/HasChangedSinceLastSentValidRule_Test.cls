@IsTest
public class HasChangedSinceLastSentValidRule_Test {
    
    @IsTest(SeeAllData=true)
    public static void Validate_ThrowsADmsOutboundInvalidDataException_WhenGivenAnOpportunity_ThatHasALastModifiedDateLessThanOrEqualToTimeLastSentToDMS(){
        
        HasChangedSinceLastSentValidationRule lastSentValidRule = new HasChangedSinceLastSentValidationRule();
        
        Account account = new Account(
            Name = 'Al Test',
            Phone = '1234567890'
        );
        insert account;
        
        Contact contact = new Contact(
            LastName = 'Al Test',
            AccountId = account.Id,
            Email = 'Al@test.com'
        );
        insert contact;
        
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        opportunity.AccountId = account.Id;
        update opportunity;
        opportunity = [select LastModifiedDate, Account.LastModifiedDate  
                      from Opportunity where id=:opportunity.Id];
        opportunity.TimeLastSentToDMS__c = opportunity.LastModifiedDate;
        opportunity.Account.TimeLastSentToDMS__c = opportunity.Account.LastModifiedDate;
        
        OpportunityContactRole oppContactRole = new OpportunityContactRole(
            OpportunityId = opportunity.Id,
            ContactId = contact.Id
        );       
        insert oppContactRole;
        oppContactRole = [select LastModifiedDate from OpportunityContactRole where ContactId=:contact.Id][0];
        //opportunity.OpportunityContactRoles[0].Contact.LastModifiedDate <= opportunity.OpportunityContactRoles[0].Contact.TimeLastSentToDMS__c )
        
        Boolean result = false;
        
        try{
            lastSentValidRule.Validate(opportunity);
        }       
        catch (Exception e){
            result = true;
        }
        System.assert(result);
    }

}