public class SF_MetadataAPI {
	public virtual class MetadataPort {
        public String endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x = 120000;
        public SF_MetadataAPI.SessionHeader_element SessionHeader;
        public SF_MetadataAPI.CallOptions_element CallOptions;
        public SF_MetadataAPI.AllOrNoneHeader_element AllOrNoneHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
        private String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
        private String[] ns_map_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata', 'SF_MetadataAPI'};
        
        
		public virtual SF_MetadataAPI.UpsertResult[] upsertMetadata(SF_MetadataAPI.Metadata[] metadata) {
            SF_MetadataAPI.upsertMetadata_element request_x = new SF_MetadataAPI.upsertMetadata_element();
            request_x.metadata = metadata;
            SF_MetadataAPI.upsertMetadataResponse_element response_x;
            Map<String, SF_MetadataAPI.upsertMetadataResponse_element> response_map_x = new Map<String, SF_MetadataAPI.upsertMetadataResponse_element>();
            response_map_x.put('response_x', response_x);System.debug(String.valueOf(request_x));
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x + metadata[0].API_Version,
              '',
              'http://soap.sforce.com/2006/04/metadata',
              'upsertMetadata',
              'http://soap.sforce.com/2006/04/metadata',
              'upsertMetadataResponse',
              'SF_MetadataAPI.upsertMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');System.debug(String.valueOf(response_x));
            return response_x.result;
        }
	}
	
	public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId','<a href="http://www.w3.org/2001/XMLSchema','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
    }
    
    public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'client'};
    }
    
    public class AllOrNoneHeader_element {
        public Boolean allOrNone;
        private String[] allOrNone_type_info = new String[]{'allOrNone','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'allOrNone'};
    }
	
	public class upsertMetadataResponse_element {
        public SF_MetadataAPI.UpsertResult[] result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class UpsertResult {
        public Boolean created;
        public SF_MetadataAPI.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] created_type_info = new String[]{'created','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] errors_type_info = new String[]{'errors','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] success_type_info = new String[]{'success','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'created','errors','fullName','success'};
    }
    
    public class Error {
        public SF_MetadataAPI.ExtendedErrorDetails[] extendedErrorDetails;
        public String[] fields;
        public String message;
        public String statusCode;
        private String[] extendedErrorDetails_type_info = new String[]{'extendedErrorDetails','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] message_type_info = new String[]{'message','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'extendedErrorDetails','fields','message','statusCode'};
    }
    
    public class ExtendedErrorDetails {
        public String extendedErrorCode;
        private String[] extendedErrorCode_type_info = new String[]{'extendedErrorCode','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'extendedErrorCode'};
    }
    
    public class upsertMetadata_element {
        public SF_MetadataAPI.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    
    public virtual class Metadata {
        public String API_Version = '37.0';//default
    }
    
    public class GlobalPicklist extends Metadata{
        public String type = 'GlobalPicklist';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        public String description;
        public SF_MetadataAPI.GlobalPicklistValue[] globalPicklistValues;
        public String masterLabel;
        public Boolean sorted;
        private String[] description_type_info = new String[]{'description','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] globalPicklistValues_type_info = new String[]{'globalPicklistValues','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] masterLabel_type_info = new String[]{'masterLabel','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] sorted_type_info = new String[]{'sorted','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'description','globalPicklistValues','masterLabel','sorted'};
    }
    
    public class GlobalPicklistValue extends Metadata{
    	public String fullName;
        public Boolean default_x;
        public Boolean isActive;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] default_x_type_info = new String[]{'default','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'fullName', 'default_x', 'isActive'};
    }
    
    public class Translations extends Metadata{
        public String type = 'Translations';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        public SF_MetadataAPI.GlobalPicklistTranslation[] globalPicklists;
        private String[] globalPicklists_type_info = new String[]{'globalPicklists','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'globalPicklists'};
    }
    
    public class GlobalPicklistTranslation {
        public String name;
        public SF_MetadataAPI.PicklistValueTranslation[] picklistValues;
        private String[] name_type_info = new String[]{'name','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'name','picklistValues'};
    }
    
    public class PicklistValueTranslation {
        public String masterLabel;
        public String translation;
        private String[] masterLabel_type_info = new String[]{'masterLabel','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] translation_type_info = new String[]{'translation','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'masterLabel','translation'};
    }
    
    public class RecordType extends Metadata{
    	public String type = 'RecordType';
        public Boolean active;
        public String businessProcess;
        public String compactLayoutAssignment;
        public String description;
        public String label;
        public String fullName;
        public SF_MetadataAPI.RecordTypePicklistValue[] picklistValues;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] active_type_info = new String[]{'active','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] businessProcess_type_info = new String[]{'businessProcess','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] compactLayoutAssignment_type_info = new String[]{'compactLayoutAssignment','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] description_type_info = new String[]{'description','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] label_type_info = new String[]{'label','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'active','label', 'fullName', 'picklistValues'};
    }
     
    public class RecordTypePicklistValue {
        public String picklist;
        public SF_MetadataAPI.PicklistValue[] values;
        private String[] picklist_type_info = new String[]{'picklist','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] values_type_info = new String[]{'values','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'picklist','values'};
    } 
    
    public class PicklistValue {
    	public String type = 'PicklistValue';
    	public String fullName;
        public Boolean default_x;
        public String description;
        public Boolean isActive;
        private String[] default_x_type_info = new String[]{'default','http://soap.sforce.com/2006/04/metadata',null,'1','1','false'};
        private String[] description_type_info = new String[]{'description','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'fullName','default_x','description','isActive'};
        private String[] type_att_info = new String[]{'xsi:type'};
    }

    public class CustomField extends Metadata {
        public String type = 'CustomField';
        public String fullName;
        public String label;
        public String type_x;
        public ValueSet valueSet;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] label_type_info = new String[]{'label','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] valueSet_type_info = new String[]{'valueSet','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'fullName', 'label', 'type_x', 'valueSet'};
        private String[] type_att_info = new String[]{'xsi:type'};
    }

    public class ValueSet {
        public ValueSetValuesDefinition valueSetDefinition;
        private String[] valueSetDefinition_type_info = new String[]{'valueSetDefinition','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'valueSetDefinition'};
    }

    public class ValueSettings {

    }

    public class ValueSetValuesDefinition {
        public CustomValue[] value;
        private String[] value_type_info = new String[]{'value','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'value'};
    }

    public class CustomValue {
        public String fullName;
        public Boolean isActive;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] isActive_type_info = new String[]{'isActive','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'fullName','isActive'};
    }

    public class CustomObjectTranslation extends Metadata {
        public String type = 'CustomObjectTranslation';
        public String fullName;
        public CustomFieldTranslation[] fields;
        private String[] fullName_type_info = new String[]{'fullName','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] fields_type_info = new String[]{'fields','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'fullName','fields'};
        private String[] type_att_info = new String[]{'xsi:type'};
    }

    public class CustomFieldTranslation {
        public String name;
        public PicklistValueTranslation[] picklistValues;
        private String[] name_type_info = new String[]{'name','http://soap.sforce.com/2006/04/metadata',null,'0','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues','http://soap.sforce.com/2006/04/metadata',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/04/metadata','true','false'};
        private String[] field_order_type_info = new String[]{'name','picklistValues'};
    }
}