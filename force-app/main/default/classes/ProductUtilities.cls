public class ProductUtilities {
	public static final String RecordTypeIdFieldName = Product2.RecordTypeId.getDescribe().getName();
	public static final String ProductCodeFieldName = Product2.ProductCode.getDescribe().getName();
    public static final String BodyStyleFieldName = Product2.Body_Style__c.getDescribe().getName();
    public static final String EngineFieldName = Product2.Engine__c.getDescribe().getName();
    public static final String WheelBaseFieldName = Product2.Wheel_Base__c.getDescribe().getName();
    public static final String TransmissionFieldName = Product2.Transmission__c.getDescribe().getName();
    public static final String WheelDrivenFieldName = Product2.Wheel_Driven__c.getDescribe().getName();
    
    public static Map<String, RecordType> RecordTypes { get {
        if(RecordTypes == null) {
            RecordTypes = new Map<String, RecordType>();
            List<RecordType> recordTypeList = [Select DeveloperName, Name, SobjectType From RecordType Where SObjectType = 'Product2' And IsActive = true];
            for(RecordType recordType : recordTypeList)
            {
                RecordTypes.put(recordType.DeveloperName, recordType);
            }
        }
        return RecordTypes;
    } private set; }
    
    public static Map<String, Product2> ModelsByCode { get {//assumes number of models will remain small
    	if(ModelsByCode == null) {
            SetModelMap();
        }
        return ModelsByCode;
    } private set; }
    
    
    public static void SetModelMap()
    {
    	ModelsByCode = new Map<String, Product2>();
        List<Product2> models = [Select ProductCode From Product2 Where RecordTypeId=:ProductUtilities.RecordTypes.get('Model').Id];
    	for(Product2 model : models) {
    		ModelsByCode.put(model.ProductCode, model);
    	}
    }
}