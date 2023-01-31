/**
 * Created by Ethan Sargent on 16/10/19.
 */

global with sharing class QantasFrequentFlyerResponseDto extends BaseResponseDto {

    global List<QantasFrequentFlyerTransactionDto> Data {get; set;}

    public QantasFrequentFlyerResponseDto(List<Loyalty_Points_Transaction__c> pointsTransactions)
    {
        this();
        Integer recordCount = 0;
        for (Loyalty_Points_Transaction__c pointsTransaction : pointsTransactions)
        {
            Data.add(new QantasFrequentFlyerTransactionDto(pointsTransaction, recordCount));
            pointsTransaction.Transaction_Delivery_Status__c = Constants.LOYALTY_TRANSACTION_SENT;
            String recordId = pointsTransaction.Id;
            pointsTransaction.Loyalty_Partner_Reference__c = recordId.substring(recordId.length() - Constants.LOYALTY_PARTNER_REF_LENGTH, recordId.length());
            pointsTransaction.Transaction_Date__c = Date.today();
            recordCount++;
        }
        update pointsTransactions;
    }

    private void init() {
        this.Data = new List<QantasFrequentFlyerTransactionDto>();
    }

    global QantasFrequentFlyerResponseDto(){
        super();
        init();
    }

}