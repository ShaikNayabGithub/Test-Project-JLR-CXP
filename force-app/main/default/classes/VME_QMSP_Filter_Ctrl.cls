/******************************************************************************************
 *  Name        : VME_QMSP_Filter_Ctrl
 *  
 *  Company     : ETMarlabs
 *    
 *  Purpose     : Used to create filters in the Tactical Adjstment
 * 
 *  Developer   : Tamanna Shukla
 *  Modified By : Tejashree J
 *  Modified Date: 23/04/2019
 ----------------------------------------------------------------------*/
public class VME_QMSP_Filter_Ctrl {
    
    @AuraEnabled
    public static Map<String,List<String>> get_VME_Region_Market_Map(){
        sObject cmp_Obj = Schema.getGlobalDescribe().get('User').newSObject() ;
        Map < String, List < String >> getRegion_Market_Map = VME_Utility_Class.getDependentPicklist(cmp_Obj, 'Market__c', 'Country_ISO_Code__c');
        System.debug(getRegion_Market_Map);
        return getRegion_Market_Map;
    }
    @AuraEnabled
    public static User get_User_Details(){
        // query current user information  
                User loggedUser = [SELECT Id,Name,Username,Market__c,FirstName,LastName,User_Status__c, Sales_Region__c, Country_ISO_Code__c FROM User WHERE Id =: UserInfo.getUserId() limit 1];
            
                return loggedUser;
    }
    @AuraEnabled
    public static Map<String,String> getQuarterPicklistValues(){
            return VME_Utility_Class.getAllPickListValue('Campaign','QMSP_Quarter__c');
    }
    @AuraEnabled
    public static Map<String,List<String>> getModelPicklistValues(){
          
            return VME_Utility_Class.getVMEBrandModelRealData();
    }
     @AuraEnabled public static Map<String, List<String>>getBrand_Model_Map() {
                return VME_Utility_Class.getVMEBrandModelRealData();
        }
}