public  class VME_NewVMECampaignCtrl {
    @AuraEnabled
    public static List<RecordTypeWrapper> getAllRecordTypesOfVME(){
        List<RecordTypeWrapper> recordTypeList = new List<RecordTypeWrapper>();
        Map<string,Schema.RecordTypeInfo> recortypeValues= Schema.SObjectType.VME_Campaign__c.getRecordTypeInfosByName();
		for(string rt:recortypeValues.keyset()){
    		Schema.RecordTypeInfo rtpeInfo=recortypeValues.get(rt);
      		if(rtpeInfo.isActive() && rtpeInfo.isAvailable() && !(rtpeInfo.isMaster())){
      			RecordTypeWrapper wrap = new RecordTypeWrapper();
      			wrap.name =rtpeInfo.getName();
      			wrap.typeId =rtpeInfo.getRecordTypeId();
      			wrap.defaultValue =rtpeInfo.isDefaultRecordTypeMapping();
      	 		recordTypeList.add(wrap);
            }
}
    
        return  recordTypeList;
    }
  
      @AuraEnabled
    public static Map<String,String> getCat_SubCat(){
  return   VME_Utility_Class.getCatSubCatCodeMappingForL2();

    }
     @AuraEnabled
    public static Map<String,String> getMarketCode(){
  return   VME_Utility_Class.getMarketCode();

    }

      @AuraEnabled
    public static Map<String,String> getBrandCode(){
  return   VME_Utility_Class.getBrandCode();

    }
     
      @AuraEnabled
    public static User getUserDetails(){
        // query current user information  
                User loggedUser = [SELECT Id,Name,Username,Market__c,FirstName,LastName,User_Status__c, Sales_Region__c, Country_ISO_Code__c FROM User WHERE Id =: UserInfo.getUserId() limit 1];
                return loggedUser;
    }
    public class RecordTypeWrapper{
        @AuraEnabled
        public  String name;
        @AuraEnabled
        public Id typeId;
        @AuraEnabled
        public Boolean defaultValue;
    }
}