/**
 * Created by Ethan Sargent on 5/11/19.
 */

public with sharing class PicklesAssignmentRequestDto extends BaseRequestDto {

    @AuraEnabled
    public List<String> assetIds {get; set; }

    @AuraEnabled
    public String dealerId {get; set;}

    public PicklesAssignmentRequestDto(){
        init();
    }

    private void init() {
        this.assetIds = new List<String>();
        this.dealerId = null;
    }

}