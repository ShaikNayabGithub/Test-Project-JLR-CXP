/**
 * @description       : check for duplicated individual customer  on digital guestbook
 * @author            : HK
 * @group             :
 * @last modified on  : 2022. 12. 10
 * @last modified by  : HK
 **/
public without sharing class KORDupAccountController {

    @AuraEnabled
    public static List<Account> getDupAccountByNamePhone(String lastName, String phone){
        try {
            Id currentUserId = UserInfo.getUserId();
            User userInfo = [
                SELECT Id, AccountId
                FROM User
                WHERE Id = :currentUserId
            ];
            
            List<Account> searchResult = [
                SELECT Id, LastName, PersonMobilePhone, Owner.LastName, (SELECT Id FROM Opportunities WHERE IsClosed = false)
                FROM Account
                WHERE Owner.AccountId = :userInfo.AccountId
                AND LastName = :lastName
                AND PersonMobilePhone = :phone
            ];
            return searchResult;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrentUserRole(){
        try {
            Id currentUserId = UserInfo.getUserId();
            User usr = [
                SELECT Id, lastName, UserRole.Name
                FROM User
                WHERE Id = :currentUserId
            ];
            return usr.UserRole?.Name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}