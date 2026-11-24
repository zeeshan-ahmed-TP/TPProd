public class FiveStreetHandler {
    @future (callout=true)
    public static void addUsertoFS(String name, String email, string phone, String salesPerson, String Id, String licenseId){
        String endPointURL = Label.Five_Street_URL + '?access_token=' + Label.FiveStreetToken;
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeFieldName('siebel_agents');
        jsonGen.writeStartArray();
        jsonGen.writeStartObject();
        jsonGen.writeStringField('name',name);
        jsonGen.writeStringField('email',email);
        jsonGen.writeStringField('phone',phone);
        jsonGen.writeStringField('move_salesperson',salesPerson);
        jsonGen.writeStringField('siebel_id',Id);
        jsonGen.writeEndObject();
        jsonGen.writeEndArray();
        jsonGen.writeEndObject();
        String res = sendApiCall(endPointURL, 'POST', jsonGen.getAsString());
        if(res != null){Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res);
            if(result.containsKey('detail')){User_Licensing__c license = new User_Licensing__c(id=licenseId,Status__c='Failed',Status_Code__c=result.get('detail').toString());update license;} 
            else if(result.containsKey('siebel_agents')){User_Licensing__c license = new User_Licensing__c(id=licenseId,Status__c='Fulfilled');update license;}
        }
    }
    
    @future (callout=true)
    public static void getUserFromFS(String userEmail,String licenseId){
        String endPointURL = Label.Five_Street_URL + '?access_token=' + Label.FiveStreetToken + '&siebel_id=' + licenseId;
        String res = sendApiCall(endPointURL, 'GET', null);
        if(res != null){Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res);List<Map<String, Object>> data = new List<Map<String, Object>>();for (Object instance : (List<Object>)response.get('siebel_agents'))data.add((Map<String, Object>)instance);
            for(Map<String, Object> item : data){for(String key : item.KeySet()){
                if(Key.equals('id')){
                    String delEndPointURL = Label.Five_Street_URL + '/' + (String)item.get('id') + '?access_token=' +Label.FiveStreetToken;String delRes = sendApiCall(delEndPointURL, 'DELETE', null);
                    break;
                        //else{User_Licensing__c license = new User_Licensing__c(id=licenseId,Status__c='Failed',Status_Code__c = 'User not Found in the System');update license;}
                    }
                }
            }
        }
    }
    
    public static String sendApiCall(String endPointURL,String method,String body){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Length', '0');
        req.setEndPoint(endPointURL);
        if(body != null)
        	req.setBody(body);
        req.setMethod(method);
        req.setTimeout(60000);
       
        HTTP http = new HTTP();          
        if(Test.isRunningTest()){
            return null;
        }else{
            res = http.send(req);            
        }
        System.debug('Response Status : '+res.getStatus());
        System.debug('Response Status Code : '+res.getStatusCode());
        System.debug('Response Body : '+res.getBody());
       
        return String.ValueOf(res.getBody());
    }
}