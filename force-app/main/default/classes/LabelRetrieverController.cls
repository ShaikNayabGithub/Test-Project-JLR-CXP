public with sharing class LabelRetrieverController {
	public final String Language {get;set;}
	public List<String> Labels {get;set;}
	public String FoundMergeFields {get;set;}
	public Integer MatchCount {get;set;}

	public String FindReferencesIn {get;
		set {
			FindReferencesIn = value;
			FindReferences();
		}
	}

	private static Pattern mergeFieldPattern = Pattern.compile('\\{\\!([^\\}]+)\\}'); //'
	
	public Integer LabelCount {
		get {
			return this.Labels.size();
		}
	}

	private Pattern acceptableLabelChars = Pattern.compile('^[a-zA-Z][a-zA-Z0-9\\_]*$');

	public LabelRetrieverController() {
	
		this.Language = ApexPages.currentPage().getParameters().get('lang');

		String requestedLabels = ApexPages.currentPage().getParameters().get('labels');

		Set<String> foundLabels = new Set<String>();

		if (!String.isBlank(requestedLabels)) {
			for (String requestedLabel : requestedLabels.split('\\,')) {
				Matcher matcher = acceptableLabelChars.matcher(requestedLabel);
				if (matcher.matches()) {
					if (!foundLabels.contains(requestedLabel)) {
						foundLabels.add(requestedLabel);
					}
				}
			}
		}

		this.Labels = new List<String>(foundLabels);

	}

	public void FindReferences() {

		this.Labels = new List<String>();

		if (String.isBlank(FindReferencesIn)) {
			return;
		}

		List<String> mergeFields = new List<String>();

		Matcher mergeFieldMatcher = mergeFieldPattern.matcher(FindReferencesIn);

		MatchCount = 0;
		while (mergeFieldMatcher.find()) {
			++MatchCount;
			mergeFields.add(mergeFieldMatcher.group(1));
		}

		FoundMergeFields = String.join(mergeFields, ', ');

		Set<String> foundLabels = new Set<String>();

		for (String mergeField : mergeFields) {
			if (mergeField.toLowerCase().StartsWith('$label.') && mergeField.length() > 7) {
				String labelName = mergeField.substring(7);
				if (!foundLabels.contains(labelName)) {
					foundLabels.add(labelName);
				}
			}
		}

		Labels.addAll(foundLabels);
	}
}