public class TPCRMRestHandler {
    
    public static String endPointURL = Label.FB_Leads_URL + 'TpxFulfillment/Tpo';
    private static final Map<String, String> AccountTypes = new Map<String, String>{
        'Agent' => '1',
        'Broker' => '3', 
        'Team' => '4'
    };
    @future (callout=true)    
    public static void createAccount(String recordType, Decimal Quantity, String firstName,String lastName, String email, String AccountName,string licenseID){
        string accountID = GuidUtil.NewGuid();
        string ownerID = GuidUtil.NewGuid();
        string subscriptionID = GuidUtil.NewGuid();
        string loginName = UserInfo.UserLogin(firstName,lastName);
        String requestBody;
        HttpResponse res;
        if(String.isNotBlank(loginName)){
            res = sendApiCall(endPointURL + '?login_name=' + EncodingUtil.urlEncode(loginName, 'UTF-8'), 'GET', null);
            if(res != null && res.getStatusCode() == 200){
                Map<String, Object> responseMap =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                system.debug('Check login Name: ' + responseMap.get('login_name'));
                if(String.ValueOf(responseMap.get('login_name')) != null){
                 	loginName = UserInfo.NewUserLogin(firstName,lastName,licenseID);   
                }
            }
        }
        
        // ===== Build Payload =====
        RequestWrapper payload = new RequestWrapper();

        payload.account_id = accountID;
        payload.account_status_id = '2';
        payload.account_type_id = AccountTypes.get(recordType);
        payload.brand_id = '1';
        payload.is_customer_account = '1';
        payload.bl_company_name = AccountName;
        payload.bl_suite = '';
        payload.bl_house = '';
        payload.bl_street = '';
        payload.bl_city = '';
        payload.bl_state = '';
        payload.bl_country = '';
        payload.bl_zip = ''; 

        payload.user_id = ownerID;
        payload.user_status_id = '1';
        payload.timezone = '1';
        payload.login_name = loginName;
        if(firstName != null)
            payload.first_name = firstName;
        payload.last_name = lastName;
        payload.e_mail = email;
        payload.birth_date = '1980-01-01';
        payload.gender = '1';

        // ===== Subscription =====
        License lic1 = new License();
        lic1.license_type_id = '1';
        lic1.license_count = String.valueOf(Quantity);

        License lic2 = new License();
        lic2.license_type_id = '15';
        lic2.license_count = String.valueOf(Quantity);

        Subscription sub = new Subscription();
        sub.subscription_id = subscriptionID;
        sub.subscription_status_id = '1';
        sub.billing_day = '15';
        sub.licenses = new List<License>{ lic1, lic2 };

        payload.subscriptions = new List<Subscription>{ sub };

        // ===== Serialize =====
        requestBody = JSON.serialize(payload);
        res = sendApiCall(endPointURL, 'POST', requestBody);
        Boolean isSuccess = res != null && res.getStatusCode() == 200 && res.getStatus() == 'OK';
        String passwordResetLink;
        if(isSuccess){
            try {
            	Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            	passwordResetLink = (String) responseMap.get('password_setup_link');
                System.debug('passwordResetLink: ' + passwordResetLink);
            } catch (Exception jsonEx) {
                System.debug('JSON parse error: ' + jsonEx.getMessage());
            }
        }
        User_Licensing__c uLicense = new User_Licensing__c(
            Id = licenseID,
            Status__c = isSuccess ? 'Fulfilled' : 'Failed',
            TPAccountId__c = accountID,
            TPUserID__c = ownerID,
            TPSubscriptionID__c = subscriptionID,
            Username__c = loginName,
            Status_Code__c = Test.isRunningTest()? null : res.getStatusCode() + ' ' + res.getBody(),
            Password_Reset_Link__c = passwordResetLink
        );
        update uLicense;
    }
    
