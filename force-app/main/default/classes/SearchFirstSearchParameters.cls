public class SearchFirstSearchParameters {
    public String FirstName { get; set {
        FirstName = String.escapeSingleQuotes(value);
    } }
    public String LastName { get; set {
        LastName = String.escapeSingleQuotes(value);
    } }
    public String CompanyName { get; set {
        CompanyName = String.escapeSingleQuotes(value);
    } }
    public String Phone { get; set {
        Phone = String.escapeSingleQuotes(value);
    } }
    public String Email { get; set {
        Email = String.escapeSingleQuotes(value);
    } }
    public String AssetIdentifier { get; set {
        AssetIdentifier = String.escapeSingleQuotes(value);
    } }
    public String RecordTypeId { get; set {
    	List<RecordType> recordTypes = [Select SObjectType From RecordType Where Id=:value];
    	if(recordTypes.Size() != 0) {
    		RecordTypeObject = recordTypes[0].SObjectType;
            RecordTypeId = recordTypes[0].Id;
    	} 	
    } }//do not clear
    
    public String RecordTypeObject { get; private set; }
    
    public Boolean IsEmpty { get {
        return (String.IsEmpty(FirstName) && String.IsEmpty(LastName) && String.IsEmpty(CompanyName) && String.IsEmpty(Phone) && String.IsEmpty(Email) && String.IsEmpty(AssetIdentifier));
    }}
    
    
    public void Clear()
    {
        this.FirstName = '';
        this.LastName = '';
        this.CompanyName = '';
        this.Phone = '';
        this.Email = '';
        this.AssetIdentifier = '';
    }
}