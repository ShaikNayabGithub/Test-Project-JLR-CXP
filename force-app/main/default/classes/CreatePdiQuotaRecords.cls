public class CreatePdiQuotaRecords implements Schedulable{
   
    public void execute(SchedulableContext sc) {
        System.debug('Invoked CreatePdiQuotaRecords schedulable implementation');
        createRecords();
    }
    public static void createRecords() {
        createRecords(null);
    }

    public static void createRecords(Date overrideStartMonth) {
        
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();

        List<PDI_Quota__c> pdiQuotas = new List<PDI_Quota__c>();
        Set<String> retailerGroupNames = new Set<String>();
        List<Account> refinedRetailerAccounts = new List<Account>();

        Date pdiQuotaMonthStart;
        if(overrideStartMonth == null) {
            pdiQuotaMonthStart = System.today().addMonths(2).toStartofMonth();
        } else {
            pdiQuotaMonthStart = overrideStartMonth.toStartofMonth();
        }

        List<Account> dualBrandRetailers = [
            SELECT Id, Name
            FROM Account 
            WHERE RecordTypeId=:recTypeId 
            AND Record_Sub_Type__c = 'Legal Entity (Dealer Group)' 
            AND Country_ISO_Code__c = 'KR' 
            ORDER BY Name DESC
        ];

        for(Account retailerAccount : dualBrandRetailers) {
            if(retailerAccount.Name == null) {
                continue;
            }
            String retailerGroupName = retailerAccount.Name.trim(); 

            if(!retailerGroupNames.contains(retailerGroupName)) {
                retailerGroupNames.add(retailerGroupName );
                refinedRetailerAccounts.add(retailerAccount);
            }
        }        
        for (Account retailerGroupAccount :refinedRetailerAccounts){
            PDI_Quota__c pdiQuota = new PDI_Quota__c();
            pdiQuota.Retailer__c = retailerGroupAccount.ID;
            pdiQuota.Month_Start__c = pdiQuotaMonthStart;
            pdiQuotas.add(pdiQuota);
        }

        insert pdiQuotas;
    }
}