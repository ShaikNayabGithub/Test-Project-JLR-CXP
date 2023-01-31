/**
 * Created by caleb@argologic.com.au on 10/03/2020.
 */

public without sharing class ChildDealershipUtility
{
    public static String getChildDealership(String accountId, Boolean isJaguar)
    {
        List<Account> parentAccounts = [
                SELECT Dealer_CI_Code__c, Dealer_CI_Code_2__c
                FROM Account
                WHERE Id = :accountId
        ];
        Account parent;
        if (parentAccounts.size() > 0) parent = parentAccounts[0];
        else throw new JlrCustomException('No account found');
        if (isJaguar)
        {
            List<Account> dealersJaguar = [
                    SELECT Id, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Name
                    FROM Account
                    WHERE Dealer_CI_Code__c = :parent.Dealer_CI_Code__c AND ParentId = :accountId
            ];
            if (dealersJaguar.size() > 0) return dealersJaguar[0].Id;
            return null;
        }
        else
        {
            List<Account> dealersLandRover = [
                    SELECT Id, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Name
                    FROM Account
                    WHERE Dealer_CI_Code_2__c = :parent.Dealer_CI_Code_2__c AND ParentId = :accountId
            ];
            if (dealersLandRover.size() > 0) return dealersLandRover[0].Id;
            return null;
        }
    }

    public static Map<String, Account> getParentToChildDealershipMap(List<String> accountIds, Boolean isJaguar)
    {
        List<Account> accounts = [
                SELECT Id, Dealer_CI_Code__c, Dealer_CI_Code_2__c
                FROM Account
                WHERE Id IN :accountIds
        ];
        if (isJaguar)
        {
            List<String> dealerCodes = new List<String>();
            for (Account account : accounts)
            {
                dealerCodes.add(account.Dealer_CI_Code__c);
            }

            System.debug(JSON.serialize(dealerCodes));
            System.debug(JSON.serialize(accountIds));
            List<Account> dealersJaguar = [
                    SELECT Id, ParentId, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Name
                    FROM Account
                    WHERE Dealer_CI_Code__c IN :dealerCodes AND ParentId IN :accountIds AND ParentId != NULL
            ];

            Map<String, Account> result = new Map<String, Account>();
            for (Account account : dealersJaguar)
            {
                result.put(account.ParentId, account);
            }
            return result;
        }
        else
        {
            List<String> dealerCodes = new List<String>();
            for (Account account : accounts)
            {
                dealerCodes.add(account.Dealer_CI_Code_2__c);
            }

            System.debug(JSON.serialize(dealerCodes));
            System.debug(JSON.serialize(accountIds));
            List<Account> dealersLandRover = [
                    SELECT Id, ParentId, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Name
                    FROM Account
                    WHERE Dealer_CI_Code_2__c IN :dealerCodes AND ParentId IN :accountIds AND ParentId != NULL
            ];

            Map<String, Account> result = new Map<String, Account>();
            for (Account account : dealersLandRover)
            {
                result.put(account.ParentId, account);
            }
            return result;
        }
    }
}