    @future (callout=true)
    public static void updateAccount(String licenseStatus, String recordType, Decimal Quantity, String firstName,String lastName, String email, String AccountName,string licenseID,string accountID, string ownerID, string subscriptionID, string loginName){
        // ===== Build Payload =====
        RequestWrapper payload = new RequestWrapper();

        payload.account_id = accountID;
        payload.account_status_id = licenseStatus == 'Closed' || licenseStatus == 'Canceled' || licenseStatus == 'Expired' ? '3' : '2';
        payload.account_type_id = AccountTypes.get(recordType);
        payload.brand_id = '1';
        payload.is_customer_account = '1';
        payload.bl_company_name = AccountName;
        payload.bl_suite = '';
        payload.bl_house = '';
        payload.bl_street = '';
        payload.bl_city = '';
        payload.bl_state = '';
        payload.bl_country = '';
        payload.bl_zip = ''; 
        payload.birth_date = '1980-01-01';
        payload.gender = '1';
        
        payload.user_id = ownerID;
        String userStatus;
        if(licenseStatus == 'Suspended' || licenseStatus == 'Expired'){
            userStatus = '2';
        } else if(licenseStatus == 'Closed' || licenseStatus == 'Canceled'){
            userStatus = '4';
        }else{
            userStatus = '1';
        }
        payload.user_status_id = userStatus;
        payload.timezone = '1';
        payload.login_name = loginName;
        if(firstName != null)
            payload.first_name = firstName;
        payload.last_name = lastName;
        payload.e_mail = email;
        
        // ===== Serialize =====
        String requestBody = JSON.serialize(payload);
        HttpResponse res = sendApiCall(endPointURL + '/' + accountID, 'PUT', requestBody);
        Boolean isSuccess = res != null && res.getStatusCode() == 200 && res.getStatus() == 'OK';
        User_Licensing__c uLicense = new User_Licensing__c(
            Id = licenseID,
            Status__c = isSuccess ? licenseStatus : 'Failed',
            Status_Code__c = res.getStatusCode() + ' ' + res.getBody()
        );
        update uLicense;
    }
    
    @future (callout=true)
    public static void addSubscription(String licenseId, Decimal Quantity,string AccountID, string ownerID, string subscriptionID, String licenseType){
        SubscriptionRequestWrapper payload = new SubscriptionRequestWrapper();
        String requestBody;
        HttpResponse res;
        
        // ===== Subscription =====
        License lic1 = new License();
        lic1.license_type_id = licenseType;
        lic1.license_count = String.valueOf(Quantity);

        Subscription sub = new Subscription();
        sub.account_id = AccountID;
        sub.owner_id = ownerID;
        sub.subscription_id = subscriptionID;
        sub.subscription_status_id = '1';
        sub.billing_day = '15';
        sub.licenses = new List<License>{ lic1 };

        payload.subscriptions = new List<Subscription>{ sub };
        // ===== Serialize =====
        requestBody = JSON.serialize(payload);
        res = sendApiCall(endPointURL + '/Subscriptions', 'POST', requestBody);
        Boolean isSuccess = res != null && res.getStatusCode() == 200 && res.getStatus() == 'OK';
        if(isSuccess){
            Database.SaveResult sr;
            if(licenseType == '34'){
                Social_Connect_License__e scAssignmentEvent = new Social_Connect_License__e(
                    License_Id__c = licenseId,
                    Subscription_Id__c = subscriptionID);
                sr = EventBus.publish(scAssignmentEvent);   
            }else if(licenseType == '35'){
                HomeIntel_License__e hmIntAssignmentEvent = new HomeIntel_License__e(
                    License_Id__c = licenseId,
                    Subscription_Id__c = subscriptionID);
                sr = EventBus.publish(hmIntAssignmentEvent);
            }
            
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
        }
    }
    
    @future (callout=true)
    public static void addSubscriptionWithLicense(String licenseId, Decimal Quantity,string AccountID, string ownerID, string subscriptionID, String licenseType){
        SubscriptionRequestWrapper payload = new SubscriptionRequestWrapper();
        String requestBody;
        HttpResponse res;
        
        // ===== Subscription =====
        License lic1 = new License();
        lic1.license_type_id = licenseType;
        lic1.license_count = String.valueOf(Quantity);
        
        LicenseAssignment licAssign = new LicenseAssignment();
        licAssign.license_type_id = licenseType;
        licAssign.user_id = ownerID;

        Subscription sub = new Subscription();
        sub.account_id = AccountID;
        sub.owner_id = ownerID;
        sub.subscription_id = subscriptionID;
        sub.subscription_status_id = '1';
        sub.billing_day = '15';
        sub.licenses = new List<License>{ lic1 };
        sub.license_assignments = new List<LicenseAssignment> { licAssign };

        payload.subscriptions = new List<Subscription>{ sub };
        // ===== Serialize =====
        requestBody = JSON.serialize(payload);
        Integer chunkSize = 200;
        
        for (Integer i = 0; i < requestBody.length(); i += chunkSize) {
            Integer endIndex = Math.min(i + chunkSize, requestBody.length());
            System.debug('PAYLOAD [' + i + '-' + endIndex + ']: ' +
                         requestBody.substring(i, endIndex));
        }
        System.debug('Payload: ' + requestBody);
        res = sendApiCall(endPointURL + '/Subscriptions', 'POST', requestBody);
        Boolean isSuccess = res != null && res.getStatusCode() == 200 && res.getStatus() == 'OK';
        User_Licensing__c uLicense = new User_Licensing__c(
            Id = licenseID,
            Status__c = isSuccess ? 'Fulfilled' : 'Failed',
            Status_Code__c = res.getStatusCode() + ' ' + res.getBody(),
            TPAccountId__c = AccountID,
            TPUserID__c = ownerID,
            TPSubscriptionID__c = subscriptionID
        );
        update uLicense;
    }
    
