public with sharing class VehicleTransferRequestEmailRenderer {
	private static Map<String, Map<String, String>> translatedLabelsCache = new Map<String, Map<String, String>>();
	private static Pattern mergeFieldPattern = Pattern.compile('\\{\\!([^\\}]+)\\}'); //'

	private static Map<String, EmailContent> templates = new Map<String, EmailContent>();

	private static final String subjectTemplateLabelName = 'Vehicle_Transfer_Request';
	private static final String htmlTemplateLabelName = 'VehicleTransferRequestEmailTemplateHtml';
	private static final String textTemplateLabelName = 'VehicleTransferRequestEmailTemplateText';
	private static final List<String> requiredLabels = new List<String> {subjectTemplateLabelName, htmlTemplateLabelName, textTemplateLabelName};
	private static final EmailContent defaultTemplate = new EmailContent(Label.Vehicle_Transfer_Request, Label.VehicleTransferRequestEmailTemplateHtml,Label.VehicleTransferRequestEmailTemplateText);

	private static final Map<String, String> mergeFieldObjectToSObjectMap = new Map<String, String> {
		'requestor' => 'user',
		'approver' => 'user',
		'vehicle' => 'asset'
	};

	public static final Map<String, Set<String>> RequiredFields = GetRequiredFields();

	public User Requestor;
	public User Approver;
	public Asset Vehicle;
	public String Comments;
	public String Language;

	public VehicleTransferRequestEmailRenderer(User requestor, User approver, Asset vehicle, String comments, String language) {
		this.Requestor = requestor;
		this.Approver = approver;
		this.Vehicle = vehicle;
		this.Comments = comments;
		this.Language = language; 
	}

	public static void initialiseLanguage(Set<String> languageSet) {
		for (String language : languageSet) {
			Map<String, String> translatedLabels = getLabels(language, requiredLabels);
			
			templates.put(language, initialiseEmailTemplate(translatedLabels.get(subjectTemplateLabelName), translatedLabels.get(htmlTemplateLabelName), translatedLabels.get(textTemplateLabelName)));
			
			translatedLabelsCache.put(language, translatedLabels);

		}

		System.debug(translatedLabelsCache);
	}

	private static Map<String, String> getLabels(String language, List<String> labelNames) {
		String labelsAsJson = '';

		if (Test.isRunningTest()) {
			labelsAsJson = '{' + 
				'"Vehicle_Transfer_Request" : "Vehcile Transfer Request", ' +
				'"Vehicle_Transfer_Request_referencedLabels" : { ' +
				'}, ' +
				'"VehicleTransferRequestEmailTemplateHtml" : "\\u003Chtml\\u003E\\r\\n\\u003Cbody\\u003E\\r\\n\\u003Cbr /\\u003E\\r\\n    {!URL}\\r\\n    \\u003Cbr /\\u003E\\r\\n    {!$label.Stock_Search_Requesting_Dealer} \\u003Cbr /\\u003E\\r\\n    {!requestor.CompanyName} \\u003Cbr /\\u003E\\r\\n    \\u003Cbr /\\u003E\\r\\n    {!$label.Stock_Search_Sales_Exec} \\u003Cbr/\\u003E\\r\\n    {!requestor.LastName}, {!requestor.FirstName} \\u003Cbr /\\u003E\\r\\n    \\u003Cbr /\\u003E\\r\\n\\r\\n    {!Comments}\\r\\n\\u003C/body\\u003E\\r\\n\\u003C/html\\u003E", ' +
				'"VehicleTransferRequestEmailTemplateHtml_referencedLabels" : { ' +
				'	"Stock_Search_Requesting_Dealer" : "Requesting Dealer", ' +
				'	"Stock_Search_Sales_Exec" : "Sales Executive" ' +
				'}, ' +
				'"VehicleTransferRequestEmailTemplateText" : "{!URL}\\r\\n\\r\\n{!$label.Stock_Search_Requesting_Dealer}\\r\\n{!requestor.CompanyName}\\r\\n\\r\\n{!$label.Stock_Search_Sales_Exec}\\r\\n{!requestor.LastName}, {!requestor.FirstName}\\r\\n\\r\\n{!Comments}", ' +
				'"VehicleTransferRequestEmailTemplateText.referencedLabels" : { ' +
				'	"Stock_Search_Requesting_Dealer" : "Requesting Dealer", ' +
				'	"Stock_Search_Sales_Exec" : "Sales Executive" ' +
				'} ' +
			'}';
		}
		else {
			PageReference ref = Page.LabelRetriever;

			ref.getParameters().put('lang', language);
			ref.getParameters().put('labels', String.join(labelNames, ','));

			labelsAsJson = ref.getContent().toString();
		}

		System.debug(labelsAsJson);

		Map<String, Object> labels = (Map<String, Object>)JSON.deserializeUntyped(labelsAsJson);

		Map<String, String> result = getLabelsFromNestedResponse(labels);

		return result;
	}

	private static Map<String, String> getLabelsFromNestedResponse(Map<String, Object> labels) {
		Map<String, String> result = new Map<String, String>();

		for (String labelName : labels.keySet()) {
			if (labels.get(labelName) instanceOf String) {
				System.debug(labelName + ' is a label');
				result.put(labelName.toLowerCase(), String.valueOf(labels.get(labelName)));
			}
			else if (labels.get(labelName) instanceOf Map<String, Object>) {
				System.debug(labelName + ' has children');
				result.putAll(getLabelsFromNestedResponse((Map<String, Object>)labels.get(labelName)));
			}
		}

		return result;
	}

	public EmailContent Render() {
		if (!templates.containsKey(this.Language)) {
			throw new LanguageNotInitialisedException();
		}

		EmailContent renderedEmail = templates.get(this.Language).Copy();

		for (String mergeField : getMergeFields(renderedEmail.Subject)) {
			renderedEmail.Subject = renderedEmail.Subject.replace(encodeMergeField(mergeField), getMergeFieldValue(mergeField));
		}

		Set<String> mergeFields = new Set<String>();
		mergeFields.addAll(getMergeFields(renderedEmail.TextContent));
		mergeFields.addAll(getMergeFields(renderedEmail.HtmlContent));

		for (String mergeField : mergeFields) {
			String mergeValue = getMergeFieldValue(mergeField);
			renderedEmail.TextContent = renderedEmail.TextContent.replace(encodeMergeField(mergeField), mergeValue);
			renderedEmail.HtmlContent = renderedEmail.HtmlContent.replace(encodeMergeField(mergeField), mergeValue.escapeHtml4());
		}

		return renderedEmail;
	}

	private static String encodeMergeField(String fieldName) {
		return '{!' + fieldName + '}';
	}

	private static Map<String, String> getTranslatedLabels(String language) {
		return translatedLabelsCache.get(language);
	}

	private static List<String> getMergeFields(String template) {
		List<String> mergeFields = new List<String>();

		Matcher mergeFieldMatcher = mergeFieldPattern.matcher(template);

		while (mergeFieldMatcher.find()) {
			mergeFields.add(mergeFieldMatcher.group(1));
		}

		return mergeFields;

	}

	public static Map<String, Set<String>> GetRequiredFields() {

		Set<String> mergeFields = new Set<String>();
		
		mergeFields.addAll(getMergeFields(defaultTemplate.Subject));
		mergeFields.addAll(getMergeFields(defaultTemplate.HtmlContent));
		mergeFields.addAll(getMergeFields(defaultTemplate.TextContent));

		Map<String, Set<String>> reqdFields = new Map<String, Set<String>>();

		for (String mergeField : mergeFields) {
			MergeFieldDetails details = new MergeFieldDetails(mergeField);

			if (mergeFieldObjectToSObjectMap.containsKey(details.ObjectName)) {
				String sObjectName = mergeFieldObjectToSObjectMap.get(details.ObjectName);
				if (reqdFields.containsKey(sObjectName)) {
					reqdFields.get(sObjectName).add(details.fieldName);
				}
				else {
					reqdFields.put(sObjectName, new Set<String>{details.fieldName});	
				}
			}
			
		}

		return reqdFields;
	}

	private String getTranslatedLabel(String labelName) {

		if (String.isBlank(labelName)) return '';

		Map<String, String> translatedLabels = getTranslatedLabels(this.Language);

		if (translatedLabels == null) {
			System.debug('Language [' + this.Language + '] not found');
			return '';
		}

		String lowerCaseName = labelName.toLowerCase();

		if (!translatedLabels.containsKey(lowerCaseName)) {
			System.debug('Label [' + lowerCaseName + '] not found');
			return '';
		}

		return translatedLabels.get(lowerCaseName);
	}

	private String getMergeFieldValue(String field) {
		if (String.isBlank(field)) return '';

		String fieldInLowerCase = field.toLowerCase();

		if (fieldInLowerCase == 'url') {
			return getURL();
		}

		if (fieldInLowerCase == 'comments') {
			return this.Comments;
		}

		MergeFieldDetails details = new MergeFieldDetails(field);

		if (details.ObjectName == '$label') {
			return getTranslatedLabel(details.fieldName);
		}
		else {
			SObject record = null;

			if (details.ObjectName == 'requestor') {
				record = this.Requestor;
			}
			else if (details.ObjectName == 'approver') {
				record = this.Approver;
			}
			else if (details.ObjectName == 'vehicle') {
				record = this.Vehicle;
			}
			else {
				return '';
			}

			String fieldValue = String.valueOf(record.get(details.FieldName));

			if (String.isBlank(fieldValue)) {
				fieldValue = '';
			}

			return fieldValue;
		}

	}

	private String getURL() {
        
        if (Approver == null) return '';
        
        String urlPrefix = URL.getSalesforceBaseUrl().toExternalForm();

        try {
            if (Approver.UserType == 'Partner' || Approver.UserType == 'Power Partner') {
            	String communityPrefix = Site.getBaseSecureUrl();
                if (!String.isBlank(communityPrefix)) {
                	urlPrefix = communityPrefix;
                }
            }
        }
        catch (Exception e) {
            System.debug(e);
            throw e;
        } 
        
        return urlPrefix + '/' + this.Vehicle.Id;
    }

    private static EmailContent initialiseEmailTemplate(String localSubject, String localHtml, String localText) {
    	EmailContent localTemplate = new EmailContent();
    	if (String.isBlank(localSubject)) {
    		localTemplate.Subject = defaultTemplate.Subject;
    	}
    	else {
    		localTemplate.Subject = localSubject;
    	}

    	if (String.isBlank(localHtml)) {
    		localTemplate.HtmlContent = defaultTemplate.HtmlContent;
    	}
    	else {
    		localTemplate.HtmlContent = localHtml;
    	}

    	if (String.isBlank(localText)) {
    		localTemplate.TextContent = defaultTemplate.TextContent;
    	}
    	else {
    		localTemplate.TextContent = localText;
    	}

    	return localTemplate;
    }

	public class EmailContent {
		public EmailContent() {

		}

		public EmailContent(String subject, String htmlContent, String textContent) {
			this.Subject = subject;
			this.HtmlContent = htmlContent;
			this.TextContent = textContent;
		}

		public EmailContent Copy() {
			return new EmailContent(this.Subject, this.HtmlContent, this.TextContent);
		}

		public String Subject {get;set;}
		public String HtmlContent {get;set;}
		public String TextContent {get;set;}
	}

	public class MergeFieldDetails {
		public String ObjectName;
		public String FieldName;

		public MergeFieldDetails(String mergeField) {
			String fieldInLowerCase = mergeField.toLowerCase();

			Integer seperatorPosition = fieldInLowerCase.indexOf('.');

			if (seperatorPosition < 1 || seperatorPosition + 1 >= fieldInLowerCase.length()) {
				this.ObjectName = null;
				this.FieldName = fieldInLowerCase;
			}

			this.ObjectName = fieldInLowerCase.left(seperatorPosition);
			this.FieldName = fieldInLowerCase.substring(seperatorPosition + 1);
		}
	}

	public class LanguageNotInitialisedException extends Exception {

	}


}