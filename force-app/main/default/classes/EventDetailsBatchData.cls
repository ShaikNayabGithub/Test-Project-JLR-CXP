public class EventDetailsBatchData {
    
    public String eventDetailsRetrieveData(){
        
        String query;
        Date lastCreatedDate = System.today().addDays(-7);
        Datetime lastCreatedDateTime = Datetime.newInstance(lastCreatedDate.year(),lastCreatedDate.month(),lastCreatedDate.day());
        String lastCreatedDateString = lastCreatedDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        
        query = 'SELECT ';
        //Event Details FIELDS
        query += 'Brand__C,Incident_Country_Code__c,Event_Type__c,Event_DateTime__c,';
        query += 'Title__c,First_Name__c,Last_Name__c,Country__c,Phone__c,Model__c,Licence_Plate__c,Email__c,';
        query += 'Language_Code__c,Survey_Suppression_Flag__c,Roadside_Event_ID__c,Source__c,Vin__c,';
        
        //AssetFIELDS
        query += 'VIN__r.Last_Registration_Date__c,VIN__r.Handover_Date__c,VIN__r.Delivered_Date__c,VIN__r.Dealer_Code__c,VIN__r.AccountID,';
        query += 'VIN__r.Model_Year__c,VIN__r.Name';
        
        //FILTERS
        query += ' FROM Event_Details__c';    
        query += ' WHERE';    
        query += ' Consumer_Reference__c = \'Total Care\' AND CreatedDate > ' + lastCreatedDateString + '';
        
        System.debug('-- query : ' + query);
        
        List<GFK_Roadside_Event_Export__c > allRows = [SELECT Id FROM GFK_Roadside_Event_Export__c WHERE Data_Source__c = 'Total Care'];
        delete allRows;
        
        return query;
    }
    
    public List<GfK_Roadside_Event_Export__c> getEventList(List<Event_Details__c> EventDetailsList){
       
        Set<Id> assetId = new Set<Id>();
        Map<Id,Asset> assetMap;
        For(Event_Details__c eds : EventDetailsList){
            if(eds.Vin__c != null){
                assetId.add(eds.Vin__c);
            }
        }
        if(!assetId.isEmpty()){
            //calling again as related records don't get passed through object lists
            assetMap = new Map<id,Asset>([Select Id,Last_Registration_Date__c,Handover_Date__c,Delivered_Date__c,Dealer_Code__c,AccountID, Model_Year__c,Name from asset where Id in:assetId]);
        }
        
        
        List<GfK_Roadside_Event_Export__c> listOfRoadsideEvents = new List<GfK_Roadside_Event_Export__c>();
        
        for(Event_Details__c ed : EventDetailsList){
            
            Asset relatedAsset = null;
            if(ed.VIN__c != null && assetMap!=  null && assetMap.get(ed.vin__c) != null){
                relatedAsset = assetMap.get(ed.vin__c);
            }
            
            GfK_Roadside_Event_Export__c newEvent = new GfK_Roadside_Event_Export__c(
                Manufacturer__c = ed.Brand__c,
                Country_Code__c = ed.Incident_Country_Code__c,
                Event_Type__c = '4',
                Title__c = ed.Title__c,
                Firstname__c = ed.First_Name__c,
                Surname_Field_1__c = ed.Last_Name__c,
                Address_8_Country__c = ed.Country__c,
                Mobile_Telephone_Number__c = ed.Phone__c,
                Model_Name__c = ed.Model__c,
                Registration_Number__c = ed.Licence_Plate__c,
                Email_Address_1__c = ed.Email__c,
                Preferred_Language__c = ed.Language_Code__c,
                Breakdown_Country__c = ed.Incident_Country_Code__c,
                Breakdown_Case_Id__c = ed.Roadside_Event_ID__c,
                Data_Source__c = 'Total Care',
                Roadside_Assistance_Provider__c = 'Roadside Assistance'
                
            );
            if(relatedAsset != null && relatedAsset.Dealer_Code__c != null ){
                newEvent.Dealer_Code__c = relatedAsset.Dealer_Code__c;  
            }
            if(relatedAsset != null && relatedAsset.Accountid != null ){
                newEvent.Customer_Unique_Id__c = relatedAsset.Accountid;  
            }
            if(relatedAsset != null && relatedAsset.Model_Year__c != null ){
                newEvent.Model_Year__c = relatedAsset.Model_Year__c;
            }
            if(relatedAsset != null && relatedAsset.Name != null ){
                newEvent.VIN__c = relatedAsset.Name;
            }
            if(relatedAsset != null && relatedAsset.Handover_Date__c != null ){
                newEvent.Vehicle_Purchase_Date__c = ((DateTime)relatedAsset.Handover_Date__c).format('dd/MM/yyyy');  
            }
            if(relatedAsset != null && relatedAsset.Last_Registration_Date__c != null){
                newEvent.Vehicle_Registration_Date__c = ((DateTime)relatedAsset.Last_Registration_Date__c).format('dd/MM/yyyy');
            }
            if(relatedAsset != null && relatedAsset.Delivered_Date__c != null){
                newEvent.Vehicle_Delivery_Date__c = ((DateTime)relatedAsset.Delivered_Date__c).format('dd/MM/yyyy');
            }
            if(ed != null && ed.Event_DateTime__c !=  null){ 
                newEvent.Service_Event_Date__c = ed.Event_DateTime__c.format('dd/MM/yyyy');
            }
            if(ed != null && ed.Survey_Suppression_Flag__c != null ){
                if(ed.Survey_Suppression_Flag__c == TRUE){
                    newEvent.Complete_Suppression__c = 'Yes';
                }
                if(ed.Survey_Suppression_Flag__c == False){
                    newEvent.Complete_Suppression__c = 'No';
                }
            }
            if(ed != null && ed.Event_DateTime__c != null){
                newEvent.Breakdown_Date__c = ed.Event_DateTime__c.format('dd/MM/yyyy');
            }
            
            listOfRoadsideEvents.add(newEvent);
        }
        return listOfRoadsideEvents;
    }
    
}