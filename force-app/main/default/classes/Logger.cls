/**
 * Created by lbrindle on 31/07/2018.
 */

public class Logger {

    private static List<Log> Logs = new List<Log>();

    public static void Info(String message){
        Log l = new Log();
        l.level = 'Info';
        l.message = message;
        l.timestamp = datetime.now();
        Logs.add(l);
    }

    public static List<Log> getLogs(){
        return Logs.clone();
    }


    public  class Log
    {
        public String level{get;set;}
        public String message{get;set;}
        public DateTime timestamp {get;set;}
        public Exception exceptionObj {get;set;}
    }
}