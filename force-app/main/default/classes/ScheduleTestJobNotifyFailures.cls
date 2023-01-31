//If you need to reschedule this class use anonymous apex: 
// System.schedule('ScheduleTestJobNotifyFailures','0 0 8,10,12,14,16,18,20 ? * MON-FRI',new ScheduleTestJobNotifyFailures());
global class ScheduleTestJobNotifyFailures implements Schedulable 
{ 
    
    global void execute(SchedulableContext SC) {
        doExecute();
    }

    @future (callout=true)
    public static void doExecute(){
        notifyFailures();
    }
    
    public static void notifyFailures() {
     
        String sTwoHoursAgo = String.ValueOf(system.now().addHours(-2)).replace(' ','T')+'.000z';
        List<String> recipients = Label.TEST_FAILURE_NOTIFICATION_EMAILS.split(',');
    
        List<ApexTestResult> results = Database.query('SELECT Outcome, ApexClass.Name, MethodName, Message, StackTrace,TestTimeStamp FROM ApexTestResult where testtimestamp >= '+sTwoHoursAgo+' and outcome != \'Pass\' order by ApexClass.Name asc');
        String msg = '<!DOCTYPE html><html>';
        msg += '<head><style>';
        msg += '#notif { font-family: "Trebuchet MS", Arial, Helvetica, sans-serif; border-collapse: collapse; width: 100%; } ';
        msg += '#notif td, #notif th { border: 1px solid #ddd; padding: 8px; } ';
        msg += '#notif tr:nth-child(even){background-color: #f2f2f2; } ';
        msg += '#notif tr:hover {background-color: #ddd;} ';
        msg += '#notif th { padding-top: 12px; padding-bottom: 12px; text-align: left; background-color: #4CAF50; color: white;} ';
        msg += '</style></head>';
        msg += '<body><h1>Unit test failures detected on Org ID: '+UserInfo.getOrganizationId()+'</h1>';
        msg += '<pre>Running user: '+UserInfo.getUserName()+'\n';
        msg += 'Recipient list stored in custom label: TEST_FAILURE_NOTIFICATION_EMAILS\n';
        msg += 'Scheduled job sending this email notification: ScheduleNotifyTestFailures()</pre><hr/>';
        msg += '<table id=\'notif\'><tr><td><b>Outcome</b></td><td><b>Test Name</b></td><td><b>Method</b></td><td><b>Message</b></td><td><b>Stack Trace</b></td><td><b>Time Stamp</b></td></tr>';
        for (ApexTestResult r : results) {
            msg += '<tr>';
            msg += '<td>'+r.Outcome+'</td>';
            msg += '<td>'+r.ApexClass.Name+'</td>';
            msg += '<td>'+r.MethodName+'</td>';
            msg += '<td>'+r.Message+'</td>';
            msg += '<td>'+r.StackTrace+'</td>';
            msg += '<td>'+r.TestTimeStamp+'</td>';
            msg += '</tr>';
        }
        msg += '</table></body></html>';
        
        if (!results.isEmpty()) EmailUtility.SendEmail(recipients, 'TestFailureNotificationDaemon', 'WARNING! Test Failure Notification', msg, null, 'noreply@jaguarexperience.com', false, null, true);
    
    }
    
}