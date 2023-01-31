/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/10/2019.
 */

global with sharing class VehicleOwnerResourceDto extends BaseResourceDto {

    private static final String RESOURCE_TYPE = 'VehicleOwner';
    global VehicleOwnerResourceDto(){
        init();
    }

    global VehicleOwnerResourceDto(Asset asset) {
        this();

        this.Id = asset.Id;
        this.Attributes.Name = asset.Name;
        this.Attributes.OwnerNameFirst = asset.Account.FirstName;
        this.Attributes.OwnerNameLast = asset.Account.LastName;
        this.Attributes.VehicleProductCode = asset.Derivative__r.ProductCode;
        //Todo more mapping
    }

    private void init(){
        this.Type = RESOURCE_TYPE;
        if (this.Attributes == null){
            this.Attributes = new VehicleOwnerAttributesDto();
        }
    }

    @AuraEnabled
    global VehicleOwnerAttributesDto Attributes {get; set;}
}