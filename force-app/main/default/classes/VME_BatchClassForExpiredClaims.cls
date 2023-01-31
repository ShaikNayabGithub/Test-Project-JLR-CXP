/******************************************************************************************
*  Name        : VME_BatchClassForExpiredClaims
*  
*  Company     : Marlabs 
*    
*  Purpose     : The batch class is used to update the status of claims as expired which is still in generated status but the last date of submission has crossed and is scheduled at 12:15am every day.
* 
*  Developer   : Tejashree J
*
*  Created Date: 07/08/2019 
*
*  Modified : 
----------------------------------------------------------------------
*/
global class VME_BatchClassForExpiredClaims implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {    
        String query = 'SELECT Id,Name,VME_Status__c FROM VME_Claims__c WHERE VME_Last_Date_of_Submissiom__c=YESTERDAY AND VME_Status__c=\'Generated\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<VME_Claims__c> scope) {
        
        for(VME_Claims__c eachClaim : scope)
        {        
            // Update the Claim Status 
            eachClaim.VME_Status__c = 'Expired' ;
            System.debug('Claim::'+eachClaim);
        }
        System.debug('Updated');
        // Update the Claim Record
        update scope;
    }  
    
    global void finish(Database.BatchableContext BC) {
    }
}