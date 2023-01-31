public class webToLeadLookUpSetter {
    
    
    private Set<String> currentVehicleNames = new Set<String>();
    private Set<String> preferredRetailerNames = new Set<String>();
    private Set<String> ciCodes = new Set<String>(); //TCRM-2691
    private Set<String> brandNames = new Set<String>();
    private Set<String> primaryModelNames = new Set<String>();
    private Set<String> secondaryModelNames = new Set<String>();
    private Map<Lead, Id> leadsWithQueueIds = new Map<Lead, Id>();
    private Set<Id> allQueueIds = new Set<Id>();
    private Set<Id> validQueueIds = new Set<Id>();
    private Map<String, Vehicle_Specification__c> makesMap = new Map<String, Vehicle_Specification__c>();
    private Map<String, Vehicle_Specification__c> modelsMap = new Map<String, Vehicle_Specification__c>();
    private Map<String, Account> retailerMap = new Map<String, Account>();
    private Map<String, Account> retailerCIcodeMap = new Map<String, Account>(); //TCRM-2691
    
    public void mappingFieldPopulated(List<Lead> leads){
        PopulateMappingMaps(leads);
        Set<Lead> accountQueuesToCheck = new Set<Lead>();
        // Find the queue names for Brazil_NSC and India_Marketing. using Custom labels and reduced 2 queries to 1.
        List<Group> ques = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND (Name =: Label.Brazil_NSC_Queue or Name =: Label.India_Marketing_Queue) ];
        Id brazilNSCqueue;
        Id indiaMarketQueue;
        if(ques != null && ques.Size() >0 ){
            for(Group qu :ques ){
                if(qu.Name != null && qu.Name == Label.Brazil_NSC_Queue){
                    brazilNSCqueue = qu.id;
                }
                else if(qu.Name != null && qu.Name == Label.India_Marketing_Queue){
                    indiaMarketQueue = qu.Id;
                }
            }
        }
        for(Lead lead : leads){
            if(String.IsNotBlank(lead.Mapping_Current_Vehicle__c) && makesMap.containsKey(lead.Mapping_Current_Vehicle__c.toUpperCase())){
                lead.Current_Vehicle_Brand__c = makesMap.get(lead.Mapping_Current_Vehicle__c.toUpperCase()).Id;
            }
            if(String.IsNotBlank(lead.Mapping_Brand__c) && makesMap.containsKey(lead.Mapping_Brand__c.toUpperCase())){
                lead.Brand__c = makesMap.get(lead.Mapping_Brand__c.toUpperCase()).Id;
            }
            if(String.IsNotBlank(lead.Mapping_Primary_Model_of_Interest__c) && modelsMap.containsKey(lead.Mapping_Primary_Model_of_Interest__c.toUpperCase())){
                lead.Primary_Model_Interest__c = modelsMap.get(lead.Mapping_Primary_Model_of_Interest__c.toUpperCase()).Id;
            }
            if(String.IsNotBlank(lead.Mapping_Secondary_Model_of_Interest__c) && modelsMap.containsKey(lead.Mapping_Secondary_Model_of_Interest__c.toUpperCase())){
                lead.Secondary_Model_Interest__c = modelsMap.get(lead.Mapping_Secondary_Model_of_Interest__c.toUpperCase()).Id;
            }
            if(String.IsNotBlank(lead.Mapping_Preferred_Retailer__c)){
                System.debug('ratailerMap'+retailerMap);
                System.debug('lead'+lead);
                if(retailerMap.containsKey(lead.Mapping_Preferred_Retailer__c.toUpperCase())){
                    Account preferredRetailer = retailerMap.get(lead.Mapping_Preferred_Retailer__c.toUpperCase());
                    lead.Preferred_Retailer__c = preferredRetailer.Id;
                    if(preferredRetailer.Parent != null && String.IsNotBlank(preferredRetailer.Parent.Queue_ID__c)){
                        System.debug('Adding queue');
                        leadsWithQueueIds.put(lead, preferredRetailer.Parent.Queue_ID__c);
                    }
                    else{
                        System.debug('Mapping Retailer is blank');
                        if(lead.Country_ISO_Code__c == 'BR'){
                            lead.OwnerId = brazilNSCqueue;
                        }
                        else if(lead.Country_ISO_Code__c == 'IN'){
                            lead.OwnerId = indiaMarketQueue;
                        }
                        //lead.Mapping_Preferred_Retailer__c = null;
                    }
                }
                else{
                    if(lead.Country_ISO_Code__c == 'BR'){
                        lead.OwnerId = brazilNSCqueue;
                    }
                    else if(lead.Country_ISO_Code__c == 'IN'){
                        lead.OwnerId = indiaMarketQueue;
                    }else{
                        lead.Mapping_Preferred_Retailer__c = null;
                    }
                }
            } 
            if(String.IsNotBlank(lead.Mapping_CI_code__c)){
                if(retailerCIcodeMap.containsKey(lead.Mapping_CI_code__c)){
                    Account preferredRetailer2 = retailerCIcodeMap.get(lead.Mapping_CI_code__c);
                    lead.Preferred_Retailer__c = preferredRetailer2.Id; 
                    leadsWithQueueIds.put(lead, preferredRetailer2.Queue_ID__c); 
                } 
            } 
        }
        
        //Id brazilNSCqueue = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'Brazil NSC Queue' LIMIT 1].Id;
        //Id brazilNSCqueue = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name =: Label.Brazil_NSC_Queue LIMIT 1].Id;
        
        for(Lead leads2 : leads){
            if(leads2.Country_ISO_Code__c == 'BR' && leads2.rating != 'Hot' && leads2.rating != 'Warm' ){
                System.debug('Dont set to retailer queue');
                leads2.OwnerId = brazilNSCqueue;
            } 
        }
        
        //Id indiaMarketQueue = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name = 'India Marketing Call Centre Queue' LIMIT 1].Id;
        //Id indiaMarketQueue = [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name =: Label.India_Marketing_Queue LIMIT 1].Id;
        for(Lead leads2 : leads){
            if(leads2.Country_ISO_Code__c == 'IN' && leads2.rating == 'Cold' ){
                leads2.OwnerId = indiaMarketQueue;
            } 
        }

        List<Group> queueSetToSend = new  List<Group>();
        allQueueIds = new Set<Id>(leadsWithQueueIds.values());
        for(Group g : [SELECT Id,Name, DoesSendEmailToMembers, Email  FROM Group WHERE Type = 'Queue' AND Id IN :allQueueIds]){
            validQueueIds.add(g.Id);
            if(g.DoesSendEmailToMembers == true){
                queueSetToSend.add(g);
            }
        }

        if(queueSetToSend.size() > 0){
            System.debug('<<< Inside Synchronous Method >>>');
            NotifyQueueMembers NQM = new NotifyQueueMembers();
            NQM.CheckMembersAndSendEmail(queueSetToSend, leadsWithQueueIds,modelsMap,false);
        }
        
        for(Lead lead : leadsWithQueueIds.keySet()){
            if((lead.Country_ISO_Code__c != 'BR' && lead.Country_ISO_Code__c != 'IN')|| (lead.Country_ISO_Code__c == 'BR' && (lead.rating == 'Hot' || lead.Rating == 'Warm')) 
               || ((lead.Country_ISO_Code__c == 'IN' && lead.rating != 'Cold'))){
                   Id newOwnerId = leadsWithQueueIds.get(lead);
                   System.debug('Set to retailer queue');
                   if(validQueueIds.contains(newOwnerId)){
                       lead.OwnerId = newOwnerId;
                   } else {
                       lead.Mapping_Preferred_Retailer__c = null;
                   }
               }
        }    
    }
    
    public void PopulateMappingMaps(List<Lead> leads){
        
        Id modelRecordType =Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        /* for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName IN ('Model', 'Make') AND SobjectType = 'Vehicle_Specification__c']){
if(rt.DeveloperName.equalsIgnoreCase('MODEL')){
modelRecordType = rt.Id;
}
else if(rt.DeveloperName.equalsIgnoreCase('MAKE')){
makeRecordType = rt.Id;
}
}*/
        Id retailerRecordType = AccountUtilities.RecordTypes.get('Retailer').Id;
        for(Lead lead : leads){
            if(String.IsNotBlank(lead.Mapping_Current_Vehicle__c)){
                currentVehicleNames.add(lead.Mapping_Current_Vehicle__c);   
            }
            if(String.IsNotBlank(lead.Mapping_Preferred_Retailer__c)){
                preferredRetailerNames.add(lead.Mapping_Preferred_Retailer__c);
            } 
            if(String.IsNotBlank(lead.Mapping_CI_code__c)){ 
                ciCodes.add(lead.Mapping_CI_code__c); 
            }  
            if(String.IsNotBlank(lead.Mapping_Brand__c)){
                brandNames.add(lead.Mapping_Brand__c);  
            }
            if(String.IsNotBlank(lead.Mapping_Primary_Model_of_Interest__c)){
                primaryModelNames.add(lead.Mapping_Primary_Model_of_Interest__c);
            }
            if(String.IsNotBlank(lead.Mapping_Secondary_Model_of_Interest__c)){
                secondaryModelNames.add(lead.Mapping_Secondary_Model_of_Interest__c);   
            }
        }
        Set<String> vehicleSpecSet = new Set<String>();
        vehicleSpecSet.addAll(currentVehicleNames);
        vehicleSpecSet.addAll(brandNames);
        vehicleSpecSet.addAll(primaryModelNames);
        vehicleSpecSet.addAll(secondaryModelNames);
        for(Vehicle_Specification__c vehicleSpec : [SELECT Id, Name,Model_code__c,Is_Currently_Sold__c, RecordTypeId FROM Vehicle_Specification__c WHERE (Name IN :vehicleSpecSet OR Model_code__c IN :vehicleSpecSet)  ]){
            
            if(vehicleSpec.RecordTypeId == modelRecordType && vehicleSpec.Is_Currently_Sold__c == true ){
                if(!modelsMap.containsKey(vehicleSpec.Name.toUpperCase())){
                    modelsMap.put(vehicleSpec.Name.toUpperCase(), vehicleSpec);  
                }
                if(vehicleSpec.Model_code__c != null && !modelsMap.containsKey(vehicleSpec.Model_code__c.toUpperCase())){
                    modelsMap.put(vehicleSpec.Model_code__c.toUpperCase(), vehicleSpec);  
                }
                
            }
            else if(vehicleSpec.RecordTypeId == makeRecordType){
                makesMap.put(vehicleSpec.Name.toUpperCase(), vehicleSpec);
            }
        }
        system.debug('modelsMap '+modelsMap);
        if (!preferredRetailerNames.isEmpty()) { // TCRM-2691 
            for(Account account : [SELECT Id, Name, Secondary_Dealer_Code__c, Parent.Queue_ID__c FROM Account WHERE Secondary_Dealer_Code__c IN :preferredRetailerNames AND RecordTypeId = :retailerRecordType]){
                retailerMap.put(account.Secondary_Dealer_Code__c.toUpperCase(), account);   
            }      
        }  
        if (!ciCodes.isEmpty()) {
            for(Account account : [SELECT Id, Name, Queue_ID__c, Dealer_CI_Code__c, Parent.Queue_ID__c FROM Account WHERE Dealer_CI_Code__c IN :ciCodes AND RecordTypeId = :retailerRecordType AND Queue_ID__c != null]){  
                retailerCIcodeMap.put(account.Dealer_CI_Code__c, account);  
            }
        }   
        
    }
    @future
    public static void PopulateLeadQueueData(String leadStr){
        List<lead> leads = (List<lead>)JSON.deserialize(leadStr, List<lead>.class);
        Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Id retailerRecordType = AccountUtilities.RecordTypes.get('Retailer').Id;
        Map<String, Account> retailerCIcodePostMap = new Map<String, Account>();
        Map<String, Account> retailerPostMap = new Map<String, Account>();
        Map<Lead, Id> postleadsWithQueueIds = new Map<Lead, Id>();
        Set<Id> postvalidQueueIds = new Set<Id>();
        Set<Id> postallQueueIds = new Set<Id>();
        Set<String> currentVehicleNames = new Set<String>();
        Set<String> preferredRetailerNames = new Set<String>();
        Set<String> ciCodes = new Set<String>(); //TCRM-2691
        Set<String> brandNames = new Set<String>();
        Set<String> primaryModelNames = new Set<String>();
        Set<String> secondaryModelNames = new Set<String>();
        Map<String, Vehicle_Specification__c> modelsMap = new Map<String, Vehicle_Specification__c>();
        
        for(Lead lead : leads){
            if(lead.NZ_Campaign_Id__c != null || lead.Country_ISO_Code__c == 'NZ'){
                if(String.IsNotBlank(lead.Mapping_Current_Vehicle__c)){
                    currentVehicleNames.add(lead.Mapping_Current_Vehicle__c);   
                }
                if(String.IsNotBlank(lead.Mapping_Preferred_Retailer__c)){
                    preferredRetailerNames.add(lead.Mapping_Preferred_Retailer__c);
                } 
                if(String.IsNotBlank(lead.Mapping_CI_code__c)){ 
                    ciCodes.add(lead.Mapping_CI_code__c); 
                }  
                if(String.IsNotBlank(lead.Mapping_Brand__c)){
                    brandNames.add(lead.Mapping_Brand__c);  
                }
                if(String.IsNotBlank(lead.Mapping_Primary_Model_of_Interest__c)){
                    primaryModelNames.add(lead.Mapping_Primary_Model_of_Interest__c);
                }
                if(String.IsNotBlank(lead.Mapping_Secondary_Model_of_Interest__c)){
                    secondaryModelNames.add(lead.Mapping_Secondary_Model_of_Interest__c);   
                }
            }
        }
        system.debug('modelsMap '+modelsMap);
        if (!preferredRetailerNames.isEmpty()) { // TCRM-2691 
            for(Account account : [SELECT Id, Name, Secondary_Dealer_Code__c, Parent.Queue_ID__c FROM Account WHERE Secondary_Dealer_Code__c IN :preferredRetailerNames AND RecordTypeId = :retailerRecordType]){
                retailerPostMap.put(account.Secondary_Dealer_Code__c.toUpperCase(), account);   
            }      
        }  
        if (!ciCodes.isEmpty()) {
            for(Account account : [SELECT Id, Name, Queue_ID__c, Dealer_CI_Code__c, Parent.Queue_ID__c FROM Account WHERE Dealer_CI_Code__c IN :ciCodes AND RecordTypeId = :retailerRecordType AND Queue_ID__c != null]){  
                retailerCIcodePostMap.put(account.Dealer_CI_Code__c, account);  
            }
        }   
        
        Set<String> vehicleSpecSet = new Set<String>();
        vehicleSpecSet.addAll(currentVehicleNames);
        vehicleSpecSet.addAll(brandNames);
        vehicleSpecSet.addAll(primaryModelNames);
        vehicleSpecSet.addAll(secondaryModelNames);
        for(Vehicle_Specification__c vehicleSpec : [SELECT Id, Name,Model_code__c,Is_Currently_Sold__c, RecordTypeId FROM Vehicle_Specification__c WHERE (Name IN :vehicleSpecSet OR Model_code__c IN :vehicleSpecSet)  ]){
            
            if(vehicleSpec.RecordTypeId == modelRecordType && vehicleSpec.Is_Currently_Sold__c == true ){
                if(!modelsMap.containsKey(vehicleSpec.Name.toUpperCase())){
                    modelsMap.put(vehicleSpec.Name.toUpperCase(), vehicleSpec);  
                }
                if(vehicleSpec.Model_code__c != null && !modelsMap.containsKey(vehicleSpec.Model_code__c.toUpperCase())){
                    modelsMap.put(vehicleSpec.Model_code__c.toUpperCase(), vehicleSpec);  
                }
                
            }
        }

        for(Lead lead : leads){
            // if(lead.NZ_Campaign_Id__c != null){ CXPD-1666 - SEND NZ Email Notification for No CampaignID
                if(String.IsNotBlank(lead.Mapping_Preferred_Retailer__c)){
                    System.debug('ratailerMap'+retailerPostMap);
                    System.debug('lead'+lead);
                    if(retailerPostMap.containsKey(lead.Mapping_Preferred_Retailer__c.toUpperCase())){
                        Account preferredRetailer = retailerPostMap.get(lead.Mapping_Preferred_Retailer__c.toUpperCase());
                        if(preferredRetailer.Parent != null && String.IsNotBlank(preferredRetailer.Parent.Queue_ID__c)){
                            System.debug('Adding queue');
                            postleadsWithQueueIds.put(lead, preferredRetailer.Parent.Queue_ID__c);
                        }
                    }
                }
                if(String.IsNotBlank(lead.Mapping_CI_code__c)){
                    if(retailerCIcodePostMap.containsKey(lead.Mapping_CI_code__c)){
                        Account preferredRetailer2 = retailerCIcodePostMap.get(lead.Mapping_CI_code__c);
                        postleadsWithQueueIds.put(lead, preferredRetailer2.Queue_ID__c); 
                    } 
                }
            // }
        }

        List<Group> queueSetToSend = new  List<Group>();
        postallQueueIds = new Set<Id>(postleadsWithQueueIds.values());
        for(Group g : [SELECT Id,Name, DoesSendEmailToMembers, Email  FROM Group WHERE Type = 'Queue' AND Id IN :postallQueueIds]){
            postvalidQueueIds.add(g.Id);
            if(g.DoesSendEmailToMembers == true){
                queueSetToSend.add(g);
            }
        } 

        if(queueSetToSend.size() > 0){
            System.debug('<<< Inside Asynchronous Method >>>');
            NotifyQueueMembers NQM = new NotifyQueueMembers();
            NQM.CheckMembersAndSendEmail(queueSetToSend, postleadsWithQueueIds,modelsMap,true);
        }
    }
}