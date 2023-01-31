@isTest
private class LabelRetrieverController_Tests {
	
	@isTest static void testConstructor() {
		String labelTest = Label.Label_Retriever_Test_Label;
		PageReference ref = Page.LabelRetriever;
		ref.getParameters().put('lang', 'en');
		ref.getParameters().put('labels', 'Label_Retriever_Test_Label,Label_Retriever_Test_Label2,Label_Retriever_Test_Label3');

		Test.setCurrentPage(ref);

		LabelRetrieverController controller = new LabelRetrieverController();

		System.assertEquals(3, controller.LabelCount);
		System.assertEquals('Label_Retriever_Test_Label', controller.Labels[0]);
		System.assertEquals('Label_Retriever_Test_Label2', controller.Labels[1]);
		System.assertEquals('Label_Retriever_Test_Label3', controller.Labels[2]);
	}

	@isTest static void testConstructorWithInvalidLabel() {
		PageReference ref = Page.LabelRetriever;
		ref.getParameters().put('lang', 'en');
		ref.getParameters().put('labels', '!!Label_Retriever_Test_Label_Invalid');

		Test.setCurrentPage(ref);

		LabelRetrieverController controller = new LabelRetrieverController();

		System.assertEquals(0, controller.LabelCount);
	}

	@isTest static void testConstructorWithInvalidLanguage() {
		PageReference ref = Page.LabelRetriever;
		ref.getParameters().put('lang', '!!');
		ref.getParameters().put('labels', 'Label_Retriever_Test_Label');

		Test.setCurrentPage(ref);

		LabelRetrieverController controller = new LabelRetrieverController();

		System.assertEquals(1, controller.LabelCount);
		System.assertEquals('Label_Retriever_Test_Label', controller.Labels[0]);
	}

	@isTest static void testConstructorWithoutLabel() {
		PageReference ref = Page.LabelRetriever;
		ref.getParameters().put('lang', '!!');

		Test.setCurrentPage(ref);

		LabelRetrieverController controller = new LabelRetrieverController();

		System.assertEquals(0, controller.LabelCount);
	}
	
	@isTest static void testFindReferences() {
		String labelTest = Label.Label_Retriever_Test_Label;
		PageReference ref = Page.LabelRetriever;
		ref.getParameters().put('lang', 'en');
		ref.getParameters().put('labels', 'Label_Retriever_Test_Label');

		Test.setCurrentPage(ref);

		LabelRetrieverController controller = new LabelRetrieverController();
		controller.FindReferencesIn = labelTest;

		System.assertEquals(1, controller.LabelCount);
		System.assertEquals('Label_Retriever_Test_Label', controller.Labels[0]);
	}

	@isTest static void testFindReferencesWithoutLabel() {
		String labelTest = Label.Label_Retriever_Test_Label;
		PageReference ref = Page.LabelRetriever;
		ref.getParameters().put('lang', 'en');
		ref.getParameters().put('labels', 'Label_Retriever_Test_Label');

		Test.setCurrentPage(ref);

		LabelRetrieverController controller = new LabelRetrieverController();
		controller.FindReferencesIn = '';

		System.assertEquals(0, controller.LabelCount);
	}

}