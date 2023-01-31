/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 13/08/2019.
 */

global with sharing virtual class BaseRequestDto
{
    global BaseRequestDto(){
        baseInit();
    }

   private void baseInit(){
        if (MaxResults == null){
            MaxResults = Constants.SOQL_DEFAULT_MAX_RESULTS;
        }
    }

    global Integer MaxResults {get; set;}

    global Integer Offset {get; set;}
}