/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class GetMatchingAccountsResponseDto extends BaseResponseDto
{
    @AuraEnabled
    public List<MatchingAccountAttributeDto> Accounts {get; set;}

    public void OrderAccountsByMatchScore() {
        if (Accounts.size() > 0) {
            Accounts.sort();
        }
    }
}