public class FileUpload_FileValidator {
    private static final Integer FILE_SIZE_LIMIT = 6000000;
    //private static final Integer FILE_SIZE_LIMIT = 300000;


    public void ValidateSize(Blob file, FileUpload_FileStatus fileStatus)
    {
        if(fileStatus.Status == ApexPages.Severity.ERROR) return;

        if(file.size() > FILE_SIZE_LIMIT) {
            fileStatus.Status = ApexPages.Severity.ERROR;
            fileStatus.Message = System.Label.File_Size_Error;
            return;
        }

        try {
            file.toString();
        }
        catch (StringException e)
        {
            fileStatus.Status = ApexPages.Severity.ERROR;
            fileStatus.Message = System.Label.File_Length_Error;
        }
    }

    public void ValidateExtension(String fileName, 
            FileUpload_BatchProcessor_FI batchProcessorFactory, FileUpload_FileStatus fileStatus)
    {
        if(fileStatus.Status == ApexPages.Severity.ERROR) return;

        Set<String> supportedFileTypes = batchProcessorFactory.GetSupportedFileFormats();
        String[] splitFileName = fileName.split('\\.');
        if(splitFileName.size() > 0 && supportedFileTypes.contains(splitFileName[splitFileName.size() - 1])) return;
        
        String formatsString = '';
        for(String supportedFileType : supportedFileTypes) {
            if(String.isNotEmpty(formatsString)) formatsString += ', ';
            formatsString += supportedFileType;
        }

        fileStatus.Status = ApexPages.Severity.ERROR;
        fileStatus.Message = String.format(System.Label.File_Extension_Error, new List<String> { formatsString });
    }
}