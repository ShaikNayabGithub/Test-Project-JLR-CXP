public class FileUpload_BatchProcessorFRetriever {
	private static final String INTERFACE_NAME = 'FileUpload_BatchProcessor_FI';
	private static final Set<String> CLASSES_NOT_TO_RETRIEVE = new Set<String> {
		INTERFACE_NAME, 'FileUpload_Controller'
	};


	public Map<String, FileUpload_BatchProcessor_FI> RetrieveFactories()
	{
		Map<String, FileUpload_BatchProcessor_FI> factoryMap = new Map<String, FileUpload_BatchProcessor_FI>();

		ApexClass[] batchFactoryClasses = (ApexClass[])[FIND :INTERFACE_NAME IN ALL FIELDS
                RETURNING ApexClass(Id, Name WHERE Name NOT IN: CLASSES_NOT_TO_RETRIEVE)][0];
        Map<Id, ApexClass> batchFactoryClassMap = new Map<Id, ApexClass>(batchFactoryClasses);

       SetupEntityAccess[] classAccessSettings = [SELECT Id, SetupEntityId FROM SetupEntityAccess WHERE
			    SetupEntityId IN: batchFactoryClasses AND
			    ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment
			    WHERE AssigneeId = :UserInfo.getUserId())];

		for(SetupEntityAccess classAccess : classAccessSettings) {
			ApexClass apexClass = batchFactoryClassMap.get(classAccess.SetupEntityId);
			if(apexClass == null) continue;

			Type apexType = Type.forName(apexClass.Name);
			Object classInstance = apexType.newInstance();

			if(classInstance instanceof FileUpload_BatchProcessor_FI) {
				FileUpload_BatchProcessor_FI batchProcessorFactory = (FileUpload_BatchProcessor_FI)classInstance;
				factoryMap.put(batchProcessorFactory.getName(), batchProcessorFactory);
			}
		}

		return factoryMap;
	}
}