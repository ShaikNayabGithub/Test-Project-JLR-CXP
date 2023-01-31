/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 13/08/2019.
 */

global with sharing virtual class BaseResponseDto {

    @AuraEnabled
    public List<ErrorDto> Errors { get; set; }
    public Boolean AdditionalResultsAvailable {get; set;}

     public void addError(Exception ex){
        if (Errors == null) {
            Errors = new List<ErrorDto>();
        }
        Errors.add(new ErrorDto(ex));
    }

    public void addError(DateParsingException ex){
        if (Errors == null) {
            Errors = new List<ErrorDto>();
        }
        Errors.add(new ErrorDto(ex));
    }


    public void addError(ErrorDto error){
        if (Errors == null) {
            Errors = new List<ErrorDto>();
        }
        Errors.add(error);
    }

    public void addErrors( List<Database.Error> errorList){
    for(Database.Error error : errorList){
          this.addError(error);
    }
    }

    public void addError(Database.Error error){
        this.Errors.add(new ErrorDto(error));
    }

    @AuraEnabled
    public Boolean IsSuccess {
        get {
            if (Errors != null && Errors.size() > 0) {
                return false;
            }
            return true;
        }
    }

    @AuraEnabled
    public List<String> Info {get; set;}

    public void AddInfo(String str)
    {
        if (Info == null)
        {
            Info = new List<String>();
        }
        Info.add(str);
    }
}