public without sharing class UserDao {
    public static List<User> getUserById(String userId){
        if(userId == null){
            return null;
        }
        return [Select
                    Id
                    ,isActive
                    ,LastModifiedDate
                    ,Udaan_Active__c
                    ,AccountId
                    ,FirstName
                    ,LastName
                    ,Email
                From
                    User
                Where
                    Id = : userId
                And
                    ProfileId = : ProfileDao.getInstance().getProfileId(Label.Udaan_User_Profile_Name)
               ];
    }
    
    public static List<User> getUserByUserName(String userName){
        if(String.isBlank(userName)){
            return null;
        }
        return [Select
                    Id
                    ,AccountId
                    ,IsActive
                    ,Udaan_Active__c
                    ,Is_new_for_Udaan__c
                    ,CreatedDate
                    ,ProfileId
                    ,CPF__c
                    ,LastPasswordChangeDate
                From
                    User
                Where
                    UserName = :userName
                ];
    }
    public static List<User> getUserCPF(String CPF){
       
        return [Select
                    Id
                    ,AccountId
                    ,IsActive
                    ,Udaan_Active__c
                    ,Is_new_for_Udaan__c
                    ,CreatedDate
                    ,ProfileId
                    ,CPF__c
                    ,LastPasswordChangeDate
                From
                    User
                where CPF__c =:CPF
                ];
    }
    public static List<User> getUdaanActiveUserById(String userId){
        if(userId == null){
            return null;
        }
        return [Select
                    Id
                    ,AccountId
                    ,ContactId
                    ,UserName
                    ,LastModifiedDate
                From
                    User
                Where
                    Id = :userId
                    and isActive = true
                    and Udaan_Active__c = true
                    and ProfileId = : ProfileDao.getInstance().getProfileId(Label.Udaan_User_Profile_Name)
                Limit 1];
    }
    /* 
     **************************************************
    Method Name: getAccountDetails
    Input Parameters: AccountId,String brand
    Return Type: Account 
    Method Description: Method to get account details .
   ****************************************************** */
     public static Account getAccountDetails(String accountId, String brand)
    {
        if(accountId == null){
            return null;
        }
        return [select
                id,
                FirstName,
                LastName,
                Phone,
                CPF__c,
                PersonHasOptedOutOfEmail
                From 
                Account
                Where 
                id = :accountId
                limit 1
               ];
    }
}