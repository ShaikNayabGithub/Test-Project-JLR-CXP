public class HttpRequestFactory {
    public HttpRequest BuildEmptyRequest(string soapAction, string endpoint)
    {
    	HttpRequest request = new HttpRequest();
		request.setMethod('POST');
		request.setHeader('Accept-Encoding','gzip,deflate');
		request.setHeader('Content-Type','text/xml;charset=UTF-8');
		request.setHeader('SOAPAction', soapAction);
		request.setHeader('User-Agent','Jakarta Commons-HttpClient/3.1');
		request.setTimeout(120000);
		request.setEndpoint(endpoint);
		return request;
    }
}