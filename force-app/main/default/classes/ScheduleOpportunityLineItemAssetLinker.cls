global class ScheduleOpportunityLineItemAssetLinker implements Schedulable, Database.batchable<sObject>, Database.Stateful {

    String query; 
    Map<String,Integer> batchCounters = new Map<String,Integer>{'TOTAL'=>0,'OK'=>0,'NOK'=>0,'SKIP'=>0,'PARTIAL'=>0}; 
    Map<String,Integer> recordCounters = new Map<String,Integer>();
    Integer saveResultCounter = -1;
    String successes='';
    String errors = '';
    TriggerFramework__c tf = new TriggerFramework__c();
    List<Boolean> tfInitialValues = new List<Boolean>{false,false,false};

    global void execute(SchedulableContext SC) {
        Database.executebatch(new ScheduleOpportunityLineItemAssetLinker(), 250);
    }

    global ScheduleOpportunityLineItemAssetLinker() {
        query = 'select id,asset__c,Vista_Order_Number__c from opportunitylineitem where asset__c = null and vista_order_number__c != null';

        tf = TriggerFramework__c.getInstance(UserInfo.getProfileId()); 
        if (tf.id == null) { //required when running within a Test Class
            tf = new TriggerFramework__c();
            tf.SetupOwnerId = UserInfo.getProfileId();
            insert tf;
        } 

        tfInitialValues[0] = tf.OpportunityLineItem_SkipValidations__c;
        tfInitialValues[1] = tf.OpportunityLineItem_PreUpdate__c;
        tfInitialValues[2] = tf.OpportunityLineItem_PostUpdate__c;

        tf.OpportunityLineItem_SkipValidations__c = true;
        tf.OpportunityLineItem_PreUpdate__c = false;
        tf.OpportunityLineItem_PostUpdate__c = false;
        update tf; 
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> LineItems)
    {
        batchCounters.put('TOTAL',batchCounters.get('TOTAL')+1);
        Set<String> VistOrderNumbers = new Set<String>(); 
        for (OpportunityLineItem li : LineItems) VistOrderNumbers.add(li.Vista_Order_Number__c); 
        List<Vista_Request__c> GOFs = [select id, VIN__c, MetaOrderNumber__c from Vista_Request__c where VIN__c != null and MetaOrderNumber__c in : VistOrderNumbers];
        if (!GOFs.isEmpty()) {
            Map<String,String> OrderNumberToVIN = new Map<String,String>();
            for (Vista_Request__c GOF : GOFs) OrderNumberToVIN.put(GOF.MetaOrderNumber__c,GOF.VIN__c); 
            if (!OrderNumberToVIN.isEmpty()) { 

                List<Asset> Assets = [select id, name from asset where name in : OrderNumberToVIN.values()];
                if (!Assets.isEmpty()) {

                    Map<String,Id> VINtoAssetID = new Map<String,Id>();
                    for (Asset a : Assets) VINtoAssetID.put(a.name,a.id);

                    for (OpportunityLineItem li : LineItems) {
                        if ( OrderNumberToVIN.containsKey(li.Vista_Order_Number__c) && 
                             VINtoAssetID.containsKey( OrderNumberToVIN.get(li.Vista_Order_Number__c) ) ) 
                            li.Asset__c = VINtoAssetID.get(OrderNumberToVIN.get(li.Vista_Order_Number__c));
                    } 

                    recordCounters = new Map<String,Integer>{'TOTAL'=>0,'OK'=>0,'NOK'=>0}; 

                    Database.SaveResult[] srList = Database.update(LineItems, false);
                    for (Database.SaveResult sr : srList) {
                        saveResultCounter++;
                        recordCounters.put('TOTAL',recordCounters.get('TOTAL')+1);
                        if (sr.isSuccess()) { 
                            successes+='Updated OpportunityLineItem ID: ' + sr.getId() + '\n';
                            recordCounters.put('OK',recordCounters.get('OK')+1);
                        } else {            
                            for(Database.Error err : sr.getErrors()) { 
                                errors+='Error updating OpportunityLineItem ID: ' + LineItems[saveResultCounter].Id  + '\n';                 
                                errors+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
                                errors+='Opportunity fields that affected this error: ' + err.getFields() + '\n\n'; 
                            }
                            recordCounters.put('NOK',recordCounters.get('NOK')+1);
                        }
                    }

                    if (recordCounters.get('OK') == 0) 
                        batchCounters.put('NOK',batchCounters.get('NOK')+1);
                    else if (recordCounters.get('NOK') == 0) 
                        batchCounters.put('OK',batchCounters.get('OK')+1);
                    else batchCounters.put('PARTIAL',batchCounters.get('PARTIAL')+1);
                } else batchCounters.put('SKIP',batchCounters.get('SKIP')+1);
            } else batchCounters.put('SKIP',batchCounters.get('SKIP')+1);
        } else batchCounters.put('SKIP',batchCounters.get('SKIP')+1);
    }

    global void finish(Database.BatchableContext BC)
    {
            tf.OpportunityLineItem_SkipValidations__c = tfInitialValues[0];
            tf.OpportunityLineItem_PreUpdate__c = tfInitialValues[1];
            tf.OpportunityLineItem_PostUpdate__c = tfInitialValues[2]; 
            update tf;

            String counterStatus = 'Total batches: ' + batchCounters.get('TOTAL') + '\n';
            counterStatus += 'Skipped batches: ' + batchCounters.get('SKIP') + '\n';
            counterStatus += 'Fully Processed batches: ' + batchCounters.get('OK') + '\n';
            counterStatus += 'Partially Processed batches: ' + batchCounters.get('PARTIAL') + '\n';
            counterStatus += 'Failed batches: ' + batchCounters.get('NOK') + '\n';

            if ( batchCounters.get('TOTAL') != batchCounters.get('OK') )
                EmailUtility.SendEmail(Label.TEST_FAILURE_NOTIFICATION_EMAILS.split(','),'ScheduleOpportunityLineItemAssetLinker Daemon','ScheduleOpportunityLineItemAssetLinker Status','<pre>'+counterStatus+'</pre><hr/>Errors:<br/><pre>'+errors+'</pre><hr/>Successes:<br/><pre>'+successes+'</pre>');

    }

}