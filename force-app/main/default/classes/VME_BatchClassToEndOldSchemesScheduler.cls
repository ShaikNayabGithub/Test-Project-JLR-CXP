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
global class VME_BatchClassToEndOldSchemesScheduler implements Schedulable {
    public static String sched = '0 05 00 * * ?';  
    global static String scheduleMe() {
        VME_BatchClassToEndOldSchemesScheduler SC = new VME_BatchClassToEndOldSchemesScheduler(); 
        return System.schedule('VME_BatchClassToEndOldSchemes Job', sched, SC);
    }
    global void execute(SchedulableContext sc) {
        VME_BatchClassToEndOldSchemes b = new VME_BatchClassToEndOldSchemes();
        ID batchprocessid = Database.executeBatch(b,50); 
    }
}