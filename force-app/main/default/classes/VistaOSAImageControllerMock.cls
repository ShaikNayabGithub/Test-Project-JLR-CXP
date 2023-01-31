@isTest
global class VistaOSAImageControllerMock implements HttpCalloutMock {
    public boolean isvalid;
    public VistaOSAImageControllerMock(boolean isvalid){
        this.isvalid = isvalid;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody('{}');
        if(isvalid){
            res.setStatusCode(200);
        }else{
            res.setStatusCode(500);    
        }
        return res;
    }
}