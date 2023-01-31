/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 13/08/2019.
 */

global with sharing class ErrorDto {

    @AuraEnabled
    global String Id {get; set;}

    @AuraEnabled
    global String ErrorCode {get; set;}

    @AuraEnabled
    global String ErrorMessage {get; set;}
    @AuraEnabled
    global String AboutLink {get; set;}
    @AuraEnabled
    global String Status {get; set;}
    @AuraEnabled
    global String Code {get; set;}
    @AuraEnabled
    global String Title {get; set;}
    @AuraEnabled
    global String Detail {get; set;}

    global String SourcePointer {get; set;}

    global String SourceParameter {get; set;}

    global Map<String, Object> Meta {get; set;}

    global ErrorDto(){

    }

    global ErrorDto(Exception ex){
        this.Id = String.valueOf(ex.getLineNumber());
        this.Code = ex.getTypeName();
        this.Detail = ex.getMessage();
        this.ErrorMessage = ex.getStackTraceString();
    }

    global ErrorDto(Database.Error error){
        this.Detail = error.message;
        this.ErrorMessage = error.message;
    }

    global ErrorDto(String summary, List<Database.Error> errors){
        this.Title = summary;
        for (Database.error error : errors){

            //ErrorCode
            if (String.isNotBlank(this.ErrorCode)){
                this.ErrorCode += ' | ';
            }
            this.ErrorCode += error.getStatusCode();

            //ErrorMessage
            if (String.isNotBlank(this.ErrorMessage)){
                this.ErrorMessage += ' | ';
            }
            this.ErrorMessage += error.getMessage() ;

            //Detail
            if(String.isNotBlank(this.Detail)){
                this.Detail += ' | ';
            }
            this.Detail += JSON.serialize(error.getFields());
        }
    }

    global ErrorDto( DateParsingException ex){
        System.debug('>> ErrorDto(ex: ' + JSON.serialize(ex) + ')');
        this.Title = 'Could not parse a date: ' + ex.DateString;
        if (ex != null){
            this.ErrorMessage = ex.getMessage();
            this.ErrorCode = ex.getTypeName();
            this.Detail = ex.getStackTraceString();
        }

    }
}