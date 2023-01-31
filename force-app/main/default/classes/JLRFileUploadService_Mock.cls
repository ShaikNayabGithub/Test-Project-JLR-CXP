@isTest
global class JLRFileUploadService_Mock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
        JLRFileUploadService.UploadFilesToSFResponse_element  response_x = 
            new JLRFileUploadService.UploadFilesToSFResponse_element();
        response_x.UploadFilesToSFResult = 'Test';
        response.put('response_x', response_x); 
   }
}