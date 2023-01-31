public with sharing class AccountSubTeamHandler {
    
    private static Set<String> enabledIsoCodes = new Set<String>{'KR'};

    public static void setAccountSubteamForEnabledMarkets(List<Account> newAccounts) {
        List<Account> enabledAccounts = new List<Account>();
        Set<Id> ownerIds = new Set<Id>();
        for(Account acc : newAccounts) {
            if(enabledIsoCodes.contains(acc.Country_ISO_Code__c) || enabledIsoCodes.contains(acc.Country_ISO_Code__pc) ) {
                enabledAccounts.add(acc);
                ownerIds.add(acc.OwnerId);
            }
        }
        

        if(enabledAccounts.size() == 0) {
            return;
        }

        ownerIds.add(UserInfo.getUserId());

        Map<Id, User> owners = new Map<Id, User>([
            SELECT Id, Division, Dealer_CI_Code__c, Dealer_CI_Code_2__c 
            FROM User 
            WHERE Id IN :ownerIds
        ]);

        for(Account enabledAccount : enabledAccounts) {
            User owner;
            if(enabledAccount.ownerId != null) {
                owner = owners.get(enabledAccount.ownerId);
            } else {
                owner = owners.get(UserInfo.getUserId());
            }
            String dynamicSubTeamName = 'KR-';

            if(owner.Dealer_CI_Code__c != null) {
                dynamicSubTeamName += owner.Dealer_CI_Code__c.trim() + '-';
            }

            if(owner.Dealer_CI_Code_2__c != null) {
                dynamicSubTeamName += owner.Dealer_CI_Code_2__c.trim() + '-';
            }

            if(owner.Division != null) {
                dynamicSubTeamName += owner.Division.trim();

                enabledAccount.Sub_team_Name__c = dynamicSubTeamName;
            }



            


            String externalId = 'KR';
                if(enabledAccount.LastName != null) {
                    externalId += '-' + enabledAccount.LastName;
                } else {
                    externalId += '-' + enabledAccount.Name;
                }

                if(enabledAccount.PersonMobilePhone != null) {
                    externalId += '-' + enabledAccount.PersonMobilePhone;
                } 
/*
                if(enabledAccount.Phone != null) {
                    externalId += '-' + enabledAccount.Phone;
                }
*/
                if(enabledAccount.Preferred_Sales_Retailer__c != null) {
                    externalId += '-' + enabledAccount.Preferred_Sales_Retailer__c;
                }
                enabledAccount.External_ID_SF__c = externalId;
        }

    }
}