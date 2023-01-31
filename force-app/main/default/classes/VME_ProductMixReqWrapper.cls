public class VME_ProductMixReqWrapper {

    @AuraEnabled public Product2 productObj {get; set;}
    @AuraEnabled public Boolean isSelected {get; set;}
    @AuraEnabled public String recordId {get; set;}


    public VME_ProductMixReqWrapper() {
    }


    public VME_ProductMixReqWrapper(Product2 productObj, Boolean isSelected, String recordId) {
        this.productObj     = productObj;
        this.isSelected     = isSelected;
        this.recordId       = recordId;
    }
}