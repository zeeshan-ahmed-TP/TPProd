({
    myAction : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            'url': 'https://conductor.congamerge.com?sessionId={!$Api.Session_ID} \
&serverUrl={!$Api.Partner_Server_URL_370} \
&URLFieldName=Formula_Conga_Tech__c \
&QueryID=a2z7i000001xs0jAAA?'
        });
        urlEvent.fire();	
    }
})