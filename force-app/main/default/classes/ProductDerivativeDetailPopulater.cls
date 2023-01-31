public class ProductDerivativeDetailPopulater {
   
    public static void PopulateDerivativeDetails(List<Product2> newProducts, Map<Id, Product2> oldProductMap) {
        List<Product2> derivatives = new List<Product2>();
        List<Product2> models = new List<Product2>();
        for(Product2 prod : newProducts){
			//when a Product (Derivative) is created, or the Name is updated, populate the fields that derive from the Name (DPCK Code, Brochure Code, Model Alternative)
            if(prod.RecordTypeId == Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId()){
                if(oldProductMap == null || oldProductMap.containsKey(prod.Id) == false){
                    derivatives.add(prod);
                }
                else{
                    if(oldProductMap.get(prod.Id).Name != prod.Name || oldProductMap.get(prod.Id).IsActive == false && prod.IsActive == true){
                        derivatives.add(prod);
                    }
                }
            }
            //when a Product (Model) is created, or the Product Code is updated, populate the Model Vehicle Spec derived from the Product Code
            if(prod.RecordTypeId == Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId()){
                if(oldProductMap == null || oldProductMap.containsKey(prod.Id) == false){
                	models.add(prod);
                }
 	           else{
    	            if(oldProductMap.get(prod.Id).ProductCode != prod.ProductCode){
        	            models.add(prod);
            	    }
               }
            }
        }
        if(derivatives.size() > 0){
            DeriveDerivativeDetails(derivatives);
        }
        if(models.size() > 0){
            DeriveModelDetails(models);
        }
    }
    
    public static void PopulateDerivativeDetails(List<Product2> newProducts) {
        PopulateDerivativeDetails(newProducts, null);
    }
        
    private static void DeriveDerivativeDetails(List<Product2> derivatives) {
        List<Product_Code_Translations__mdt> prodTranslations = [SELECT MasterLabel, Group__c, Make__c, Feature_Word__c, Feature_Description__c FROM Product_Code_Translations__mdt];
        Map<Id, String> vsMap = new Map<Id, String>();
        for(Vehicle_Specification__c vs : [SELECT Id, Name FROM Vehicle_Specification__c WHERE RecordTypeId = :Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId()]){
            vsMap.put(vs.Id, vs.Name);
        }
        for(Product2 prod : derivatives){
            if(prod != null && prod.Name != null){
                if(prod.Name.contains(' ')){
                    if(prod.Name.length() > prod.Name.lastIndexOf(' ')){
	            		//Model Year is the final number at the end of the Product Name
	            		String modelYear = prod.Name.substring(prod.Name.lastIndexOf(' ')+1);
	            		if(modelYear.indexOf('/') >= 0){
			                modelYear = modelYear.substring(0, modelYear.indexOf('/'));
		            	}
		            	prod.Model_Year__c = modelYear;
                    }
        	    	//DPCK Code is the substring after the final '/' in the Product Name
	            	String nameMinusModelYear = prod.Name.substring(0, prod.Name.lastIndexOf(' '));
                    if(nameMinusModelYear.contains('/')){
                        if(nameMinusModelYear.contains(',') && nameMinusModelYear.lastIndexOf(',') > nameMinusModelYear.lastIndexOf('/')){
	            			prod.DPCK_Code__c = nameMinusModelYear.substring(nameMinusModelYear.lastIndexOf('/')+1, nameMinusModelYear.lastIndexOf(','));
                    	}
            			//Brochure Model Code is the substring before the final '/' in the Product Name
            			String strippedName = nameMinusModelYear.substring(0, nameMinusModelYear.lastIndexOf('/'));
                        if(strippedName.contains(' ') && strippedName.length() > strippedName.lastIndexOf(' ')){
            				prod.Brochure_Model_Code__c = strippedName.substring(strippedName.lastIndexOf(' ')+1);
                        }
                    }
                }
	            //Specification Pack Alternative is the corresponding DPCK value from Product Code Translations metadata table
    	        //Model Year Alternative is the corresponding Model_Year value from Product Code Translations metadata table
        	    for(Product_Code_Translations__mdt pct : prodTranslations){
           	    	if(pct.Group__c == 'Model_Year' && pct.Feature_Word__c == prod.Model_Year__c){
                	    prod.Model_Year_Alternative_CXP__c = pct.Feature_Description__c;
                    }
                	if(String.IsBlank(prod.Specification_Pack_Alternative__c)){
	                   	if(pct.Group__c == 'DPCK' && pct.MasterLabel == prod.DPCK_Code__c){
	                        if(vsMap.containsKey(prod.Make__c) && vsMap.get(prod.Make__c) == pct.Make__c){
	                            prod.Specification_Pack_Alternative__c = pct.Feature_Description__c;
    	                    }
	                    }
    	            }
                }
            }
        }
    }
    
    private static void DeriveModelDetails(List<Product2> models) {
        List<Vehicle_Specification__c> vsList = [SELECT Id, Product_Code__c FROM Vehicle_Specification__c WHERE RecordTypeId = :Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId()];
        for(Product2 prod : models){
            prod.Model_Vehicle_Spec__c = null;
            if(!String.IsBlank(prod.ProductCode)){
                //look up Vehicle Spec Id from vsList (Product Code is comma-separated list on Vehicle Spec)
                for(Vehicle_Specification__c vs : vsList){
                    if(!String.IsBlank(vs.Product_Code__c)){
                        for(String str : vs.Product_Code__c.split(',')){
                            if(str == prod.ProductCode){
                                prod.Model_Vehicle_Spec__c = vs.Id;
                            }
                        }
                    }
                }
            }
        }
    }

}