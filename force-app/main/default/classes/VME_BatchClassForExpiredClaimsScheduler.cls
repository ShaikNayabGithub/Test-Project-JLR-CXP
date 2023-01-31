/******************************************************************************************
 *  Name        : VME_BatchClassForExpiredClaimsScheduler
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
global class VME_BatchClassForExpiredClaimsScheduler implements Schedulable {
    public static String sched = '0 15 00 * * ?';  
    global static String scheduleMe() {
        VME_BatchClassForExpiredClaimsScheduler SC = new VME_BatchClassForExpiredClaimsScheduler(); 
        return System.schedule('VME_BatchClassForExpiredClaims Job'+System.now(), sched, SC);
    }
    global void execute(SchedulableContext sc) {
        VME_BatchClassForExpiredClaims b = new VME_BatchClassForExpiredClaims();
        ID batchprocessid = Database.executeBatch(b,50); 
    }
}