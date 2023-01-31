/**
 * Created by Nick on 16/10/2019.
 */

public with sharing class PicklesOuvResourceDto extends BaseResourceDto {

    public PicklesOuvResourceDto() {
        super();
        init();
    }

    private void init() {
        this.Type = 'PicklesOuv';
        if (this.Attributes == null) {
            this.Attributes = new PicklesOuvAttributesDto();
        }
    }

    public PicklesOuvResourceDto(Role__c role) {
        this();
        this.Id = role.Vehicle__r.Id;
        this.Attributes.Vin = role.Vehicle__r.VIN__c;

        if (role.Vehicle__r.Brand__r.Name == Constants.MAKE_NAME_JAGUAR)
        {
            this.Attributes.DealerCode = role.Account__r.Dealer_CI_Code__c.substring(1);
        }
        else if (role.Vehicle__r.Brand__r.Name == Constants.MAKE_NAME_LAND_ROVER)
        {
            this.Attributes.DealerCode = role.Account__r.Dealer_CI_Code_2__c.substring(1);
        }
    }

    public PicklesOuvAttributesDto Attributes { get; set; }
}