public with sharing class DataModelController2{    
    
    // properties
    public List<fieldData> FieldmapList {get;set;}
    public Account acc {get;set;}
    // Constructor
    public DataModelController2(){
        acc = new Account();
        Set<String> fields = new Set<String>();        
        Map<String, Schema.DescribeFieldResult> finalMap =           
        getFieldMetaData(Account.getSObjectType().getDescribe(), fields);
        fieldmaplist = new List<fieldData>();
        for (String field :finalMap.keyset()) {  
          System.debug(finalMap.get(field).getName()); // field name
          System.debug(finalMap.get(field).getType()); // field type
          System.debug(finalMap.get(field).getLength()); // field length
          fieldmaplist.add(new fieldData(finalMap.get(field).getName(),string.valueof(finalMap.get(field).getType()),string.valueof(finalMap.get(field).getLength()),string.valueof(finalMap.get(field).getLabel()) ));
        }
 

    }
    public Map<String, Schema.DescribeFieldResult> getFieldMetaData(  
  Schema.DescribeSObjectResult dsor, Set<String> fields) {

  Map<String,Schema.DescribeFieldResult> finalMap = 
  new Map<String, Schema.DescribeFieldResult>();
  Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
  // iterate over the requested fields and get the describe info for each one. 
  // add it to a map with field name as key
  for(String field : objectFields.keyset()){
      Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
      finalMap.put(field, dr); 
  }
  return finalMap;
}
public pagereference getObjectData () {
    SObjectType objectType = Schema.getGlobalDescribe().get(acc.Name);
    Set<String> fields = new Set<String>();
    Map<String, Schema.DescribeFieldResult> finalMap =  
          getFieldMetaData(objectType.getDescribe(), fields);
          fieldmaplist = new List<fieldData>();
    for (String field :finalMap.keyset()) {  
        fieldmaplist.add(new fieldData(finalMap.get(field).getName(),string.valueof(finalMap.get(field).getType()),string.valueof(finalMap.get(field).getLength()),string.valueof(finalMap.get(field).getLabel()) ));
    }
    return null;
}

  public class FieldData {
    public string field{get;set;}
    public string type{get;set;}
    public string length{get;set;}
    public string label{get;set;}
    fieldData( string field,string type, string length,string label) {
       this.field = field;
       this.type = type;
       this.length = length;
       this.label = label;
    }
  }
}