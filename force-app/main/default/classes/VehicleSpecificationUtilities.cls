public class VehicleSpecificationUtilities {
    public static Map<String, Vehicle_Specification__c> Brands { get {
        if(Brands == null) {
            SetBrandMap();
        }
        return Brands;
    } private set; }
    
    public static Map<String, RecordType> RecordTypes { get {
        if(RecordTypes == null) {
            RecordTypes = new Map<String, RecordType>();
            List<RecordType> recordTypeList = [Select DeveloperName From RecordType Where SObjectType = 'Vehicle_Specification__c' And IsActive = true];
            for(RecordType recordType : recordTypeList)
            {
                RecordTypes.put(recordType.DeveloperName, recordType);
            }
        }
        return RecordTypes;
    } private set; }

    public static void SetBrandMap()
    {
        Brands = new Map<String, Vehicle_Specification__c>();
        List<Vehicle_Specification__c> brandList = [Select Name From Vehicle_Specification__c Where RecordType.DeveloperName = 'Make'];
        for(Vehicle_Specification__c brand : brandList) {
            Brands.put(brand.Name.toLowerCase(), brand);
        }
    }
}