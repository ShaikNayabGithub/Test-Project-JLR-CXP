({
    doCountDown: function(cmp, helper) {

        var ret;
        var ret2;
        var ret3;
        var ret4;
        var day;
        var hour;
        var min;
        var sec;
        
       
        //debugger;
        var action = cmp.get("c.bringDate");
        action.setCallback(this, function(action) {
            if (action.getState() === "ERROR") {
                alert("Server Error: " + action.getError()[0].message);
            } else {
               
                ret = action.getReturnValue();
                //debugger;
                if(ret!=null && ret!= ""){
                    var div=ret.split("-");
                    var monthNames = ["january", "february", "march", "april", "may", "june","july", "august", "september", "october", "november", "december"];
                    var div2=div[2].split("T");
                    var div3=div2[1].split(".");
                    var entero=div[1]-1;
                    ret=monthNames[entero]+" "+div2[0]+", "+div[0]+" "+div3[0];
       
                    cmp.set("v.startDate",ret);
                    var initDate = new Date(ret);//document.getElementsByClassName("countdown-timer_a")[0].attributes[1].nodeValue);
                    var countdownTimer = document.getElementsByClassName("countdown-timer_a")[0];
                    var days = document.getElementsByClassName("countdown-timer__days_a")[0];
                    var hours = document.getElementsByClassName("countdown-timer__hours_a")[0];
                    var minutes = document.getElementsByClassName("countdown-timer__minutes_a")[0];
                    var seconds = document.getElementsByClassName("countdown-timer__seconds_a")[0];
                
                setInterval (function(){
                    //debugger;
                       /* if (ret > 0) {
                            //debugger;
                            day = Math.floor(ret / (1000 * 60 * 60 * 24));
                            ret2 = (ret / (1000 * 60 * 60 * 24)) - day;
    
                            hour = Math.floor(ret2 * 24);
                            ret3 = (ret2 * 24 - hour);
                            min = Math.floor(ret3 * 60);
                            ret4 = (ret3 * 60 - min);
                            sec = Math.floor(ret4 * 60);
    
                            cmp.set("v.day", day);
                            cmp.set("v.hour", hour);
                            cmp.set("v.min", min);
                            cmp.set("v.sec", sec);
    
                        } else {
                            debugger;
                            day = 0;
                            hour = 0;
                            min = 0;
                            sec = 0;
                            cmp.set("v.day", day);
                            cmp.set("v.hour", hour);
                            cmp.set("v.min", min);
                            cmp.set("v.sec", sec);
                        }
                        */
                    	
                        //ret=ret-1000;

            var difference = initDate - Date.parse(new Date());

            //check if date passed
            if(difference <= 0) {
                if(seconds != null && seconds.childNodes.length > 0)
                seconds.childNodes[0].innerHTML=0;
                if(minutes != null && seconds.childNodes.length > 0)
                minutes.childNodes[0].innerHTML=0;
                if(hours != null && seconds.childNodes.length > 0)
                hours.childNodes[0].innerHTML=0;
                if(days != null && seconds.childNodes.length > 0)
                days.childNodes[0].innerHTML=0;
            } else {
                //actual update
                if(seconds != null && seconds.childNodes.length > 0)
                seconds.childNodes[0].innerHTML=(Math.floor(difference / 1000) % 60);
                if(minutes != null && seconds.childNodes.length > 0)
                minutes.childNodes[0].innerHTML=(Math.floor(difference / 1000 / 60) % 60);
                if(hours != null && seconds.childNodes.length > 0)
                hours.childNodes[0].innerHTML=(Math.floor(difference / (1000 * 60 * 60)) % 24);
                if(days != null && seconds.childNodes.length > 0)
                days.childNodes[0].innerHTML=(Math.floor(difference / (1000 * 60 * 60 * 24)));
            }
                    
	},1000);      
                    }
				}
            
        });
        $A.enqueueAction(action);  
  
       
}
})