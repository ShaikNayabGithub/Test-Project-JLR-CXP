/*

Author : Deepti Tanguturi
Purpose : Getting scheme and VME Campaign data based on Claim
Created Date : 30-04-2019
Modified By :
Modified Name:
Reason : 
*/
public class VME_ShowClaimScheme_Ctrl {
        @AuraEnabled
        public static user fetchUser() {
                User loggedUser = VME_Utility_Class.fetchUser();
                return loggedUser;
        }
        @AuraEnabled
        public static String get_User_Currency() {
                return UserInfo.getDefaultCurrency();
        }
        @AuraEnabled
        public static SchemeCampaignWrapper getClaimSchemeData(String claimId) {
                SchemeCampaignWrapper wrapperObj;
                VME_Claims__c claim = [SELECT Id, VME_Related_Scheme__c FROM VME_Claims__c where id = : claimId];
                VME_Schemes__c scheme = [SELECT Id, Name, VME_Start_Date__c, VME_Type__c, VME_End_Date__c, VME_Campaign__c, VME_JLR_Share__c, convertCurrency(VME_PU_Amount__c), VME_Retailer__c, VME_Claims_Available__c, VME_Claims_Approved__c, VME_Total_Amount_Approved__c, VME_Total_Amount_Available__c, VME_InActive__c, VME_Scheme_Type__c, VME_Volume__c, VME_Retailer_Contribution__c, VME_Level_3_Description__c FROM VME_Schemes__c where Id = : +claim.VME_Related_Scheme__c];
                VME_Campaign__c vmeCampaign = [SELECT Id, VME_External_ID__c, Name, QMSP_Campaign__c, VME_Category__c, VME_Sub_Category__c, VME_Start_Date__c, VME_End_Date__c, VME_Brand__c, VME_Model__c, convertCurrency(VME_Planned_PU_Amount__c), VME_Approved_Volume__c, VME_Planned_Volume__c, convertCurrency(VME_Planned_Budget__c), CurrencyIsoCode, RecordTypeId, VME_Fiscal_Year__c, VME_Quarter__c, VME_Market_Code__c, VME_Country__c FROM VME_Campaign__c where Id = : +scheme.VME_Campaign__c];
               
            wrapperObj = new SchemeCampaignWrapper();
                wrapperObj.schemeObj = scheme;
                wrapperObj.campaignObj = vmeCampaign;
                return wrapperObj;
        }
        public class SchemeCampaignWrapper {
                @AuraEnabled
                public VME_Schemes__c schemeObj;
                @AuraEnabled
                public VME_Campaign__c campaignObj;
        }
}