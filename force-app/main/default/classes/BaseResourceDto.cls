global with sharing virtual class BaseResourceDto {

    @AuraEnabled
    global String Id {get; set;}

    @AuraEnabled
    global String Type {get; set;}

}