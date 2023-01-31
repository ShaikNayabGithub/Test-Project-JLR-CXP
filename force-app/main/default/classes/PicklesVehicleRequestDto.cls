/**
 * Created by Ethan Sargent on 30/10/19.
 */

public with sharing class PicklesVehicleRequestDto extends BaseResourceDto {

    @AuraEnabled
    public String Name {get; set;}

    @AuraEnabled
    public String VINString {get; set;}

    @AuraEnabled
    public String HandOverDateString {get; set;}

    @AuraEnabled
    public String MakeString {get; set;}

    @AuraEnabled
    public String ModelDetailString {get; set;}

    @AuraEnabled
    public String RegistrationNumberString {get; set;}

    @AuraEnabled
    public String CommonTypeOfSaleString {get; set;}

    public PicklesVehicleRequestDto(){
        init();
    }

    public PicklesVehicleRequestDto(
            String Id,
            String handOverDateString,
            String MakeString,
            String VINString,
            String ModelDetailString,
            String RegistrationString,
            String CommonTypeOfSaleString,
            String Name
    ) {
        this();
        init(Id, handOverDateString, MakeString, VINString, ModelDetailString, RegistrationString, CommonTypeOfSaleString, Name);
    }


    private void init(String Id, String handOverDateString, String MakeString,
            String VINString, String ModelDetailString, String RegistrationString, String CommonTypeOfSaleString, String Name){
        this.Id = Id;
        this.Name = Name;
        this.HandOverDateString = handOverDateString;
        this.MakeString = MakeString;
        this.VINString = VINString;
        this.ModelDetailString = ModelDetailString;
        this.RegistrationNumberString = RegistrationString;
        this.CommonTypeOfSaleString = CommonTypeOfSaleString;
    }

    private void init(){
        this.Id = 'Id';
        this.Name = 'Name';
        this.HandOverDateString = 'handOverDateString';
        this.MakeString = 'MakeString';
        this.VINString = 'VINString';
        this.ModelDetailString = 'ModelDetailString';
        this.RegistrationNumberString = 'RegistrationString';
        this.CommonTypeOfSaleString = 'CommonTypeOfSaleString';
    }

    public PicklesVehicleRequestDto(Asset asset) {
        String formattedDateString = ' - ';
        if (asset.Handover_Date__c != null) {
            Datetime tmp = Datetime.newInstance(asset.Handover_Date__c, Time.newInstance(0, 0, 0, 0));
            formattedDateString = tmp.format('dd/MM/yyyy');
        }


        this.Id = (String) asset.Id;
        this.HandOverDateString = formattedDateString;
        this.MakeString = asset.Brand__r.Name;
        this.VINString = asset.VIN__c;
        this.ModelDetailString = asset.Product2.Name;
        this.RegistrationNumberString = asset.Registration_Number__c;
        this.CommonTypeOfSaleString = asset.Common_Sale_Type__c;
        this.Name = asset.Name;
    }
}