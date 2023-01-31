public class Vista_AssetRetriever implements Vista_EntityRetriever_I {
    public void Retrieve(Vista_RequestCollection requestCollection)
    {
        if(requestCollection.Assets == null) {
            requestCollection.Assets = new Map<String, Asset>();
        }
        //To check if Asset Vin & Order match with Request vin and order
        //Need to create a two maps one using the vin as key the other order number
        Map<string,string> vinsmap= new Map<string,string>();
        Map<string,string> orderMap= new Map<string,string>();    
        //If order number null on asset, we want to still pick up the asset
        Set<string> vinsSet = new Set<string>();
        
        for(string ordernumber :requestCollection.RecordGroups.keySet() ){
            List<Vista_RecordGroup> reqs = new List<Vista_RecordGroup>(requestCollection.RecordGroups.get(ordernumber));
            for(Vista_RecordGroup req: reqs){
                Vista_Request__c request1 = req.Request;
                if(request1.Vin__c != null || request1.Vin__c != null ){
                   
                    vinsmap.put(request1.Vin__c,request1.MetaOrderNumber__c);
                    orderMap.put(request1.MetaOrderNumber__c,request1.Vin__c);
                    vinsSet.add(request1.Vin__c);
                }
            }
        }
        //looking for existing assets with order number and vins
        for(Asset asset : [SELECT Id,VIN__c, Order_Number__c, Description_Group_Id__c,Model_Year_Code__c,Model_Year__c,Ordering_Market__c,Transmission__c,Interior_colour_code__c,Derivative__c,
                Account.RecordType.DeveloperName,Current_Planned_Delivery_Date__c,Sold_Date_Vista__c,Original_Handover_Date__c,Vehicle_Initial_Registration_Date__c,registration_number__c, product2.warranty_length__c
                FROM Asset 
               WHERE (Order_Number__c IN: requestCollection.RecordGroups.keySet()) or VIN__c in:vinsSet ]) {
                               
                               //if Asset has both order number and vin should check if these match those on the requests
                               if(String.isNotEmpty(asset.Order_Number__c) && String.isNotEmpty(asset.Vin__c)){
                                   string requestVin = orderMap.get(asset.Order_Number__c);
                                   string requestOrder = vinsmap.get(asset.Vin__c);
                                   if((String.isNotEmpty(requestOrder) && asset.Order_Number__c != requestOrder) || (String.isNotEmpty(requestVin) && asset.VIN__c != requestVin )){
                                       
                                       aop_AOPException mismatchException= new aop_AOPException();
                                       mismatchException.setMessage('Asset has Vin: '+asset.Vin__c +'and Order:'+asset.Order_Number__c+' does not match Requests');
                                       throw mismatchException;
                                       
                                   }
                                   
                               }
                               //If asset didn't have order number set it
                               if(String.isEmpty(asset.Order_Number__c) && asset.VIN__c !=  null){
                                   asset.Order_Number__c = vinsmap.get(asset.VIN__c);
                               }
            requestCollection.Assets.put(asset.Order_Number__c, asset);
        }
    }
}