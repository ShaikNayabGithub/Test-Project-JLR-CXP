public  class VME_DealerMixCtrlWrapper {

    @AuraEnabled public Account accountObj {get ; set;}
    @AuraEnabled public Boolean isSelected {get ; set;}
    @AuraEnabled public String recordId {get; set;}

    public  VME_DealerMixCtrlWrapper(){

    }

    
    public VME_DealerMixCtrlWrapper(Account accountObj, Boolean isSelected, String recordId) {  
        this.accountObj     = accountObj;
        this.isSelected     = isSelected;
        this.recordId       = recordId;
    }
}