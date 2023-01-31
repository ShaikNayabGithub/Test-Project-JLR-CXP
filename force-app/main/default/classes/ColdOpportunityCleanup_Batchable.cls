global class ColdOpportunityCleanup_Batchable implements Database.Batchable<SObject>, Schedulable {

    Integer numberOfDaysInPast = -90;
    
    global ColdOpportunityCleanup_Batchable() {
        numberOfDaysInPast = -90;
    }
    
    global ColdOpportunityCleanup_Batchable(Integer numberOfDays) {
        //for testing - cannot set LastModifiedDate for newly created, test, Opportunity
        numberOfDaysInPast = numberOfDays;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){
        Date todaysdate = Date.today();
        Date ninetydays = todaysdate.addDays(numberOfDaysInPast);
		return Database.getQueryLocator([SELECT Id FROM Opportunity WHERE LastModifiedDate < :ninetydays AND (Next_Activity_Date__c = null OR Next_Activity_Date__c < :todaysdate) AND (NOT StageName IN ('Order', 'Handover', 'Retailer Lost')) AND IsClosed = false]);
	}

    global void execute(Database.BatchableContext info, List<Opportunity> oppList){
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Opportunity opp : oppList) { 
            oppsToUpdate.add(new Opportunity(Id=opp.Id, StageName='Retailer Lost', Retailer_Loss_Category__c='Experience', Retailer_Loss_Type__c='Response Time', Retailer_Loss_Description__c='Retailer Response Time'));            
        }
        Database.update(oppsToUpdate, false);
    }

    global void finish(Database.BatchableContext info) {}

    global void execute(SchedulableContext sc){
        ColdOpportunityCleanup_Batchable batch = new ColdOpportunityCleanup_Batchable();
        database.executebatch(batch, 50);
    }
    
}