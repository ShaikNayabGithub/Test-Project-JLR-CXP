/**
 * Created by Ethan Sargent on 6/11/19.
 */

public with sharing class PicklesDealerDetailsDto extends BaseResourceDto {

    @AuraEnabled
    public String Name {get; set;}

}