    @future (callout=true)
    public static void subscribeHVPostalCode(string ownerID, String ItemID, Decimal Quantity, Decimal cost){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Length', '0');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(Label.ML_HV_URL + 'Services/LeadRouting/Subscribe');
        req.setHeader('x-ml-timestamp', Datetime.now().formatGMT('yyyyMMddHHmmss'));
        Blob inputBlob = Blob.valueOf('TopProducer ' + Label.HV_Access_Key + ' x-ml-timestamp:'+Datetime.now().formatGMT('yyyyMMddHHmmss'));
        Blob hashBlob = Crypto.generateDigest('MD5', inputBlob);
        
        // Convert to hexadecimal string
        String md5Hash = EncodingUtil.convertToHex(hashBlob);
        req.setHeader('ml-auth','client=TopProducer&systemaccesskey=' + Label.HV_Access_Key + '&signature=' + md5Hash);
        req.setMethod('POST');
        req.setTimeout(60000);
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        // ExternalPartnerId
        jsonGen.writeStringField('ExternalPartnerId', ownerID);
        // Items array
        jsonGen.writeFieldName('Items');
        jsonGen.writeStartArray();
        // Item 1
        jsonGen.writeStartObject();
        jsonGen.writeNumberField('ItemId', Integer.valueOf(ItemID));
        jsonGen.writeStringField('ItemType', 'HV');
        jsonGen.writeNumberField('Quantity', Integer.valueOf(Quantity));
        jsonGen.writeNumberField('Cost', Integer.valueOf(cost));
        jsonGen.writeEndObject();
        jsonGen.writeEndArray();
		jsonGen.writeEndObject();

		String payload = jsonGen.getAsString();
       	req.setBody(payload);
        HTTP http = new HTTP();          
        
        res = http.send(req);            
        
        System.debug('Response Status : '+res.getStatus());
        System.debug('Response Status Code : '+res.getStatusCode());
        System.debug('Response Body : '+res.getBody());
        String responseBody = res.getBody();

        Integer chunkSize = 200;
        
        for (Integer i = 0; i < responseBody.length(); i += chunkSize) {
            Integer endIndex = Math.min(i + chunkSize, responseBody.length());
            System.debug('RESPONSE: ' + responseBody.substring(i, endIndex));
        }
    }
    
    @future (callout=true)
    public static void unSubscribeHVPostalCode(string ownerID, String ItemID){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Length', '0');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(Label.ML_HV_URL + 'Services/LeadRouting/Unsubscribe');
        req.setHeader('x-ml-timestamp', Datetime.now().formatGMT('yyyyMMddHHmmss'));
        Blob inputBlob = Blob.valueOf('TopProducer '+ Label.HV_Access_Key  + ' x-ml-timestamp:'+Datetime.now().formatGMT('yyyyMMddHHmmss'));
        Blob hashBlob = Crypto.generateDigest('MD5', inputBlob);
        
        // Convert to hexadecimal string
        String md5Hash = EncodingUtil.convertToHex(hashBlob);
        req.setHeader('ml-auth','client=TopProducer&systemaccesskey=' + Label.HV_Access_Key + '&signature=' + md5Hash);
        req.setMethod('POST');
        req.setTimeout(60000);
        Map<String, Object> payload = new Map<String, Object>{
            'ExternalPartnerId' => ownerId,
                'ItemIdList' => new List<Integer>{
                    Integer.valueOf(ItemID)
                        }
        };
        
       	req.setBody(JSON.serialize(payload));
        HTTP http = new HTTP();          
        
        res = http.send(req);            
        
        System.debug('Response Status : '+res.getStatus());
        System.debug('Response Status Code : '+res.getStatusCode());
        System.debug('Response Body : '+res.getBody());
        String responseBody = res.getBody();

        Integer chunkSize = 200;
        
        for (Integer i = 0; i < responseBody.length(); i += chunkSize) {
            Integer endIndex = Math.min(i + chunkSize, responseBody.length());
            System.debug('RESPONSE: ' + responseBody.substring(i, endIndex));
        }
    }
    
    
    @future (callout=true)
    public static void updateSubscriptionDetails(String licenseStatus,string licenseID,string AccountID, string ownerID, string subscriptionID){
        SubscriptionRequestWrapper payload = new SubscriptionRequestWrapper();
        String requestBody;
        HttpResponse res;
        
        Subscription sub = new Subscription();
        sub.account_id = AccountID;
        sub.subscription_id = subscriptionID;
        String subscriptionStatus;
        if(licenseStatus == 'Suspended' || licenseStatus == 'Expired'){
            subscriptionStatus = '3';
        } else if(licenseStatus == 'Closed' || licenseStatus == 'Canceled'){
            subscriptionStatus = '4';
        }else if(licenseStatus == 'Probation'){
            subscriptionStatus = '2';
        }else{
            subscriptionStatus = '1';
        }
        sub.subscription_status_id = subscriptionStatus;
        payload.subscriptions = new List<Subscription>{ sub };
        // ===== Serialize =====
        requestBody = JSON.serialize(payload);
        res = sendApiCall(endPointURL + '/Subscriptions', 'PUT', requestBody);
        Boolean isSuccess = res != null && res.getStatusCode() == 200 && res.getStatus() == 'OK';
        User_Licensing__c uLicense = new User_Licensing__c(
            Id = licenseID,
            Status__c = isSuccess ? licenseStatus : 'Failed',
            Status_Code__c = res.getStatusCode() + ' ' + res.getBody()
        );
        update uLicense;
    }
    
