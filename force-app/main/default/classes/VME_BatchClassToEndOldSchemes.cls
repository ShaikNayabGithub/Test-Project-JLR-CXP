/******************************************************************************************
 *  Name        : VME_BatchClassToEndOldSchemes
 *  
 *  Company     : ETMarlabs 
 *    
 *  Purpose     : The batch class is used to end Old schemes and is scheduled at 12:05am every day.
 * 
 *  Developer   : Tejashree J
 *
 *  Created Date: 01/05/2019 
 *
 *  Modified : 09/07/2019 BY Tejashree J
 ----------------------------------------------------------------------
*/
global class VME_BatchClassToEndOldSchemes implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC) {    
		Date yesterday= Date.today().addDays(-1);
        String query = 'SELECT Id,Name,VME_InActive__c,VME_Available_for_Claims__c,VME_Consumed_Volume__c,VME_Volume__c,VME_End_Date__c,VME_Revise_Check__c FROM VME_Schemes__c where VME_End_Date__c=:yesterday';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<VME_Schemes__c> scope) {
        
        for(VME_Schemes__c schm : scope)
        {        
            // Update the Scheme fields 
            schm.VME_InActive__c = true ;
            schm.VME_Revise_Check__c = true;
            schm.VME_Available_for_Claims__c = true;
            schm.VME_Volume__c = schm.VME_Consumed_Volume__c;
            System.debug('Scheme::'+schm);
        }
        try {
        	System.debug('Updated');
            // Update the Scheme Record
            update scope;
         
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
         
    }  
     
    global void finish(Database.BatchableContext BC) {
  }
}