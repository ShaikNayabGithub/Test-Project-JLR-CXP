global with sharing class CustomLoginController {
    global String username{get;set;}
    global String password{get;set;}
    global CustomLoginController () {}
    global PageReference forwardToCustomAuthPage() {
        return new PageReference( '/CustomLogin');
    }
    global PageReference login() {
        return Site.login(username, password, null);
    }
   /* global remember(){}*/
}