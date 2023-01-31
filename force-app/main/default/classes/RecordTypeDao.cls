public with sharing class RecordTypeDao {
	private static RecordTypeDao instance;
    // key:sObjectType + _ + DeveloperName
    private Map<String, RecordType > recordTypeMap;
    
    // sObjectType
    public static final String sObjectType_Lead = 'Lead';
    public static final String sObjectType_Account = 'Account';
    public static final String sObjectType_Product = 'Product2';
    public static final String sObjectType_Asset = 'Asset';
    public static final String sObjectType_VehicleSpecification = 'Vehicle_Specification__c';
    
    // Recordtype DeveloperName
    public static final String lead_Udaan = 'UDAAN';
    public static final String account_Individual = 'Individual';
    public static final String account_Retailer = 'Retailer';
    public static final String product_Model = 'Model';
    public static final String asset_Vehicle = 'Vehicle';
    public static final String vehicleSpecification_Make = 'Make';
    public static final String product_Derivative = 'Derivative';
    
    private RecordTypeDao(){
        this.recordTypeMap = new Map<String, RecordType>();
		List<RecordType> recordTypeList = [Select id, Name, DeveloperName, sObjectType From RecordType ];
        for(RecordType r : recordTypeList){
            this.recordTypeMap.put(r.sObjectType + '_' + r.DeveloperName, r);
        }
	}
    
    public static RecordTypeDao getInstance(){
        if(instance == null){
            instance = new RecordTypeDao();
        }
        return instance;
    }
    
    public Id getRecordTypeId(String sObjectType , String developerName){
        String key = sObjectType + '_' + developerName;
        if(this.recordTypeMap.containsKey(key)){
            return this.recordTypeMap.get(key).Id;
        }
        return null;
    }
}