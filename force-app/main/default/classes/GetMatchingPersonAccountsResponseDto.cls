/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class GetMatchingPersonAccountsResponseDto extends BaseResponseDto
{
    @AuraEnabled
    public List<MatchingPersonAccountAttributeDto> PersonAccounts {get; set;}
    
    public void OrderPersonAccountsByMatchScore()
    {
        PersonAccounts.sort();
    }
}