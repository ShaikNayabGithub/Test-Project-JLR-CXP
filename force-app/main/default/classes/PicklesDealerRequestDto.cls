/**
 * Created by Ethan Sargent on 6/11/19.
 */

public with sharing class PicklesDealerRequestDto extends BaseRequestDto {

    @AuraEnabled
    public String dealerSearchKey {get; set;}


}