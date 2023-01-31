public class CSVUpload_SimpleFieldSetter {
    private final List<File_Upload_Field_Mapping__c> fieldMappings;
    private final String REPAIR_LOWER_CASE='repair';

    public CSVUpload_SimpleFieldSetter(List<File_Upload_Field_Mapping__c> fieldMappings)
    {
        this.fieldMappings = fieldMappings;
    }

    public void SetSimpleFields(SObject record, Integer rowIndex, CSVDataCollection dataCollection)
    {
        Map<String, Schema.SObjectField> fieldDescribeMap;
        
        if(record!=null)
            fieldDescribeMap=record.getSObjectType().getDescribe().fields.getMap();
                
        List<String> rowData = dataCollection.LinesByRowIndex.get(rowIndex);
        CSVRowStatus rowStatus = dataCollection.LineStatusesByRowIndex.get(rowIndex);
        String sObjectName;
        String finalAddress;     

        if(record!=null)
            sObjectName=record.getSObjectType().getDescribe().getName();
        
        for(File_Upload_Field_Mapping__c fieldMapping : fieldMappings) {
            if(String.isBlank(fieldMapping.Salesforce_Field_Name__c) || 
                    fieldMapping.SObject_Name__c != sObjectName) continue;

            Schema.DescribeFieldResult fieldDescription;
                    
            if(fieldDescribeMap!=null)        
                fieldDescription =fieldDescribeMap.get(fieldMapping.Salesforce_Field_Name__c).getDescribe();

            String fieldValueString = CSVDataCollectionUtilities.GetColumnValue(dataCollection, 
                    fieldMapping.Import_Node__c, rowData);
                    
            String isCorporate=  CSVDataCollectionUtilities.GetColumnValue(dataCollection, 
                    FinanceUpload_Constants.CORPORATE_COLUMN_HEADER, rowData);  
                                              
            if(String.isBlank(fieldValueString)) continue;
          
            try {
            
                object fieldValue = SObjectUtilities.CastFieldData(fieldValueString, fieldDescription);    
                
                if(fieldMapping.name=='Finance.Title.0'|| fieldMapping.name=='Finance.Title.1' )
                    {
                        String salutation=(String)fieldValue;
                        if(!String.isBlank(salutation))
                            fieldValue=CSVDataCollectionUtilities.getSalutationValue(salutation);
                    
                    }
                    
                if((isCorporate=='Company' || isCorporate=='TRUE' || isCorporate=='corporate' || isCorporate=='Yes') && fieldMapping.name!='Service.First Name.1' && fieldMapping.name!='Service.Last Name.1' && fieldMapping.name!='Service.Mobile Number' && fieldMapping.name!='Service.Email' && fieldMapping.name!='Finance.Last Name.1' && fieldMapping.name!='Finance.First Name.1' && fieldMapping.name!='Service.Title.1'  && fieldMapping.name!='Finance.Title.1' && fieldMapping.name!='Finance.Email' )
                   record.put(fieldMapping.Salesforce_Field_Name__c, fieldValue);  //if a record is a company, then the last name,first name,title and email are removed
                else
                if(isCorporate!='TRUE' && isCorporate!='Company' && isCorporate!='Corporate' && isCorporate!='Yes')
                    record.put(fieldMapping.Salesforce_Field_Name__c, fieldValue);   
                                  
                //merge address1 and address2     
                //remove the hardcoded value      
                if(fieldMapping.Import_Node__c=='Address1') 
                    finalAddress=String.valueOf(fieldValue);     
                else
                    if(fieldMapping.Import_Node__c=='Address2') 
                        finalAddress=finalAddress+'\r\n'+String.valueOf(fieldValue);
                        
            }
            
            catch (TypeException e) {
                if(rowStatus == null) {
                    rowStatus = new CSVRowStatus();
                    dataCollection.LineStatusesByRowIndex.put(rowIndex, rowStatus);
                }
                rowStatus.HasErrored = true;
                if(rowStatus.Message == null) rowStatus.Message = '';
                rowStatus.Message += String.format('Error on column {0}: {1};', new List<String> { 
                        fieldMapping.Import_Node__c, e.getMessage() });
            }
        }
        
        if(!String.isBlank(finalAddress))
            record.put('BillingStreet',finalAddress);       
    }
}