global class SharePersonAccount_Scheduler implements Schedulable
{
     global void execute( SchedulableContext SC )
        {        
            //Instance creation to call all the batch classes
            shareAccountToRetailer sharingPersonAccountRecords = new shareAccountToRetailer();
            DataBase.executeBatch(sharingPersonAccountRecords);
            SharePersonAccount_Scheduler.start();
            System.abortJob( SC.getTriggerId() );
        }

        public static void start()
        {
            // start keepalive again in 5 mins
            Datetime sysTime = System.now().addSeconds( 120 );      
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'SharePersonAccount_Scheduler' + sysTime, chronExpression, new SharePersonAccount_Scheduler() );
        }
}