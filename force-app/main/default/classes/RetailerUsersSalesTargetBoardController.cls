/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin		17/06/2021			CXPD-1341: Target count is incorrect in Home page
* 
*/
public without sharing class RetailerUsersSalesTargetBoardController {
    
    public static User loggedInUser = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userInfo.getUserId() AND ContactId != null];
    
    // Return list of Target User Ids as per provided UserId
    public static Set < Id > getTargetUserIds(Id userId) {
        Set < Id > managerIds = new Set < Id > ();
        Set < Id > targetUserIds = new Set < Id > ();
        managerIds.add(userId);
        
        // Get the Target Users from Standard User Hierarchy Setup
        do {
            List < User > userList = [SELECT Id, Name, Retailer_Name__c, Profile.Name, Market__c, (SELECT Id, Name, Profile.Name FROM ManagedUsers WHERE isActive = true) FROM User WHERE Id =: managerIds];
            // Reset Manager User Ids
            managerIds = new Set < Id > ();
            if(userList != null && !userList.isEmpty()) {
                for(User userObj: userList) {
                    targetUserIds.add(userObj.Id);
                    for(User managedUserObj: userObj.ManagedUsers){
                        if(managedUserObj.Profile.Name.containsIgnoreCase('Sales Manager')){
                            managerIds.add(managedUserObj.Id);
                        } else {
                            targetUserIds.add(managedUserObj.Id);
                        }
                    }
                }  
            }
        } while(managerIds.size() > 0);
        
        // Get the Target Users from User Role Custom Setup
        managerIds.add(userId);
        do {
            List < User_Role__c > userRoleList = [Select Id, Name, Add_Subordinates__c, MasterUser__c, Viewing_User__c FROM User_Role__c WHERE MasterUser__c =:managerIds AND Viewing_User__c != null];
            // Reset Manager User Ids
            managerIds = new Set < Id > ();
            if(userRoleList != null && !userRoleList.isEmpty()) {
                for(User_Role__c userRoleObj: userRoleList) {
                    targetUserIds.add(userRoleObj.MasterUser__c);
                    if(userRoleObj.Add_Subordinates__c == true) {
                        // Condition added to avoid recursion
                        if(userRoleObj.MasterUser__c != userRoleObj.Viewing_User__c && !targetUserIds.contains(userRoleObj.Viewing_User__c)) {
                            managerIds.add(userRoleObj.Viewing_User__c);
                        }
                    } else {
                        targetUserIds.add(userRoleObj.Viewing_User__c);
                    }
                }
            }
        } while(managerIds.size() > 0);
        
        for(User userObj: [SELECT Id, Name, Profile.Name FROM User WHERE Id IN :targetUserIds]) {
            System.debug('## Name - ' + userObj.Name + ' ## Profile - ' + userObj.Profile.Name);
        }
        return targetUserIds;
    }
    
    @AuraEnabled
    public static List<SalesTargetWrapper> getTargetRecords(String recordTypeName){
        //system.debug(recordTypeName);
        /* List<User_Role__c> usrs = [Select Id, Name, Add_Subordinates__c, Viewing_User__c, Viewing_User__r.Name, Viewing_User__r.Profile.Name FROM User_Role__c WHERE MasterUser__c =:loggedinUser.Id AND Viewing_User__c != null];         
        Set<Id> subordinatesId = new Set<Id>();
        Set<Id> directId = new Set<Id>();
        
        if(usrs != null && usrs.size() > 0){
            for(User_Role__c usr : usrs){
                if(usr.Add_Subordinates__c == true){
                    subordinatesId.add(usr.Viewing_User__c);
                    directId.add(usr.Viewing_User__c);
                }else{
                    directId.add(usr.Viewing_User__c);
                }
            }
            
        } */
        
        Set < Id > targetIds = getTargetUserIds(UserInfo.getUserId());
        
        Id salesTargetRecordtypeId = Schema.SObjectType.Sales_Target__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        SchemaUtility.CurrentDateDetails financialDetails = new SchemaUtility.CurrentDateDetails(system.today().year(), system.today().month());  
        Map<String,SalesTargetWrapper> salesTargetWrapperMap = new Map<String,SalesTargetWrapper>();
        List<SalesTargetWrapper> sortedValues = new List<SalesTargetWrapper>();
        
        List < SalesTargetWrapper > wrapperList = new List < SalesTargetWrapper > ();
        
        // Map < String, List < SalesTargetWrapper >> parentChildSalesTargetWrapperMap = new Map < String, List < SalesTargetWrapper >> ();
        if(loggedInUser != null){
            /* subordinatesId.add(loggedInUser.Id);
            directId.add(loggedInUser.Id);
            
            List<User> salesUsers = [SELECT Id, Name, IsActive, Profile.Name, Partner_Manager__c, Partner_Manager__r.Name, Partner_Manager__r.Partner_Manager__c 
                                     FROM User 
                                     WHERE (Partner_Manager__r.Partner_Manager__c IN :subordinatesId 
                                            OR Partner_Manager__c IN :subordinatesId 
                                            OR Id IN :directId) 
                                     AND IsActive = true 
                                     ORDER BY Profile.Name ASC]; */
            
            List < User > salesUsers = [SELECT Id, Name, IsActive, Profile.Name, Partner_Manager__c, Partner_Manager__r.Name 
                                        FROM User 
                                        WHERE Id IN :targetIds 
                                        AND IsActive = true 
                                        ORDER BY Profile.Name DESC];
            
            for(User salesUser: salesUsers){
                Sales_Target__c sTarget = new Sales_Target__c(Salesperson__c = salesUser.Id, 
                                                              Target_Year__c = '' + financialDetails.financailYear, 
                                                              January_Target__c = 0, 
                                                              February_Target__c = 0,
                                                              March_Target__c = 0, 
                                                              April_Target__c = 0, 
                                                              May_Target__c = 0, 
                                                              June_Target__c = 0, 
                                                              July_Target__c = 0, 
                                                              August_Target__c = 0,
                                                              September_Target__c = 0, 
                                                              October_Target__c = 0, 
                                                              November_Target__c = 0, 
                                                              December_Target__c = 0, 
                                                              RecordtypeId = salesTargetRecordtypeId);
                SalesTargetWrapper sTW = new SalesTargetWrapper();
                sTW.salesPersonName = salesUser.Name;
                sTW.managerName = salesUser.Partner_Manager__r.Name;
                sTW.salesTarget = sTarget;            
                sTW.salesRole = salesUser.Profile.Name;	
                salesTargetWrapperMap.put(salesUser.Id, sTW); 

            }
            List<Sales_Target__c> salesTarget = [SELECT Id, Salesperson__c, Salesperson__r.Name, Salesperson__r.IsActive, 
                                                 January_Target__c, February_Target__c, March_Target__c, April_Target__c, May_Target__c, June_Target__c, 
                                                 July_Target__c, August_Target__c, September_Target__c, October_Target__c, November_Target__c, December_Target__c
                                                  FROM Sales_Target__c 
                                                  WHERE Target_Year__c =: '' + financialDetails.financailYear 
                                                  AND Salesperson__r.AccountId = :loggedInUser.Contact.AccountId 
                                                  AND Salesperson__r.IsActive = true 
                                                  AND RecordTypeId =: salesTargetRecordtypeId 
                                                  ORDER BY Salesperson__r.Name DESC];
            
            for(Sales_Target__c target: salesTarget) {
                if(salesTargetWrapperMap.containsKey(target.Salesperson__c)) {
                    salesTargetWrapperMap.get(target.Salesperson__c).salesTarget = target;
                }
            }
            System.debug('### salesTargetWrapperMap # ' + salesTargetWrapperMap);
            // Search through the Map Wrapper to find every sales manager	
            /*for(SalesTargetWrapper wrapper: salesTargetWrapperMap.values())	{	
                if(wrapper.salesRole != null && !wrapper.salesRole.startsWithIgnoreCase('Dealer Principle')) {	
                    String managerName = wrapper.salesPersonName;
                    if(wrapper.salesRole.startsWithIgnoreCase('Sales Manager/Receptionist')) {	
                        // Once a manager is found, add them to the final list then add every Exec beneath them	
                        // Replace DP name with theirs for better sorting.	
                        // wrapper.managerName = wrapper.salesPersonName;	
                        wrapper.teamIterator = 1;	
                        
                        List<SalesTargetWrapper> execsToAdd = new List<SalesTargetWrapper>();	
                        for(SalesTargetWrapper secondWrapper: salesTargetWrapperMap.values()) {	
                            if(secondWrapper.salesRole.startsWithIgnoreCase('Sales Executive') && secondWrapper.managerName == wrapper.salesPersonName)	{	
                                //The below line empties manager name for Execs	
                                //Comment / Uncomment based on need / requirements	
                                secondWrapper.managerName = '0';	
                                execsToAdd.add(secondWrapper);	
                                //sortedValues.add(secondWrapper);	
                                wrapper.managerName = wrapper.salesPersonName;
                                wrapper.teamIterator++;	
                            }	
                        }	
                        sortedValues.add(wrapper);	
                        for(SalesTargetWrapper temp: execsToAdd) {	
                            sortedValues.add(temp);	
                        }	
                    }	
                }	
            }	*/
            
            // New logic
            Map < String, Integer > managerCountMap = new Map < String, Integer > ();
            for(SalesTargetWrapper wrapperObj: salesTargetWrapperMap.values())	{	
                if(wrapperObj.salesRole != null && !wrapperObj.salesRole.startsWithIgnoreCase('Dealer Principle')) {	
                	// wrapperObj.teamIterator = 1;
                    if(managerCountMap.containsKey(wrapperObj.managerName)) {
                        wrapperObj.displayManagerName = false;
                        Integer currentCount = managerCountMap.get(wrapperObj.managerName);
                        managerCountMap.put(wrapperObj.managerName, currentCount + 1);
                    } else {
                        wrapperObj.displayManagerName = true;
                        managerCountMap.put(wrapperObj.managerName, 1);
                    }
                    // wrapperObj.teamIterator = managerCountMap.get(wrapperObj.managerName);
                    wrapperList.add(wrapperObj);
                }
            }
            // Set teamIterator for all records
            for(SalesTargetWrapper wrapperObj: wrapperList)	{
                if(managerCountMap.containsKey(wrapperObj.managerName)) {
                    wrapperObj.teamIterator = managerCountMap.get(wrapperObj.managerName);
                }
            }
            wrapperList.sort();
        }	
        return wrapperList;
        // return sortedValues;	
        // return salesTargetWrapperMap.values();  	
    }
    
    @AuraEnabled
    public static String saveTargetRecords(String salesTargetWrapper){
        String successMessage = 'Success';
        try{
            List<SalesTargetWrapper> salesTargetWrapperList = (List<SalesTargetWrapper>)JSON.deserialize(salesTargetWrapper, List<SalesTargetWrapper>.class);
            //system.debug(salesTargetWrapperList);
            List<Sales_Target__c> upsertTargetList = new List<Sales_Target__c>();
            for(SalesTargetWrapper targetWrapper: salesTargetWrapperList){
                if(targetWrapper.salesTarget.Id != null || 						//1.0 - Added condition to avoId upsert of records with 0 Targets
                   (targetWrapper.salesTarget.January_Target__c != 0 || 		//Since - Targets with 0 records are not in system yet
                    targetWrapper.salesTarget.February_Target__c != 0 || 		//Without this condition, Targets with 0 records gets created multiple times, instead
                    targetWrapper.salesTarget.March_Target__c != 0 ||			//of upserting it because 'Id' is not available in the first place to upsert
                    targetWrapper.salesTarget.April_Target__c != 0 ||
                    targetWrapper.salesTarget.May_Target__c != 0 ||
                    targetWrapper.salesTarget.June_Target__c != 0 || 
                    targetWrapper.salesTarget.July_Target__c != 0 ||
                    targetWrapper.salesTarget.August_Target__c != 0 ||
                    targetWrapper.salesTarget.September_Target__c != 0 || 
                    targetWrapper.salesTarget.October_Target__c != 0 ||
                    targetWrapper.salesTarget.November_Target__c != 0 ||
                    targetWrapper.salesTarget.December_Target__c != 0 )){
                        upsertTargetList.add(targetWrapper.salesTarget);}
            }
            
            if(upsertTargetList.size()> 0) upsert upsertTargetList; 
        }catch(exception exp){
            successMessage = ''+exp.getMessage();
        }
        return successMessage;
    }
    
    
    public class SalesTargetWrapper implements Comparable {
        @AuraEnabled public String managerName;
        @AuraEnabled public String salesPersonName;
        @AuraEnabled public String salesRole;
        @AuraEnabled public Sales_Target__c salesTarget = new Sales_Target__c();
        @AuraEnabled public Integer salesTotal = 0;
        @AuraEnabled public Integer teamIterator = 0;
        @AuraEnabled public Boolean displayManagerName = false;
        
        public Integer compareTo(Object compareObj) {
            SalesTargetWrapper wrapper = (SalesTargetWrapper) compareObj;
            if (this.managerName == wrapper.managerName) return 0;
            if (this.managerName > wrapper.managerName) return 1;
            return -1;
        }
    }
    
}