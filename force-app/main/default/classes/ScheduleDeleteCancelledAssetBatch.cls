/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin		01/06/2021			CXPD-1005: Scheduler for DeleteCancelledAssetBatch
* 
*/
public class ScheduleDeleteCancelledAssetBatch implements Schedulable {
    public void execute(SchedulableContext sc) {
        DeleteCancelledAssetBatch cancelAsset = new DeleteCancelledAssetBatch(); 
        Database.executebatch(cancelAsset);
    }
}