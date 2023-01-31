global class JLR_FileUploadServiceScheduler implements Schedulable 
{

    global void execute(SchedulableContext ctx)
    {  
        WebserviceCaller();        
    }
    
    public static void WebserviceCaller()
    {    
        webserviceCall();    
    }    
    
    @future(callout = true)
    public static void webserviceCall()
    {
       
            JLRFileUploadService.JLRFileUploadServiceSoap obj = new  JLRFileUploadService.JLRFileUploadServiceSoap();
            obj.Timeout_x = 120000;
            
            obj.UploadFilesToSF();
                
    }
}