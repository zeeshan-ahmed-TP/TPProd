public class TPCRMHandler {
    
    private static final String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
    private static final String serviceNS = 'http://www.myservice.com/services/MyService/';
    private static final String xsd ='http://www.w3.org/2001/XMLSchema';
    private static final String mes = 'http://tempuri.org/TP2CSS/message/';
    private static final String encodingStyle= 'http://schemas.xmlsoap.org/soap/encoding/';
    
    private static final Map<String, String> AccountTypes = new Map<String, String>{
        'Agent' => '1',
        'Broker' => '3', 
        'Team' => '4'
    };
        
    private static final String WSDL_URL = Label.TP_CRM_WSDL_URL;
    
    /**************************************SOAP Actions*************************************/
    private static final String tempURI = 'http://tempuri.org/TP2CSS/action/';
    private static final String SaCreateAccount = tempURI + 'Profile.CreateAccount';
    private static final String SaUpdateAccount = tempURI + 'Profile.UpdateAccountDetails';
    private static final String SaUpdateSubscription = tempURI + 'Profile.UpdateSubscriptionDetails';
    private static final String SaUpdateSubscriptionLicenses = tempURI + 'Profile.ModifySubscriptionLicenses';
    private static final String SaGetUserInfoByLogin4CSS = tempURI + 'ProfileRO.GetUserInfoByLogin4CSS';
    private static final String SaAddSubscription = tempURI + 'Profile.AddSubscription';
    
    
    @Future(callout=true)
    public static void createAccountInCRM(String recordType, Decimal Quantity, String firstName,String lastName, String email, String AccountName,string licenseID){
    	
        List<User_Licensing__c> lstOfLicensing = new List<User_Licensing__c>();
		string accountID = GuidUtil.NewGuid();
        string ownerID = GuidUtil.NewGuid();
        string subscriptionID = GuidUtil.NewGuid();
        string loginName = UserInfo.UserLogin(firstName,lastName);
        string password = UserInfo.UserPassword(firstName,lastName,licenseID);
                    
        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('xsi', xsi);
		envelope.setNamespace('xsd', xsd);
		envelope.setNamespace('mes', mes);
        dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
        dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        
		String insideParameters = ''; 
        
        /************** Code to Check If Username Already Exists - Start ******************/
		
        dom.XmlNode GetUInfoByL4CSS = body.addChildElement('GetUserInfoByLogin4CSS', mes, null);
        GetUInfoByL4CSS.setAttributeNS('soapenv:encodingStyle', encodingStyle, null, null);
        dom.XmlNode GUIBL4C_i_sXML = GetUInfoByL4CSS.addChildElement('i_sXML', null, null);
        GUIBL4C_i_sXML.setAttributeNS('xsi:type', 'xsd:string', null, null);
        
        DOM.Document checkUnDocs = new DOM.Document();
        DOM.XmlNode checkParam = checkUnDocs.createRootElement('parameters', null, null);
        DOM.XmlNode checkUser = checkParam.addChildElement('user', null, null);
        checkUser.setAttribute('login_name',loginName);
        system.debug(checkUnDocs.toXmlString());
        insideParameters = checkUnDocs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4();
        GUIBL4C_i_sXML.addTextNode('<![CDATA['+insideParameters+']]>');
        System.debug('Node: ' + '<![CDATA['+insideParameters+']]>');
        HttpResponse response;
        if(Test.isRunningTest()){
            response = null;
        }else{
            response = sendApiCall(WSDL_URL, 'POST', doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4(),SaGetUserInfoByLogin4CSS);
        }
        
        if(response != null && Integer.valueOf(response.getHeader('Content-Length')) > 1000) {
            system.debug('login name exists');
            loginName = UserInfo.NewUserLogin(firstName,lastName,licenseID);            
        }       
        else{
            system.debug('No change in login name');
        }
        
        /************** Code to Check If Username Already Exists - End ******************/
        
        body.removeChild(GetUInfoByL4CSS);
        insideParameters = '';
        
        dom.XmlNode createAccount = body.addChildElement('CreateAccount', mes, null);
		createAccount.setAttributeNS('soapenv:encodingStyle', encodingStyle, null, null);
        dom.XmlNode ca_i_sXML = createAccount.addChildElement('i_sXML', null, null);
		ca_i_sXML.setAttributeNS('xsi:type', 'xsd:string', null, null);
        
        
        DOM.Document docs = new DOM.Document();
        DOM.XmlNode parameters = docs.createRootElement('parameters', null, null);
        DOM.XmlNode account = parameters.addChildElement('account', null, null);
        account.setAttribute('account_id','{'+accountID+'}');
        account.setAttribute('account_status_id', '2');
        account.setAttribute('account_type_id', AccountTypes.get(recordType));
        account.setAttribute('brand_id', '1');
        account.setAttribute('bl_company_name',AccountName);
        account.setAttribute('bl_suite', '');
        account.setAttribute( 'bl_house' , '');
        account.setAttribute('bl_street','');
        account.setAttribute('bl_city','');
        account.setAttribute('bl_state','');
        account.setAttribute('bl_country','');
        account.setAttribute('bl_zip',''); 
        account.setAttribute('is_customer_account', '1');
        
        DOM.XmlNode owner = parameters.addChildElement('owner', null, null);
        owner.setAttribute('user_id', '{'+ownerID+'}');
        owner.setAttribute('user_status_id', '1');
        owner.setAttribute('login_name', loginName);
        owner.setAttribute('password', password);
        if(firstName != null)
        	owner.setAttribute('first_name',firstName);
        owner.setAttribute('last_name', lastName);
        owner.setAttribute('e_mail', email);
        owner.setAttribute('suite','');
        owner.setAttribute('house','');
        
        owner.setAttribute('street', '');
        owner.setAttribute('city', '');
        owner.setAttribute('state', '');
        owner.setAttribute('country', '');
        owner.setAttribute('zip', '');
        owner.setAttribute('birth_date', '12:00:00 AM');
        owner.setAttribute('gender', '1');

        DOM.XmlNode linkedApplications = parameters.addChildElement('linked_applications', null, null);
        DOM.XmlNode linkedApplication = linkedApplications.addChildElement('linked_application', null, null);
        linkedApplication.setAttribute('application_id', '1');//1 says it is application is CRM
        linkedApplication.setAttribute('account_id','{'+ accountID+'}');//1 then crm_account_id
        linkedApplication.setAttribute('login_name','{'+ loginName+'}');//1 then crm_login_name
        linkedApplication.setAttribute('user_id', '{'+ownerID+'}');//1 then crm_user_id
        
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        subscription.setAttribute('subscription_id','{'+ subscriptionID+'}');
        subscription.setAttribute('subscription_status_id', '1');
        subscription.setAttribute('billing_day', '13');
        
        DOM.XmlNode licenses = subscription.addChildElement('licenses', null, null);
        DOM.XmlNode license = licenses.addChildElement('license', null, null);
        license.setAttribute('license_type_id', '1');
        license.setAttribute('license_count', String.valueOf(Quantity));
        
        DOM.XmlNode license4 = licenses.addChildElement('license', null, null);
        license4.setAttribute('license_type_id', '15');
        license4.setAttribute('license_count', String.valueOf(Quantity)); 
        
        System.debug(docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        insideParameters = docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4();
        
        
        ca_i_sXML.addTextNode('<![CDATA['+insideParameters+']]>');
        system.debug('doc.toXmlString'+doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        
        try{
                HttpResponse res;
            if(Test.isRunningTest()){
                res = null;
            }else{
                res = sendApiCall(WSDL_URL, 'POST', doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4(),SaCreateAccount);
            }
                system.debug(res);
                User_Licensing__c uLicense = new User_Licensing__c(id = licenseID);
                uLicense.Status__c = 'Fulfilled';
                uLicense.TPAccountId__c = accountID;
                uLicense.TPUserID__c = ownerID;
                uLicense.TPSubscriptionID__c = subscriptionID ;
                uLicense.Username__c = loginName;
                uLicense.Password__c = password;
                lstOfLicensing.add(uLicense);
            }
            catch( Exception e)
            {
                system.debug('exception'+e);
                User_Licensing__c uLicense = new User_Licensing__c(id = licenseID);
                uLicense.Status__c = 'Failed';
                uLicense.Status_Code__c = e.getMessage();
                lstOfLicensing.add(uLicense);
            }
            
            update lstOfLicensing;
    }
    
    public static HttpResponse sendApiCall(String endPointURL,String method,String body, String soapAction){
        system.debug('endPointURL: ' + endPointURL);
        system.debug('method: '+ method);
        system.debug(LoggingLevel.INFO, 'body: '+ body);
        system.debug('soapAction: ' + soapAction);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Length', '0');
        req.setHeader('SOAPAction', soapAction);
        req.setEndPoint(endPointURL);
        req.setBody(body);
        req.setMethod(method);
        req.setTimeout(60000);
       
        HTTP http = new HTTP();          
       
        res = http.send(req);
       
        System.debug('Response Status : '+res.getStatus());
        System.debug('Response Status Code : '+res.getStatusCode());
        System.debug('Response Body : '+res.getBody().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
       
        return res;
    }
    
    @future (callout=true)
    public static void updateAccount(String licenseStatus, String recordType, Decimal Quantity, String firstName,String lastName, String email, String AccountName,string licenseID,string AccountID, string ownerID, string subscriptionID, string loginName, String password){
        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('xsi', xsi);
		envelope.setNamespace('xsd', xsd);
		envelope.setNamespace('mes', mes);
        dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
        dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        
		String insideParameters = '';
        
        dom.XmlNode updateAccount = body.addChildElement('UpdateAccountDetails', mes, null);
		updateAccount.setAttributeNS('soapenv:encodingStyle', encodingStyle, null, null);
        dom.XmlNode ua_i_sXML = updateAccount.addChildElement('i_sXML', null, null);
		ua_i_sXML.setAttributeNS('xsi:type', 'xsd:string', null, null);
        
        DOM.Document docs = new DOM.Document();
        DOM.XmlNode parameters = docs.createRootElement('parameters', null, null);
        DOM.XmlNode account = parameters.addChildElement('account', null, null);
        account.setAttribute('account_id','{'+accountID+'}');
        String accountStatus = licenseStatus == 'Closed' || licenseStatus == 'Canceled' || licenseStatus == 'Expired' ? '3' : '2';
        account.setAttribute('account_status_id', accountStatus);
        account.setAttribute('account_type_id', AccountTypes.get(recordType));
        account.setAttribute('bl_company_name',AccountName);
        account.setAttribute('bl_suite', '');
        account.setAttribute( 'bl_house' , '');
        account.setAttribute('bl_street','');
        account.setAttribute('bl_city','');
        account.setAttribute('bl_state','');
        account.setAttribute('bl_country','');
        account.setAttribute('bl_zip',''); 
        
        DOM.XmlNode owner = parameters.addChildElement('owner', null, null);
        owner.setAttribute('user_id', '{'+ownerID+'}');
        owner.setAttribute('login_name',loginName);
        owner.setAttribute('password', password);
        if(firstName != null)
        owner.setAttribute('first_name',firstName);
        if(lastName != null)
        owner.setAttribute('last_name', lastName);
        if(email!=null)
        owner.setAttribute('e_mail', email);
        String userStatus;
        if(licenseStatus == 'Suspended' || licenseStatus == 'Expired'){
            userStatus = '2';
        } else if(licenseStatus == 'Closed' || licenseStatus == 'Canceled'){
            userStatus = '4';
        }else{
            userStatus = '1';
        }
        owner.setAttribute('user_status_id', userStatus);

        DOM.XmlNode linkedApplications = parameters.addChildElement('linked_applications', null, null);
        DOM.XmlNode linkedApplication = linkedApplications.addChildElement('linked_application', null, null);
        linkedApplication.setAttribute('application_id', '1');//1 says it is application is CRM
        linkedApplication.setAttribute('account_id','{'+ accountID+'}');//1 then crm_account_id
        linkedApplication.setAttribute('login_name','{'+ loginName+'}');//1 then crm_login_name
        linkedApplication.setAttribute('user_id', '{'+ownerID+'}');//1 then crm_user_id
        
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        subscription.setAttribute('subscription_id','{'+ subscriptionID+'}');
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
        
        subscription.setAttribute('subscription_status_id', subscriptionStatus);
        subscription.setAttribute('billing_day', '13');
        
        DOM.XmlNode licenses = subscription.addChildElement('licenses', null, null);
        DOM.XmlNode license = licenses.addChildElement('license', null, null);
        license.setAttribute('license_type_id', '1');
        license.setAttribute('license_count', String.valueOf(Quantity));
        
        DOM.XmlNode license4 = licenses.addChildElement('license', null, null);
        license4.setAttribute('license_type_id', '15');
        license4.setAttribute('license_count', String.valueOf(Quantity)); 
        
        System.debug(docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        insideParameters = docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4();
        
        
        ua_i_sXML.addTextNode('<![CDATA['+insideParameters+']]>');
        system.debug('doc.toXmlString'+doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        try{
                        
                HttpResponse res = sendApiCall(WSDL_URL, 'POST', doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4(),SaUpdateAccount);
                system.debug(res);
            }
            catch( Exception e)
            {
                system.debug('exception'+e);
                User_Licensing__c uLicense = new User_Licensing__c(id = licenseID);
                uLicense.Status__c = 'Failed';
                uLicense.Status_Code__c = e.getMessage();
                update uLicense;
            }
    }
    
    @future (callout=true)
    public static void updateSubscription(String licenseStatus,string licenseID,string AccountID, string ownerID, string subscriptionID){
        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('xsi', xsi);
		envelope.setNamespace('xsd', xsd);
		envelope.setNamespace('mes', mes);
        dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
        dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        
		String insideParameters = '';
        
        dom.XmlNode updateAccount = body.addChildElement('UpdateSubscriptionDetails', mes, null);
		updateAccount.setAttributeNS('soapenv:encodingStyle', encodingStyle, null, null);
        dom.XmlNode ua_i_sXML = updateAccount.addChildElement('i_sXML', null, null);
		ua_i_sXML.setAttributeNS('xsi:type', 'xsd:string', null, null);
        
        DOM.Document docs = new DOM.Document();
        DOM.XmlNode parameters = docs.createRootElement('parameters', null, null);
        
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        subscription.setAttribute('account_id','{'+ accountID+'}');
        subscription.setAttribute('subscription_id','{'+ subscriptionID+'}');
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
        String customMessage = '';
        if(licenseStatus == 'Suspended'){
            customMessage = '&lt;message titlebar=&quot;Titlebar&quot; caption=&quot;Action Required: Important Subscription Notice&quot; description=&quot;Your account is in suspension&quot; type=&quot;1&quot;&gt;&lt;details&gt;&lt;detail heading=&quot;Subscription Details&quot; body=&quot; Your account is currently suspended due to having multiple missed payments. To resolve this matter please contact our billing team at 1-800-241-5721 during the following times: Monday to Friday 7:30AM to 4:00PM PST. At this time, you are unable to login to your account.&quot;/&gt;&lt;/details&gt;&lt;/message&gt;';
        }else if(licenseStatus == 'Probation'){
            customMessage = '&lt;message titlebar=&quot;Titlebar&quot; caption=&quot;Action Required: Important Subscription Notice&quot; description=&quot;Your account is in probation&quot; type=&quot;1&quot;&gt;&lt;details&gt;&lt;detail heading=&quot;Subscription Details&quot; body=&quot;Your account is currently in probation as you have missed a payment. To resolve this matter please contact our billing team at 1-800-241-5721 during the following times: Monday to Friday 7:30AM to 4:00PM PST. At this time, you are still able to login to your account by clicking continue.&quot;/&gt;&lt;/details&gt;&lt;/message&gt;';
        }
        System.debug('msgDoc: ' + customMessage);
        subscription.setAttribute('subscription_status_id', subscriptionStatus);
        subscription.setAttribute('subscription_owner_message', customMessage);
        subscription.setAttribute('subscription_user_message', customMessage);
        subscription.setAttribute('show_until_date', '2050-12-31');
        subscription.setAttribute('billing_day', '13');
        System.debug(docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        insideParameters = docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4();
        
        
        ua_i_sXML.addTextNode('<![CDATA['+insideParameters+']]>');
        system.debug('doc.toXmlString'+doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        try{
                        
                HttpResponse res = sendApiCall(WSDL_URL, 'POST', doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4(),SaUpdateSubscription);
                system.debug(res);
            }
            catch( Exception e)
            {
                system.debug('exception'+e);
                User_Licensing__c uLicense = new User_Licensing__c(id = licenseID);
                uLicense.Status__c = 'Failed';
                uLicense.Status_Code__c = e.getMessage();
                update uLicense;
            }
    }
    
    @future (callout=true)
    public static void addSubscription(String licenseId, Decimal Quantity,string AccountID, string ownerID, string subscriptionID, String licenseType){
        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('xsi', xsi);
		envelope.setNamespace('xsd', xsd);
		envelope.setNamespace('mes', mes);
        dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
        dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        
		String insideParameters = '';
        
        dom.XmlNode updateAccount = body.addChildElement('AddSubscription', mes, null);
		updateAccount.setAttributeNS('soapenv:encodingStyle', encodingStyle, null, null);
        dom.XmlNode ua_i_sXML = updateAccount.addChildElement('i_sXML', null, null);
		ua_i_sXML.setAttributeNS('xsi:type', 'xsd:string', null, null);
        
        DOM.Document docs = new DOM.Document();
        DOM.XmlNode parameters = docs.createRootElement('parameters', null, null);
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        subscription.setAttribute('subscription_id','{'+ subscriptionID+'}');
        subscription.setAttribute('account_id','{'+ accountID+'}');
        subscription.setAttribute('owner_id','{'+ ownerID+'}');
        subscription.setAttribute('user_id','{'+ ownerID+'}');
        subscription.setAttribute('subscription_status_id', '1');
        
        DOM.XmlNode licenses = subscription.addChildElement('licenses', null, null);
        
        DOM.XmlNode license4 = licenses.addChildElement('license', null, null);
        license4.setAttribute('license_type_id', licenseType);
        license4.setAttribute('license_count', String.valueOf(Quantity)); 
        
        System.debug(docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        insideParameters = docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4();
        
        
        ua_i_sXML.addTextNode('<![CDATA['+insideParameters+']]>');
        system.debug('doc.toXmlString'+doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        try{
            HttpResponse res = sendApiCall(WSDL_URL, 'POST', doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4(),SaAddSubscription);
            system.debug(res);
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
        catch( Exception e)
        {
            system.debug('exception'+e);
        }
    }
    
    @future (callout=true)
    public static void updateSubscriptionLicenses(Decimal Quantity,string AccountID, string ownerID, string subscriptionID){
        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('xsi', xsi);
		envelope.setNamespace('xsd', xsd);
		envelope.setNamespace('mes', mes);
        dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
        dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        
		String insideParameters = '';
        
        dom.XmlNode updateAccount = body.addChildElement('ModifySubscriptionLicenses', mes, null);
		updateAccount.setAttributeNS('soapenv:encodingStyle', encodingStyle, null, null);
        dom.XmlNode ua_i_sXML = updateAccount.addChildElement('i_sXML', null, null);
		ua_i_sXML.setAttributeNS('xsi:type', 'xsd:string', null, null);
        
        DOM.Document docs = new DOM.Document();
        DOM.XmlNode parameters = docs.createRootElement('parameters', null, null);
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        subscription.setAttribute('subscription_id','{'+ subscriptionID+'}');
        subscription.setAttribute('account_id','{'+ accountID+'}');
        subscription.setAttribute('owner_id','{'+ ownerID+'}');
        
        DOM.XmlNode licenses = subscription.addChildElement('licenses', null, null);
        DOM.XmlNode license = licenses.addChildElement('license', null, null);
        license.setAttribute('license_type_id', '1');
        license.setAttribute('license_count', String.valueOf(Quantity));
        
        DOM.XmlNode license4 = licenses.addChildElement('license', null, null);
        license4.setAttribute('license_type_id', '15');
        license4.setAttribute('license_count', String.valueOf(Quantity)); 
        
        System.debug(docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        insideParameters = docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4();
        
        
        ua_i_sXML.addTextNode('<![CDATA['+insideParameters+']]>');
        system.debug('doc.toXmlString'+doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        try{
                        
                HttpResponse res = sendApiCall(WSDL_URL, 'POST', doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4(),SaUpdateSubscriptionLicenses);
                system.debug(res);
            }
            catch( Exception e)
            {
                system.debug('exception'+e);
            }
    }
    
    /*@future (callout=true)
    public static void GetUserInfoByLogin4CSS(string FirstName,string LastName, string phone){
        
        DOM.Document doc = new DOM.Document();
        dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        envelope.setNamespace('xsi', xsi);
        envelope.setNamespace('xsd', xsd);
        envelope.setNamespace('mes', mes);
        
        dom.XmlNode header = envelope.addChildElement('Header', soapNS, null);
        
        dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        dom.XmlNode bodyChild1 = body.addChildElement('GetUserInfoByLogin4CSS', mes, null);
        bodyChild1.setAttributeNS('soapenv:encodingStyle', encodingStyle, null, null);
        dom.XmlNode bodyChild2 = bodyChild1.addChildElement('i_sXML', null, null);
        bodyChild2.setAttributeNS('xsi:type', 'xsd:string', null, null);
        
        System.debug(doc.toXmlString());
        String insideParameters = '';
        
        string loginName = UserInfo.UserLogin(firstName,lastName);
        
        DOM.Document docs = new DOM.Document();
        DOM.XmlNode parameters = docs.createRootElement('parameters', null, null);
        DOM.XmlNode user = parameters.addChildElement('user', null, null);
        user.setAttribute('login_name',loginName);
        system.debug(docs.toXmlString());
        
        insideParameters = docs.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4();
        bodyChild2.addTextNode('<![CDATA['+insideParameters+']]>');
        system.debug('doc.toXmlString'+doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4());
        HttpResponse res = sendApiCall(WSDL_URL, 'POST', doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4(),SaGetUserInfoByLogin4CSS);
        System.debug('TPCRM Res: ' + res);
        
        
        system.debug('response: ' +res);
        
        if(res.getStatusCode() == 200){
            loginName = UserInfo.NewUserLogin(firstName,lastName,phone);
            user.setAttribute('login_name',loginName);
            system.debug(doc.toXmlString());
            HttpResponse response = sendApiCall(WSDL_URL, 'POST', doc.toXmlString().replaceAll('\\<\\?xml(.+?)\\?\\>', '').trim().unescapeHtml4(),SaGetUserInfoByLogin4CSS);
            system.debug('User Information received with FirstName,LastName and phone');
            
        }
        else{
            system.debug('User Information received with FirstName.LastName');
        }   
    }*/
}