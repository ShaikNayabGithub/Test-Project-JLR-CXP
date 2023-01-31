public without sharing class NewLeadController {
    
    
    @AuraEnabled
    public static List<Map<String,String>> getPicklistValues(String field){
        
        List<Map<String,String>> optionsList = new List<Map<String,String>>();
        
        Map<String,String> noneValue = new Map<String,String>();
        noneValue.put('label', '');
        noneValue.put('value', '');         
        optionsList.add(noneValue);
        
        Map<String,String> picklistValuesMap = SchemaUtility.getPickListValues('Lead', field);
        for(String picklistValue : picklistValuesMap.keySet()){
            Map<String,String> optionsmap= new Map<String,String>();
            optionsmap.put('label', picklistValue);
            optionsmap.put('value', picklistValuesMap.get(picklistValue));         
            
            optionsList.add(optionsmap);
            
        } 
        
        return optionsList;        
    }
    
    
    @AuraEnabled
    public static Map<Object,List<String>> getVehicleModelValuesByBrand(){
        
        return getDependentPicklistValues(Lead.Vehicle_Model_Offline__c) ;
    }
    
    /* @AuraEnabled
    public static Map<Object,List<String>> getPurchaseTypeValuesByType(){
        
        return getDependentPicklistValues(Lead.Purchase_Type__c) ;
    }
    
    @AuraEnabled
    public static Map<Object,List<String>> getSubTypeValuesByType(){
        
        return getDependentPicklistValues(Lead.Sub_Type__c) ;
    } */
    
    
    public static Map<Object,List<String>> getDependentPicklistValues( Schema.sObjectField dependToken )
    {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                    );
                
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                     ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>{''} );
                }
                dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
            }
            
            
        }
        dependentPicklistValues.put((object)'', new List<String>{''});
        return dependentPicklistValues;
    }
    
    
    @AuraEnabled
    public static LeadCreationWrapper saveLead(Lead newLead){
        Vehicle_Specification__c brand ;
        try{
            brand = [Select Id FROM Vehicle_Specification__c WHERE RecordType.developername='Make' AND Name = :newLead.Brand_Offline__c LIMIT 1];
        }catch(exception e){
            
        }
        Id leadProcessStreamlinedRTID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead Process - Streamlined').getRecordTypeId();
        newLead.RecordTypeId = leadProcessStreamlinedRTID;
        newLead.Status = 'New';
        newLead.LeadSource = 'Walk-in';
        //newLead.Country_ISO_Code__c = 'AE';
        newLead.Brand__c = brand != null ? brand.Id : null; 
        newLead.Mapping_Primary_Model_of_Interest__c = newLead.Vehicle_Model_Offline__c; 

        System.debug('#### newLead: ' + newLead);
        
        
        LeadCreationWrapper wrapper = new LeadCreationWrapper();
        try{
            insert newLead;   
                        
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(newLead.id);  
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
			lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            Lead convertedLead = [SELECT ID, ConvertedOpportunityID FROM LEAD WHERE ID =: newLead.Id];
            wrapper.lead = convertedLead;
        }
        catch(Exception e){
            wrapper.errorMessage = e.getMessage();
        }
        System.debug('### wrapper:' + wrapper);
        return wrapper;
        
    }
    
    public class LeadCreationWrapper{
        
        @AuraEnabled
        public Lead lead{get;set;}
        
        @AuraEnabled
        public String errorMessage{get;set;}
        
        public LeadCreationWrapper(){}
    }    
    
    
}