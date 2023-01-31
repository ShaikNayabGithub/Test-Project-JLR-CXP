public class InvocableRDAServicePlanAdd {

    @InvocableMethod(Label='Add Service Plan')
    public static void process( List<Id> RDA) {
        List<RDA__c> rdas = new List<RDA__c>();
        if(RDA != null && RDA.size() > 0){
            for(Id rdaid : RDA){
                RDA__c rd = new RDA__c();
                rd.Id = rdaid;
                rdas.add(rd);
            }
            System.debug('process got rdas'+rdas);
            ServicePlanContractCreationLogic spcl = new ServicePlanContractCreationLogic();
             spcl.createNewServicePlanContract(rdas);
             System.debug('process Finished got rdas'+rdas);
        }

        
       
    }
    
    
}