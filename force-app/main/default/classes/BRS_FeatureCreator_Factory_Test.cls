@isTest
public class BRS_FeatureCreator_Factory_Test {
	//largely usesless, class under test is just instanciates objects but is not covered by other unit tests due to callout to creation of class responsible for making callouts 
	//to the metadata API
    static testmethod void Build_ReturnsBRSFeatureCreator_WhenCalled()
    {
    	BRS_FeatureCreator_Factory factory = new BRS_FeatureCreator_Factory();
    	
    	BRS_FeatureCreator result = factory.Build();
    	
    	System.AssertNotEquals(null, result);
    }
}