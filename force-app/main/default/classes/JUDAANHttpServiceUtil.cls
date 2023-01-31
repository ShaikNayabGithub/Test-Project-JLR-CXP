public class JUDAANHttpServiceUtil 
{
    public static Integer EXCEPTION_CODE = 900;
    public static Integer CALL_OUT_LIMIT_CODE = 901;
    public static Integer TIME_OUT = Integer.valueOf(system.label.c_timeout_proto_jaccs);
    
    public static HttpRequest getRequest(String endpoint, String method, String body)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setBody(body); 
        req.setTimeout(TIME_OUT);
        return req;
    }
    
    public static HttpRequest getRequest(String endpoint, String method)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method); 
        req.setTimeout(TIME_OUT);
        return req;
    }
    
    public static HttpResponse send(HttpRequest req)
    {
        if(allowCallout())
        {
            try
            {
                http h = new Http(); 
                return h.send(req);
            }
            catch(Exception ex)
            {
                return failResponse(ex.getMessage(), EXCEPTION_CODE);
            }
        }
        else
        {
            return failResponse('Limit Exceeded', CALL_OUT_LIMIT_CODE);
        }
    }
    
    public static HttpResponse failResponse(String message, Integer statusCode)
    {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(message);
        return res;
    }
    
    public static boolean allowCallout()
    {
        return Limits.getLimitCallouts() > Limits.getCallouts();
    }
    
     public static String readXMLResponse(XmlStreamReader reader, String sxmltag)
    {
      string retValue; // Read through the XML
      while(reader.hasNext())
      {
        if (reader.getEventType() == XmlTag.START_ELEMENT)
        {
          if (reader.getLocalName() == sxmltag) {
            reader.next();
            if (reader.getEventType() == XmlTag.characters)
            {
              retValue = reader.getText();
            }
          }
        }
        reader.next();
      }
      return retValue;
    } 
}