    @future (callout=true)
    public static void updateSubscriptionLicenses(String licenseStatus,Decimal Quantity,string AccountID, string ownerID, string subscriptionID, String licenseType, string licenseID){
        SubscriptionRequestWrapper payload = new SubscriptionRequestWrapper();
        String requestBody;
        HttpResponse res;
        
        // ===== Subscription =====
        License lic1 = new License();
        lic1.license_type_id = licenseType;
        lic1.license_count = String.valueOf(Quantity);
        
        Subscription sub = new Subscription();
        sub.account_id = AccountID;
        sub.subscription_id = subscriptionID;
        sub.licenses = new List<License>{ lic1 };
            
        payload.subscriptions = new List<Subscription>{ sub };
        // ===== Serialize =====
        requestBody = JSON.serialize(payload);
        res = sendApiCall(endPointURL + '/Subscriptions', 'PATCH', requestBody);
        Boolean isSuccess = res != null && res.getStatusCode() == 200 && res.getStatus() == 'OK';
        User_Licensing__c uLicense = new User_Licensing__c(
            Id = licenseID,
            Status__c = isSuccess ? licenseStatus : 'Failed',
            Status_Code__c = res.getStatusCode() + ' ' + res.getBody()
        );
        update uLicense;
    }
    
    public static HttpResponse sendApiCall(String endPointURL,String method,String body){
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Length', '0');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Label.FB_Leads_Token);
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
       
        return res;
    }
    
    public class RequestWrapper {
        public String account_id;
        public String account_status_id;
        public String account_type_id;
        public String brand_id;
        public String is_customer_account;
        
        public String bl_company_name;
        public String bl_suite;
        public String bl_house;
        public String bl_street;
        public String bl_city;
        public String bl_state;
        public String bl_country;
        public String bl_zip;
        
        public String css_customer_id;
        public String sponsor_id;
        public String sponsor_customer_id;
        
        public String user_id;
        public String user_status_id;
        public String timezone;
        public String login_name;
        public String first_name;
        public String last_name;
        public String initial;
        public String hint_question;
        public String hint_answer;
        
        public String home_phone;
        public String work_phone;
        public String mobile_phone;
        public String fax;
        public String e_mail;
        
        public String suite;
        public String house;
        public String street;
        public String city;
        public String state;
        public String country;
        public String zip;
        
        public String birth_date;
        public String gender;
        
        public List<Subscription> subscriptions;
    }
    
    public class SubscriptionRequestWrapper {
        public List<Subscription> subscriptions;
    }
    
    public class Subscription {
        public String account_id;
    	public String owner_id;
        public String subscription_id;
        public String subscription_status_id;
        public String billing_day;
        public List<License> licenses;
        public List<LicenseAssignment> license_assignments;
    }
    
    public class License {
        public String license_type_id;
        public String license_count;
    }
    
    public class LicenseAssignment {
        public String license_type_id;
        public String user_id;
    }
}