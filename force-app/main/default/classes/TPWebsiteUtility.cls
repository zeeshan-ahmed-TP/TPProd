public class TPWebsiteUtility {
    
    //----------------------------createAccount-----------------------------
    @Future(callout=true)
    public static void createAccount(String firstName,String lastName, String email, String AccountName,Decimal Quantity,string licenseID){
        List<User_Licensing__c> lstOfLicensing = new List<User_Licensing__c>();
        
        TpWebsite.redirectSoap tpWebsite = new TpWebsite.redirectSoap();
        string accountID = GuidUtil.NewGuid();
        string ownerID = GuidUtil.NewGuid();
        string subscriptionID = GuidUtil.NewGuid();
        string loginName = UserInfo.UserLogin(firstName,lastName);
        string password = UserInfo.UserPassword(firstName,lastName,licenseID);
        
        DOM.Document docs = new DOM.Document();
        DOM.XmlNode parameter = docs.createRootElement('parameters', null, null);
        DOM.XmlNode user = parameter.addChildElement('user', null, null);
        user.setAttribute('login_name',loginName);
        system.debug(docs.toXmlString());
        List<Dom.XmlNode> resChildNodes;
        If(!Test.isRunningTest()){
            String response = tpWebsite.GetUserInfoByLogin4CSS(docs.toXmlString());
            DOM.Document responseDoc = new DOM.Document();
            responseDoc.load(response);
            Dom.XmlNode root = responseDoc.getRootElement();
            resChildNodes = root.getChildElements(); 
        }
        
        if(resChildNodes != null && resChildNodes.size() > 0) {
            loginName = UserInfo.NewUserLogin(firstName,lastName,licenseID);
        }   
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode account = parameters.addChildElement('account', null, null);
        account.setAttribute('account_id',accountID);
        account.setAttribute('account_status_id', '2');//2
        account.setAttribute('billing_system_id','1');
        account.setAttribute('brand_id', '1');
        account.setAttribute('bl_company_name', AccountName);
        account.setAttribute('is_customer_account', '1');
        account.setAttribute('account_type_id', '1');
        account.setAttribute('zip', '');
        account.setAttribute('reactivation', 'FALSE');
        
        DOM.XmlNode owner = parameters.addChildElement('owner', null, null);
        owner.setAttribute('user_id', ownerID);
        owner.setAttribute('user_status_id', '1');
        owner.setAttribute('timezone','7');
        owner.setAttribute('login_name', loginName);
        owner.setAttribute('password', password);
        if(firstName != null)
        	owner.setAttribute('first_name',firstName);
        owner.setAttribute('last_name', lastName);
        owner.setAttribute('e_mail', '');
        owner.setAttribute('street', '');
        owner.setAttribute('city', '');
        owner.setAttribute('state', '');
        owner.setAttribute('country', '');
        owner.setAttribute('zip', '');
        owner.setAttribute('birth_date', '12:00:00 AM');
        owner.setAttribute('gender', '1');
        
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        subscription.setAttribute('subscription_id', subscriptionID);
        subscription.setAttribute('subscription_status_id', '1');
        
        DOM.XmlNode licenses = subscription.addChildElement('licenses', null, null);
        DOM.XmlNode license = licenses.addChildElement('license', null, null);
        license.setAttribute('license_type_id', '1');
        license.setAttribute('license_count', '1');
        
        DOM.XmlNode license4 = licenses.addChildElement('license', null, null);
        license4.setAttribute('license_type_id', '4');
        license4.setAttribute('license_count', String.valueOf(Quantity));
        
        system.debug(doc.toXmlString());
        try{
            Boolean res = tpWebsite.CreateAccount(doc.toXmlString());
            system.debug(res);
            User_Licensing__c uLicense = new User_Licensing__c(id = licenseID);
            uLicense.Status__c = 'Fulfilled';
            uLicense.TWS_MS_AccountId__c = accountID;
            uLicense.TWS_MS_UserId__c = ownerID;
            uLicense.TWS_MS_SubscriptionId__c = subscriptionID ;
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
    //--------------------end createAccount----------------------------------------------
    
    //-------------------GetUserInfoByLogin4CSS------------------------------------------
    /*@future (callout=true)
    public static void GetUserInfoByLogin4CSS(string FirstName,string LastName, string phone){
        
        TpWebsite.redirectSoap tpWebsite = new TpWebsite.redirectSoap();
        string loginName = UserInfo.UserLogin(firstName,lastName);
        
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode user = parameters.addChildElement('user', null, null);
        user.setAttribute('login_name',loginName);
        system.debug(doc.toXmlString());
        String res = tpWebsite.GetUserInfoByLogin4CSS(doc.toXmlString());
        system.debug('response: ' +res);
        system.debug('response: ' +res.length());
        if(res.length() == 15){
            loginName = UserInfo.NewUserLogin(firstName,lastName,phone);
            user.setAttribute('login_name',loginName);
            system.debug(doc.toXmlString());
            String response = tpWebsite.GetUserInfoByLogin4CSS(doc.toXmlString());
            system.debug('User Information received with FirstName,LastName and phone');
            
        }
        else{
            system.debug('User Information received with FirstName.LastName');
        }
        
    }*/
    //----------------------------- end GetUserInfoByLogin4CSS-----------------------------
    //-----------------------------UpdateAccountDetailsTP----------------------------------
    @Future(callout = true)
    public static void UpdateAccountDetails(String licenseStatus, String firstName,String lastName, String email,string AccountID, string ownerID, string subscriptionID,string loginname,string password){
        TpWebsite.redirectSoap tpWebsite = new TpWebsite.redirectSoap();
        
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode account = parameters.addChildElement('account', null, null);
        if(accountID != null){
         	account.setAttribute('account_id',accountID);   
        }
        String accountStatus = licenseStatus == 'Closed' || licenseStatus == 'Canceled' || licenseStatus == 'Expired' ? '3' : '2';
        account.setAttribute('account_status_id', accountStatus);
        account.setAttribute('billing_system_id','1');
        account.setAttribute('brand_id', '1');
        account.setAttribute('is_customer_account', '1');
        account.setAttribute('account_type_id', '1');
        
        DOM.XmlNode owner = parameters.addChildElement('owner', null, null);
        if(ownerID != null){
         	owner.setAttribute('user_id', ownerID);   
        }
        String userStatus;
        if(licenseStatus == 'Suspended' || licenseStatus == 'Expired'){
            userStatus = '2';
        } else if(licenseStatus == 'Closed' || licenseStatus == 'Canceled'){
            userStatus = '4';
        }else{
            userStatus = '1';
        }
        owner.setAttribute('user_status_id', userStatus);
        owner.setAttribute('timezone','7');
        owner.setAttribute('login_name', loginName);
        owner.setAttribute('password', password);
        if(firstName != null)
        owner.setAttribute('first_name',firstName);
        owner.setAttribute('last_name', lastName);
        owner.setAttribute('e_mail', email);
        owner.setAttribute('street', '');
        owner.setAttribute('city', '');
        owner.setAttribute('state', '');
        owner.setAttribute('country', '');
        owner.setAttribute('zip', '');
        owner.setAttribute('birth_date', '12:00:00 AM');
        owner.setAttribute('gender', '1');
        
        
        system.debug(doc.toXmlString());
        
        Boolean res = tpWebsite.UpdateAccountDetails(doc.toXmlString());
        system.debug(res);
    }
    //------------------end UpdateAccountDetailsTP------------------------------------------
    //-----------------UpdateSubscriptionDetailsTP------------------------------------------
    @Future(callout = true)
    public static void UpdateSubscriptionDetails(String licenseStatus, string AccountID, string ownerID, string subscriptionID,string loginname, string password){
        TpWebsite.redirectSoap tpWebsite = new TpWebsite.redirectSoap();
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        //account
        /*DOM.XmlNode account = parameters.addChildElement('account', null, null);
        account.setAttribute('account_id', AccountID);
        //owner
        DOM.XmlNode owner = parameters.addChildElement('owner', null, null);
        owner.setAttribute('user_id', ownerID);
        owner.setAttribute('login_name', loginName);
        system.debug('login'+loginName);
        owner.setAttribute('password', password);*/
        //system.debug('login'+password); 
        //subscription
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
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        subscription.setAttribute('account_id', AccountID);
        subscription.setAttribute('subscription_id',subscriptionID);//subscription__guid__c
        subscription.setAttribute('subscription_status_id', subscriptionStatus);//1
        subscription.setAttribute('owner_id', ownerID);
        system.debug(doc.toXmlString());
        Boolean res = tpWebsite.UpdateSubscriptionDetails(doc.toXmlString());
        system.debug('response: ' +res);
        //return res;
        
    }
    
    //--------------------end---------------------------------
    //-------------ModifySubscriptionLicenses--------------------
    /*@Future(callout = true)
    public static void ModifySubscriptionLicenses(string AccountID, string ownerID,string subscriptionID){
        
        TpWebsite.redirectSoap tpWebsite = new TpWebsite.redirectSoap();
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode user_info = parameters.addChildElement('user_info', null, null);
        user_info .setAttribute('account_id', AccountID);
        user_info.setAttribute('user_id', ownerID);
        system.debug(doc.toXmlString());
        string res = tpWebsite.GetLicensesInfo(doc.toXmlString());
        system.debug('response'+res);
        if( res.contains('lic_count'))
        {
            system.debug('lic_count');
        }*/
        /*  TpWebsite.redirectSoap tpWebsite = new TpWebsite.redirectSoap();
DOM.Document doc = new DOM.Document();
DOM.XmlNode parameters = doc.createRootElemsent('parameters', null, null);
//account
DOM.XmlNode subscription = parameters.addChildElement('subscription', null, null);
subscription.setAttribute('account_id', acc.Id);
s   //owner
subscription.setAttribute('owner_id', ownerID);
//subscription
subscription.setAttribute('subscription_id', subs.Id);

DOM.XmlNode licenses = subscription.addChildElement('licenses', null, null);
DOM.XmlNode license = licenses.addChildElement('license', null, null);
license.setAttribute('license_type_id', '1');
license.setAttribute('increment_license_count', '-1');


Boolean res = tpWebsite.ModifySubscriptionLicenses(doc.toXmlString());
system.debug('response: ' +res);*/
        // return res;
        
    //}
    //-------------------end-------------------------------
    //--------------------GetLicensesInfo----------------
    /*@Future(callout = true)
    public static void GetLicensesInfo(string AccountID, string ownerID){
        TpWebsite.redirectSoap tpWebsite = new TpWebsite.redirectSoap();
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        //account
        DOM.XmlNode user_info = parameters.addChildElement('user_info', null, null);
        user_info .setAttribute('account_id', AccountID);//guid
        //owner
        user_info.setAttribute('user_id', ownerID);//
        system.debug(doc.toXmlString());
        string res = tpWebsite.GetLicensesInfo(doc.toXmlString());
        system.debug('response'+res);
        // return res;
    }*/
    //--------------------end-----------------------------------
    //--------------------AddModifySubscriptionDetails---------
    /*@Future(callout = true)
    public static void AddModifySubscription(string AccountID, string ownerID, string subscriptionID,string loginname, string password){
        TpWebsite.redirectSoap tpWebsite = new TpWebsite.redirectSoap();
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        //account
        DOM.XmlNode account = parameters.addChildElement('account', null, null);
        account.setAttribute('account_id', AccountID);
        //owner
        DOM.XmlNode owner = parameters.addChildElement('owner', null, null);
        owner.setAttribute('user_id', ownerID);
        owner.setAttribute('login_name', loginName);
        system.debug('login'+loginName);
        owner.setAttribute('password', password);
        //system.debug('login'+password); 
        //subscription
        
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        subscription.setAttribute('subscription_id',subscriptionID);//subscription__guid__c
        subscription.setAttribute('subscription_status_id', '1');//1
        system.debug(doc.toXmlString());
        Boolean res = tpWebsite.AddModifySubscription(doc.toXmlString());
        system.debug('response: ' +res);
        //return res;
    }*/
    //-----------------end---------------------------------------
    
}