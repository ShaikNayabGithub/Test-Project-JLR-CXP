/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/11/2019.
 */

global with sharing class RetailDeliveryResourceDto extends BaseResourceDto{

    global RetailDeliveryResourceDto(){
        super();
        init();
    }

    private void init(){
        if (this.Attributes == null){
            this.Attributes = new RetailDeliveryAttributeDto();
        }
        this.Type = Constants.RESOURCE_TYPE_RETAIL_DELIVERY_ADVICE;
    }

    global RetailDeliveryResourceDto(RetailDeliveryAttributeDto atts){
        this();
        this.Attributes = atts;
    }


    global RetailDeliveryAttributeDto Attributes { get; set; }
}