/**
 * Created by Ethan Sargent on 16/10/19.
 */

global with sharing class QantasBusinessRewardsResponseDto extends BaseResponseDto
{

    global List<QantasBusinessRewardsTransactionDto> Data {get; set;}

    public void init()
    {
        if (this.Data == null)
        {
            this.Data = new List<QantasBusinessRewardsTransactionDto>();
        }
    }

    public QantasBusinessRewardsResponseDto()
    {
        super();
        init();
    }

    public QantasBusinessRewardsResponseDto(List<Loyalty_Points_Transaction__c> pointsTransactions)
    {
        this();
        Integer recordCount = 0;
        for (Loyalty_Points_Transaction__c pointsTransaction : pointsTransactions)
        {
            Data.add(new QantasBusinessRewardsTransactionDto(pointsTransaction, recordCount));
            pointsTransaction.Transaction_Delivery_Status__c = Constants.LOYALTY_TRANSACTION_SENT;
            String recordId = pointsTransaction.Id;
            pointsTransaction.Loyalty_Partner_Reference__c = recordId.substring(recordId.length() - Constants.LOYALTY_PARTNER_REF_LENGTH, recordId.length());
            pointsTransaction.Transaction_Date__c = Date.today();
            recordCount++;
        }
        update pointsTransactions;
    }
}