@isTest
private class VehicleTransferRequestEmailRndr_Tests {
	
	@isTest static void testInitialiseLanguage() {

		Set<String> languageSet = new Set<String> {'en'};

		VehicleTransferRequestEmailRenderer.initialiseLanguage(languageSet);

		System.assert(true);
		
	}
	
	@isTest static void testGetRequiredFields() {
		
		Map<String, Set<String>> requiredFields = VehicleTransferRequestEmailRenderer.GetRequiredFields();

		System.assertNotEquals(null, requiredFields);

	}

	@isTest static void testRender() {

		User requestor = new User();
		User approver = new User();
		Asset vehicle = new Asset();
		String comments = 'comments';
		String language = 'en';

		Set<String> languageSet = new Set<String> {language};

		VehicleTransferRequestEmailRenderer.initialiseLanguage(languageSet);

		VehicleTransferRequestEmailRenderer renderer = new VehicleTransferRequestEmailRenderer(requestor, approver, vehicle, comments, language);

		VehicleTransferRequestEmailRenderer.EmailContent content = renderer.Render();

		System.assert(!String.isBlank(content.Subject), 'Expected that Subject would not be blank');
		System.assert(!String.isBlank(content.TextContent), 'Expected that TextContent would not be blank');
		System.assert(!String.isBlank(content.HtmlContent), 'Expected that HtmlContent would not be blank');

	}

	@isTest static void testRenderWithoutInitialisingLanguage() {

		User requestor = new User();
		User approver = new User();
		Asset vehicle = new Asset();
		String comments = 'comments';
		String language = 'fr';

		VehicleTransferRequestEmailRenderer renderer = new VehicleTransferRequestEmailRenderer(requestor, approver, vehicle, comments, language);

		try {
			VehicleTransferRequestEmailRenderer.EmailContent content = renderer.Render();
		}
		catch (VehicleTransferRequestEmailRenderer.LanguageNotInitialisedException ex) {
			System.assert(true);
			return;
		}

		System.assert(false, 'Expected that LanguageNotInitialisedException would be thrown');

	}
	
}