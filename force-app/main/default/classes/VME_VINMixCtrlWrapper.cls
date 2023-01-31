public  class VME_VINMixCtrlWrapper {
    
    @AuraEnabled public Asset assetObj {get ; set;}
    @AuraEnabled public Boolean isSelected {get ; set;}
    @AuraEnabled public String recordId {get; set;}

    public  VME_VINMixCtrlWrapper(){
        
    }

    public VME_VINMixCtrlWrapper(Asset assetObj, Boolean isSelected, String recordId){
        this.assetObj       = assetObj;
        this.isSelected     = isSelected;
        this.recordId       = recordId;
    }
}