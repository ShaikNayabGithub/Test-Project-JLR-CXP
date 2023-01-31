/********************************************************************************************************
* Name         : LeadRestSvc
* @Date        : 04-May-2017
* @Description : This class is used for insert leads coming through API call
* UPDATES
* Version          Created By                    Date                        Description
*-------------------------------------------------------------------------------------------
*   1.0              SaasFocus                    04-May-2017                  Initial Creation 
**************************************************************************************************************/
@RestResource(urlMapping = '/insertLeads/*')
global class LeadRestSvc {
    static List < Lead > lstLeadtoInsert = new List < Lead > ();
    static List < lead_Request_mapping > lstValidLeads = new List < lead_Request_mapping > ();
    static set < string > setVSName = new set < string > ();
    static set < string > newCarModel = new set < string > ();
    static set < string > usedCarModel = new set < string > ();
    static Map < string, Id > mapVS = new map < string, Id > ();
    static Map < string, Id > mapNewCarModel = new map < string, Id > ();
    static Map < string, Id > mapUsedCarModel = new map < string, Id > ();
    static List < lead_Response > lstResponse = new List < lead_Response > ();
    static set < Id > setLeadId = new set < Id > ();
    static set < string > setDLRID = new set < string > ();
    static Map < string, Id > mapDLRCodeToId = new map < string, Id > ();
    static Map < string, string > mapDLRCodeToName = new map < string, string > ();
    static Map < string, Id > mapQueue = new Map < string, id > ();
    static Lead objLead;
    @HttpPost
    global static List < lead_Response > doPost(List < lead_Request_mapping > lead_Data) {
        
        try {
            
            if (lead_data.size() > 0) {
                validateLeads(lead_data);
            }
            //Querying car brand.
            if (setVSName.size() != 0) {
                for (Vehicle_Specification__c vs: [Select id, name from Vehicle_Specification__c where name in : setVSName]) {
                    if (vs.name != '') {
                        mapVS.put(vs.name, vs.Id);
                    }
                }
            }
            //Querying new car model.
            if (newCarModel.size() != 0) {
                for (Vehicle_Specification__c vs: [Select id, name from Vehicle_Specification__c where name in : newCarModel and Is_Currently_Sold__c = true and recordtype.DeveloperName =:SObjectUtilities.RecordTypes.get('Vehicle_Specification__c').get('Model').DeveloperName]) {
                    if (vs.name != '') {
                        mapNewCarModel.put(vs.name, vs.Id);
                    }
                }
            }
            //Querying used car model.
            if (usedCarModel.size() != 0) {
                for (Vehicle_Specification__c vs: [Select id, name from Vehicle_Specification__c where name in : usedCarModel and recordtype.DeveloperName =:SObjectUtilities.RecordTypes.get('Vehicle_Specification__c').get('Model').DeveloperName]) {
                    if (vs.name != '') {
                        mapUsedCarModel.put(vs.name, vs.Id);
                    }
                }
            }
            
            //Querying Dealer based on dealer Id.
            if (setDLRID.size() > 0) {
                for (Account objAcc: [Select id, Primary_Dealer_Code__c, name from Account where Primary_Dealer_Code__c in : setDLRID]) {
                    mapDLRCodeToId.put(objAcc.Primary_Dealer_Code__c, objAcc.id);
                    mapDLRCodeToName.put(objAcc.Primary_Dealer_Code__c, objAcc.name);
                    
                }
            }
            
            //Querying the queue specified in label.
            for (Group objQ: [select Id, name from Group where(Name in : mapDLRCodeToName.values() or name = : Label.JLR_Owner_Queue) and Type = 'Queue']) {
                mapQueue.put(objQ.name, objQ.Id);
            }
            if (lstValidLeads.size() > 0) {
                mapValidLeads();
            }
            
            if (lstLeadtoInsert.size() > 0) {
                upsertLeads();
            }
            return lstResponse;
        } catch (exception e) {
            lstResponse.add(new lead_Response('', '', false, 'Failure :' + e.getMessage()));
            return lstResponse;
        }
    }
    public static void validateLeads(List < lead_Request_mapping > lead_Data) {
        for (lead_Request_mapping objReq: lead_Data) {
            if (objReq.website_lead_id == '')
                lstResponse.add(new lead_Response('', objReq.website_lead_id, false, 'website_lead_id Cannont be blank for ' + objReq.fname));
            else
                If(objReq.lname == '')
                lstResponse.add(new lead_Response('', objReq.website_lead_id, false, 'lastname Cannont be blank for ' + objReq.website_lead_id));
            else
                If(objReq.email == '')
                lstResponse.add(new lead_Response('', objReq.website_lead_id, false, 'email Cannont be blank for ' + objReq.website_lead_id));
            else
                If(objReq.used_car_purchase_offer == '' || !objReq.used_car_purchase_offer.isNumeric())
                lstResponse.add(new lead_Response('', objReq.website_lead_id, false, 'Invalid used_car_purchase_offer for ' + objReq.website_lead_id));
            else {
                lstValidLeads.add(objReq);
                setVSName.add(objReq.newcar_make);
                setVSName.add(objReq.usedcar_make);
                newCarModel.add(objReq.newcar_model);
                usedCarModel.add(objReq.usedcar_model);
                setDLRID.add(objReq.dlrid);
            }
            
        }
    }
    
    public static void mapValidLeads() {
        for (lead_Request_mapping objReq: lstValidLeads) {
            
            objLead = new Lead(
                Preferred_Retailer__c = mapDLRCodeToId.get(objReq.dlrid),
                WebSiteLeadId__c = objReq.WEBSITE_LEAD_ID,
                JLR_Dealer_Id__c = objReq.dlrid,
                FirstName = objReq.fname,
                LastName = objReq.lname,
                email = objReq.email,
                MobilePhone = objReq.mobile_no,
                Brand__c = mapVS.get(objReq.newcar_make),
                Primary_Model_Interest__c = mapNewCarModel.get(objReq.newcar_model),
                Current_Vehicle_Brand__c = mapVS.get(objReq.usedcar_make),
                Current_Vehicle__c = mapUsedCarModel.get(objReq.usedcar_model),
                Value__c = Decimal.valueof(objReq.used_car_purchase_offer),
                Purchase_Type__c = 'New Vehicle',
                LeadSource = 'Online Booking',
                JLR_India_Udaan_Lead_Type__c = objReq.lead_type,
                Industry = 'Other',
                Budget__c = 500000,
                JLR_Customer_Id__c = objReq.customer_id,
                JLR_Product_Id__c = objReq.product_id,
                JLR_City__c = objReq.custom_registration_city,
                Used_Car_Model_Type__c = objReq.usedcar_model_type,
                Country_ISO_Code__c = 'IN',
                In_Market_Date__c = Date.newInstance(System.Today().year(), System.Today().month(), Date.daysInMonth(System.Today().year(), System.Today().month()))
                
            );
            if (mapVS.get(objReq.usedcar_make) != null) {
                objLead.Trade_In__c = true;
                
            }
            if (objReq.lead_type == 'Booking') {
                if (mapQueue.containskey(mapDLRCodeToName.get(objReq.dlrid))) {
                    objLead.ownerId = mapQueue.get(mapDLRCodeToName.get(objReq.dlrid));
                }
            } 
            else {
                if (mapQueue.containskey(Label.JLR_Owner_Queue)) {
                    objLead.ownerId = mapQueue.get(Label.JLR_Owner_Queue);
                }
            }
            if (objReq.payment_type == 'EMI') {
                objLead.Finance_Interest__c = true;
            }
            
            if (objReq.lead_type == 'Test Drive Request' && SObjectUtilities.RecordTypes.get('Lead').get('Test_Drive_Request') != null) {
                objLead.recordtypeId = SObjectUtilities.RecordTypes.get('Lead').get('Test_Drive_Request').Id;
            } 
            else
                if ((objReq.lead_type == 'Quotation' || objReq.lead_type == 'Booking') && SObjectUtilities.RecordTypes.get('Lead').get('Generic')!= null) {
                    objLead.recordtypeId = SObjectUtilities.RecordTypes.get('Lead').get('Generic').Id;
                }
            lstLeadtoInsert.add(objLead);
        }
    }
    public static void upsertLeads() {
        
        Schema.SObjectField f = Lead.Fields.WebSiteLeadId__c;
        List < Database.UpsertResult > Results = Database.upsert(lstLeadtoInsert, f, false);
        Integer Index = 0;
        for (Database.UpsertResult sr: Results) {
            if (sr.isSuccess()) {
                if (sr.getId() != null) {
                    setLeadId.add(sr.getId());
                }
            } else {
                for (Database.Error err: sr.getErrors()) {
                    lstResponse.add(new lead_Response('', lstLeadtoInsert[index].WebSiteLeadId__c, false, 'Failure:' + err.getMessage()));
                }
            }
            Index++;
        }
        for (Lead objsuccessLead: [Select id, JLR_India_Udaan_Duplicate__c, WebSiteLeadId__c from Lead where id in : setLeadId]) {
            lstResponse.add(new lead_Response(objsuccessLead.id, objsuccessLead.WebSiteLeadId__c, objsuccessLead.JLR_India_Udaan_Duplicate__c, 'Lead Inserted'));
        }
    }
    
    global class lead_Request_mapping {
        public string website_lead_id;
        public string dlrid;
        public string customer_id;
        public string fname;
        public string lname;
        public string email;
        public string mobile_no;
        public string product_id;
        public string newcar_make;
        public string newcar_model;
        public string custom_registration_city;
        public string usedcar_make;
        public string usedcar_model;
        public string usedcar_model_type;
        public string used_car_purchase_offer;
        public string lead_type;
        public string payment_type;
    }
    
    global class lead_Response {
        
        string Salesforce_Id;
        string website_lead_id;
        boolean isDuplicate;
        string message;
        public lead_Response(string a, string b, boolean c, string d) {
            Salesforce_Id = a;
            website_lead_id = b;
            isDuplicate = c;
            message = d;
        }
    }
}