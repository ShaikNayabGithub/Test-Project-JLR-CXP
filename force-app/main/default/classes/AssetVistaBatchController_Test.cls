@isTest
public class AssetVistaBatchController_Test {
    
    @isTest static void getUserDetailsTest(){
        AssetVistaBatchController.getUserDetails();
    }
    @isTest static void ProcessAssetVistaBatchTest(){
        String jsonStr =  AssetVistaBatchController.ProcessAssetVistaBatch();
        AssetVistaBatchController.batchWrapper wrapIns = (AssetVistaBatchController.batchWrapper)json.deserialize(jsonStr, AssetVistaBatchController.batchWrapper.class);
        if(wrapIns != null && wrapIns.batchJobId != null){
            AssetVistaBatchController.getBatchJobStatus(wrapIns.batchJobId);
            AssetVistaBatchController.abortBatchHandler(wrapIns.batchJobId);
        }
    }
}