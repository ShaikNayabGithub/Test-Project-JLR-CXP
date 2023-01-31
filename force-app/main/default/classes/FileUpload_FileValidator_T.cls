@isTest
public class FileUpload_FileValidator_T {
    static testMethod void ValidateSize_DoesNotChangeMessage_GivenValidFile()
	{
        FileUpload_FileValidator validator = new FileUpload_FileValidator();

        String inputString = 't1';
        String startMessage = 'm1';

        Blob inputFile = Blob.valueOf(inputString);
        FileUpload_FileStatus fileStatus = new FileUpload_FileStatus();
        fileStatus.Message = startMessage;


        validator.ValidateSize(inputFile, fileStatus);


        System.assertEquals(startMessage, fileStatus.Message);
    }

    static testMethod void ValidateSize_DoesNotChangeStatus_GivenValidFile()
	{
        FileUpload_FileValidator validator = new FileUpload_FileValidator();

        String inputString = 't1';

        Blob inputFile = Blob.valueOf(inputString);
        FileUpload_FileStatus fileStatus = new FileUpload_FileStatus();
        fileStatus.Status = ApexPages.Severity.CONFIRM;


        validator.ValidateSize(inputFile, fileStatus);


        System.assertEquals(ApexPages.Severity.CONFIRM, fileStatus.Status);
    }


    static testMethod void ValidateExtension_DoesNotSetStatus_GivenAcceptedFileExtension()
	{
        FileUpload_FileValidator validator = new FileUpload_FileValidator();

        String fileExtension1 = 'e1';
        String fileName = 'n1.' + fileExtension1;

        FileUpload_FileStatus fileStatus = new FileUpload_FileStatus();
        fileStatus.Status = ApexPages.Severity.CONFIRM;
        FileUpload_BatchProcessor_FI batchProcessorFactory = new Dummy_BatchProcessor_F(new Set<String> { 
                fileExtension1 });


        validator.ValidateExtension(fileName, batchProcessorFactory, fileStatus);


        System.assertEquals(ApexPages.Severity.CONFIRM, fileStatus.Status);
    }

    static testMethod void ValidateExtension_SetStatusToError_GivenUnacceptedFileExtension()
	{
        FileUpload_FileValidator validator = new FileUpload_FileValidator();

        String fileExtension1 = 'e1';
        String fileExtension2 = 'e2';
        String fileName = 'n1.' + fileExtension1;

        FileUpload_FileStatus fileStatus = new FileUpload_FileStatus();
        fileStatus.Status = ApexPages.Severity.CONFIRM;
        FileUpload_BatchProcessor_FI batchProcessorFactory = new Dummy_BatchProcessor_F(new Set<String> { 
                fileExtension2 });


        validator.ValidateExtension(fileName, batchProcessorFactory, fileStatus);


        System.assertEquals(ApexPages.Severity.Error, fileStatus.Status);
    }

    static testMethod void ValidateExtension_SetStatusMessage_GivenUnacceptedFileExtension()
	{
        FileUpload_FileValidator validator = new FileUpload_FileValidator();

        String fileExtension1 = 'e1';
        String fileExtension2 = 'e2';
        String fileName = 'n1.' + fileExtension1;

        FileUpload_FileStatus fileStatus = new FileUpload_FileStatus();
        fileStatus.Status = ApexPages.Severity.CONFIRM;
        FileUpload_BatchProcessor_FI batchProcessorFactory = new Dummy_BatchProcessor_F(new Set<String> { 
                fileExtension2 });


        validator.ValidateExtension(fileName, batchProcessorFactory, fileStatus);

        String expectedMessgage = String.format(System.Label.File_Extension_Error, new List<String> { fileExtension2 });
        System.assertEquals(ApexPages.Severity.Error, fileStatus.Status);
    }

    static testMethod void ValidateExtension_SetStatusMessage_GivenUnacceptedFileExtensionAndMultipleAccepted()
	{
        FileUpload_FileValidator validator = new FileUpload_FileValidator();

        String fileExtension1 = 'e1';
        String fileExtension2 = 'e2';
        String fileExtension3 = 'e3';
        String fileName = 'n1.' + fileExtension1;

        FileUpload_FileStatus fileStatus = new FileUpload_FileStatus();
        fileStatus.Status = ApexPages.Severity.CONFIRM;
        FileUpload_BatchProcessor_FI batchProcessorFactory = new Dummy_BatchProcessor_F(new Set<String> { 
                fileExtension2, fileExtension3 });


        validator.ValidateExtension(fileName, batchProcessorFactory, fileStatus);

        String expectedMessgage = String.format(System.Label.File_Extension_Error, new List<String> { 
                (fileExtension2 + ', ' + fileExtension3) });
        System.assertEquals(expectedMessgage, fileStatus.Message);
    }


    private class Dummy_BatchProcessor_F implements FileUpload_BatchProcessor_FI
    {
        private final Set<String> supportedFileFormats;

        public Dummy_BatchProcessor_F(Set<String> supportedFileFormats) {
            this.supportedFileFormats = supportedFileFormats;
        }

        public String GetLabel() { throw new TypeException(); }
	    public String GetName() { throw new TypeException(); }
        public Document GetTemplate() { throw new TypeException(); }
	    public Database.Batchable<String> Create(Id attachmentId, Id apexJobId) { throw new TypeException(); }

	    public Set<String> GetSupportedFileFormats() 
        {
             return this.supportedFileFormats; 
        }
    }
}