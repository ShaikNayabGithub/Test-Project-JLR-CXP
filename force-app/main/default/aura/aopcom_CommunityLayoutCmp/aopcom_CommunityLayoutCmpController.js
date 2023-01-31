({

	doInit :  function(component, event, helper) {
        window.scrollTo(0,0);
        
        
    	var result;
        var action = component.get("c.initial");
        //debugger;
        //Start GetCookie
        var c_value = document.cookie;
        var c_start = c_value.indexOf("resHeader=");
        if (c_start == -1 || window.location.href.indexOf("book-event")>-1 || window.location.href.indexOf("edit-profile")>-1){
            c_value = null;
        }                                						        					
        else
        {
            c_start = c_value.indexOf("=", c_start) + 1;
            var c_end = c_value.indexOf(";", c_start);
            if (c_end == -1)
            {
                c_end = c_value.length;
            }
            c_value = unescape(c_value.substring(c_start,c_end));
        }
        //End GetCookie
        if(c_value ==null){
            action.setCallback(this, function(action) {
                var state = action.getState();
                if(state == "ERROR"){
                    //debugger;
                    console.log("Server Error: " + action.getError()[0].message);
                }else if (state === "SUCCESS") {
                   // debugger;
                    result=action.getReturnValue();
                    //Start setCookie
                    var exdate=new Date();
                    //cookie expires after one day
        			exdate.setDate(exdate.getDate() + 1);
        			c_value=escape(result[result.length-1].Name) + ((1==null) ? "" : "; expires="+exdate.toUTCString());
       				document.cookie="resHeader=" + c_value;
                    //End setCookie
                    console.log(window.location.href);
                    var div=result[result.length-1].Name.split('#');
                    component.set("v.UserName_label", div[0]);
                    component.set("v.Context", div[1]);
                    component.set("v.AWSUrl",div[2]);
                    document.cookie = "AWSUrl="+div[2];
                    
                    if(div[div.length-1].indexOf('false')>-1){ 
                       
                        //Save Community Context
                        //debugger;
                        component.set("v.communityContext",div[div.length-2]);
                        document.cookie = "communityPath="+div[div.length-2];
                        
                        if(result[result.length-1].Name.indexOf("myprofile")>-1){
                            component.set("v.myProfileTab", true);
                            if(window.location.href.indexOf("my-profile")>-1){
                        		component.set("v.selectedMyProf", "main-nav__link--current");
                    		}
                        }else if(window.location.href.indexOf("my-profile")>-1){
                            component.set("v.available",false);
                        }
                        if(result[result.length-1].Name.indexOf("myevent")>-1){
                            component.set("v.myEventTab", true);
                            if(window.location.href.indexOf("my-event")>-1){
                                component.set("v.selectedMyEvent", "main-nav__link--current");
                            }
                        }else if(window.location.href.indexOf("my-event")>-1){
                            component.set("v.available", false);
                        }
                        if(result[result.length-1].Name.indexOf("bookevent")>-1){
                            component.set("v.bookEventTab",true);
                            if(window.location.href.indexOf("book-event")>-1){
                                component.set("v.selectedBook", "main-nav__link--current");
                            }
                        }else if(window.location.href.indexOf("book-event")>-1){
                            component.set("v.available",false);
                        }
                        if(result[result.length-1].Name.indexOf("amendbooking")==-1){
                            document.getElementById("amend").innerHTML="";        
                            //component.set("v.amendbooking",true)
                        }
                            
                        component.set("v.SpotifyUrl",div[3]);
                        delete result[result.length-1];
                        component.set("v.countries",result);
                    }else{
                        component.set("v.available",false);
                    }
                    
                 }
        });
            $A.enqueueAction(action);  
        }else{
            //Processed if header is stored previously
        	result=c_value;
            console.log(window.location.href);
            var div=result.split('#');
            component.set("v.UserName_label", div[0]);
            component.set("v.Context", div[1]);
            component.set("v.AWSUrl",div[2]);
            document.cookie = "AWSUrl="+div[2];
            if(div[div.length-1].indexOf('false')>-1){
                
				//Save Community Context
				//debugger;
                component.set("v.communityContext",div[div.length-2]);
                document.cookie = "communityPath="+div[div.length-2];
                
                if(result.indexOf("myprofile")>-1){
                    component.set("v.myProfileTab", true);
                    if(window.location.href.indexOf("my-profile")>-1){
                        component.set("v.selectedMyProf", "main-nav__link--current");
                    }
                }else if(window.location.href.indexOf("my-profile")>-1){
                    component.set("v.available",false);
                }
                if(result.indexOf("myevent")>-1){
                    component.set("v.myEventTab", true);
                    if(window.location.href.indexOf("my-event")>-1){
                        component.set("v.selectedMyEvent", "main-nav__link--current");
                    }
                }else if(window.location.href.indexOf("my-event")>-1){
                    component.set("v.available", false);
                }
                if(result.indexOf("bookevent")>-1){
                    component.set("v.bookEventTab",true);
                    if(window.location.href.indexOf("book-event")>-1){
                        component.set("v.selectedBook", "main-nav__link--current");
                    }
                }else if(window.location.href.indexOf("book-event")>-1){
                    component.set("v.available",false);
                }
                
                if(window.location.href.indexOf("driving-tips")>-1){
                        component.set("v.selectedDriving", "main-nav__link--current");
                }
                if(window.location.href.indexOf("faq")>-1){
                        component.set("v.selectedFaq", "main-nav__link--current");
                }
                if(result.indexOf("amendbooking")==-1){
                    document.getElementById("amend").innerHTML="";        
                    //component.set("v.amendbooking",true)
                }

                component.set("v.SpotifyUrl",div[3]);
                
                action.setCallback(this, function(action) {
                    var state = action.getState();
                    if(state == "ERROR"){
                        //debugger;
                        console.log("Server Error: " + action.getError()[0].message);
                    }else if (state === "SUCCESS") {
                       // debugger;
                        result=action.getReturnValue();
                        //debugger;
                        delete result[result.length-1];
                        component.set("v.countries",result);
                       
                        
                     }
        		});
            	$A.enqueueAction(action); 
                
            }else{
                component.set("v.available",false);
            }
        }
        //debugger;
        
        
	    var action2 = component.get("c.loadCheckFront");
        //debugger;
        action2.setCallback(this, function(action2) {
            var state = action2.getState();
            if(state == "ERROR"){
                alert("Server Error: " + action2.getError()[0].message);
			}else if (state === "SUCCESS") {
 				//debugger;
                result=action2.getReturnValue();
				var div=result.split('#');
                
                window.setTimeout(function(){
                    if(document.getElementById('CHECKFRONT_WIDGET_01')!=null){
                        //debugger;
                        new CHECKFRONT.Widget ({
                            host: div[1],
                            target: 'CHECKFRONT_WIDGET_01',
                            category_id: div[2],
                            tid:div[0],
                            lang_id:div[3],
                            provider: 'droplet'
                        }).render();
                    }
                    if(document.getElementById('CHECKFRONT_LINK')!=null){
                        document.getElementById('CHECKFRONT_LINK').innerHTML='<a href="https://'+div[1]+'/reserve/" style="font-size: 16px">Continue to Secure Booking System &raquo;</a>';
                    }
                },1250);
			}        
        });
        $A.enqueueAction(action2);	
        
        
        //Workaround in order to set width of content wrapper dynamically
        document.getElementsByClassName("cCenterPanel")[0].style.maxWidth="100%";
        //Workaround in order to reload main.js  dynamically when a new page load
        //debugger;
        
        window.setTimeout(function(){
            //debugger;
            var head= document.getElementsByTagName('head')[0];
            var scripts=document.getElementsByTagName('script');
            var badName;
            var badLink;
            for (var i = 0; i < scripts.length; i++) {
                thisLinkUrl=scripts[i].src;
                badName='/main.js';
                if (thisLinkUrl != "" && thisLinkUrl.substring( thisLinkUrl.length - badName.length, thisLinkUrl.length ) === badName) {
                    badLink = scripts[i];
                    badLink.parentNode.removeChild(badLink);
                }
             }
             
            var script= document.createElement('script');
            script.type= 'text/javascript';
            script.src= '/TAOPTAsia/resource/main_js/main.js';
            head.appendChild(script);
        },450);
        
        var head= document.getElementsByTagName('head')[0];
        var link= document.createElement('link');
   		link.type= 'image/x-icon';
   		link.href= '/TAOPTAsia/resource/favicon';
        link.rel= 'icon'
   		head.appendChild(link);
        
        //Add js class manually to HTML tag
        document.getElementsByTagName('html')[0].className += ' js';
        
        
	},
    //getPhoneMail : function (component, event, helper){
        //console.log("hola");
    //},
    
    getCookie : function(c_name){
        				
        var c_value = document.cookie;
        var c_start = c_value.indexOf(c_name + "=");
        if (c_start == -1){
            c_value = null;
        }                                						        					
        else
        {
            c_start = c_value.indexOf("=", c_start) + 1;
            var c_end = c_value.indexOf(";", c_start);
            if (c_end == -1)
            {
                c_end = c_value.length;
            }
            c_value = unescape(c_value.substring(c_start,c_end));
        }
		return c_value;
	},
    
        setCookie : function(c_name,value,exdays)
    {
        var exdate=new Date();
        exdate.setDate(exdate.getDate() + exdays);
        var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
        document.cookie=c_name + "=" + c_value;
    },
    
    
    logout : function(component, event, helper) {
		//Delete header cookie before logout
		//debugger;
        var c_value = document.cookie;
        var c_start = c_value.indexOf("resHeader=");
        if (c_start != -1){
            var c_end = c_value.indexOf(";", c_start);
            if (c_end == -1)
            {
                c_end = c_value.length;
            }
            document.cookie="resHeader=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
            document.cookie="communityPath=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
            document.cookie="AWSUrl=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
        }                                						        					
        
        window.location.href="/TAOPTAsia/secur/logout.jsp";
        
        //Logout
        /*var action = component.get("c.logout");
        
        action.setCallback(this, function(action) {
            if (action.getState() === "ERROR") {
                alert("Server Error: " + action.getError()[0].message);
            }  
		});
        $A.enqueueAction(action);  */
    }

    
})