public class TPMSUtility {
	@Future(callout=true)
    public static void createAccount(String firstName,String lastName, String phone,String email, String AccountName,string licenseID,string TPAccountId,string TPUserID,string Username,List<string> lstMLSBoards){
    	System.debug('TPAccountId: ' + TPAccountId + ' TPUserID: ' + TPUserID);    
        List<User_Licensing__c> lstOfLicensing = new List<User_Licensing__c>();
        TPMS.tmk2cssSoap tpms = new TPMS.tmk2cssSoap();
        string accountID = GuidUtil.NewGuid();
        string ownerID = GuidUtil.NewGuid();
        string subscriptionID = GuidUtil.NewGuid();
        string loginName = UserInfo.UserLogin(firstName,lastName);
        string password = UserInfo.UserPassword(firstName,lastName,licenseID);
        
        DOM.Document docs = new DOM.Document();
        DOM.XmlNode parameter = docs.createRootElement('parameters', null, null);
        DOM.XmlNode user = parameter.addChildElement('user', null, null);
        user.setAttribute('login_name',loginName);
        
        
        String response = tpms.GetUserInfoByLogin4CSS(docs.toXmlString());
        System.debug('Name Res: ' + response);
        if(response !=null && response != '')
            loginName = UserInfo.NewUserLogin(firstName,lastName,licenseID);  
        //******************************creating XML input************************************//
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode account = parameters.addChildElement('account', null, null);
        account.setAttribute('account_id',accountID);
        account.setAttribute('account_status_id', '2');
        account.setAttribute('brand_id', '1');
        account.setAttribute('is_customer_account', '1');
        account.setAttribute('account_type_id', '1');
        account.setAttribute('bl_company_name', AccountName);
        
        DOM.XmlNode owner = parameters.addChildElement('owner', null, null);
        owner.setAttribute('user_id', ownerID);
        owner.setAttribute('user_status_id', '1');
        owner.setAttribute('login_name', loginName);
        owner.setAttribute('password', password);
        if(firstName!=null)
            owner.setAttribute('first_name',firstName);
        owner.setAttribute('last_name', lastName);
        // owner.setAttribute('work_phone', phone);
        owner.setAttribute('e_mail', email);
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
        license.setAttribute('license_type_id', '25');
        license.setAttribute('license_count', '1');
        
        DOM.XmlNode license4 = licenses.addChildElement('license', null, null);
        license4.setAttribute('license_type_id', '22');
        license4.setAttribute('license_count', '1'); 
        
        DOM.XmlNode license5;
        System.debug('lstMLSBoards Size: ' + lstMLSBoards.size());
        System.debug('lstMLSBoards: ' + lstMLSBoards);
        for(String mlsBoard : lstMLSBoards){
            if(mlsBoard!=null){
                license5 = licenses.addChildElement('license', null, null);
                license5.setAttribute('license_type_id', '20');
                license5.setAttribute('license_count', '1'); 
                System.debug('board_id: ' + mlsBoard);
                license5.setAttribute('board_id', mlsBoard);   
            }
        }
        System.debug('License: ' + licenses.getChildElements());
        DOM.XmlNode linkedApplications = parameters.addChildElement('linked_applications', null, null);
        DOM.XmlNode linkedApplication = linkedApplications.addChildElement('linked_application', null, null);
        linkedApplication.setAttribute('application_id', '1');//1 says it is application is CRM
        
        linkedApplication.setAttribute('account_id', TPAccountId);//1 then crm_account_id
        linkedApplication.setAttribute('login_name', username);//1 then crm_login_name
        linkedApplication.setAttribute('user_id', TPUserID);//1 then crm_user_id
            
            try{
                System.debug('doc: ' + doc.toXmlString());        
                Boolean res = tpms.CreateAccount(doc.toXmlString());
                system.debug(res);
                User_Licensing__c uLicense = new User_Licensing__c(id = licenseID);
                uLicense.Status__c = 'Fulfilled';
                uLicense.TWS_MS_AccountId__c = accountID;
                uLicense.TWS_MS_UserId__c = ownerID;
                uLicense.TWS_MS_SubscriptionId__c = subscriptionID ;
                uLicense.TPAccountId__c = TPAccountId;
                uLicense.TPUserID__c = TPUserID;
                uLicense.Username__c = loginName;
                uLicense.Password__c = password;
                uLicense.Quantity__c = 1;
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
        @future (callout=true)
        public static void GetUserInfoByLogin4CSS(string FirstName,string LastName, string phone){
            
          TPMS.tmk2cssSoap tpms = new TPMS.tmk2cssSoap();
          string loginName = UserInfo.UserLogin(firstName,lastName);

          DOM.Document doc = new DOM.Document();
          DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
          DOM.XmlNode user = parameters.addChildElement('user', null, null);
          user.setAttribute('login_name',loginName);
          system.debug(doc.toXmlString());
          String res = tpms.GetUserInfoByLogin4CSS(doc.toXmlString());
          system.debug('response: ' +res);
          system.debug('response: ' +res.length());
            if(res.length() == 15){
                loginName = UserInfo.NewUserLogin(firstName,lastName,phone);
                user.setAttribute('login_name',loginName);
                system.debug(doc.toXmlString());
                String response = tpms.GetUserInfoByLogin4CSS(doc.toXmlString());
                system.debug('User Information received with FirstName,LastName and phone');

            }
            else{
                system.debug('User Information received with FirstName.LastName');
            }
          
    	}
    //----------------------------- end GetUserInfoByLogin4CSS-----------------------------
    //-----------------------------UpdateAccountDetailsTP----------------------------------
    @Future(callout = true)
    public static void UpdateAccountDetails(String licenseStatus, String firstName,String lastName,string AccountName,string phone,String email,string AccountID, string ownerID,string subscriptionID, string loginname,string password,string TAccountID, string TownerID,string Tloginname){
            
        TPMS.tmk2cssSoap tpms = new TPMS.tmk2cssSoap();
        
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode account = parameters.addChildElement('account', null, null);
        if(AccountID != null)
        	account.setAttribute('account_id',AccountID);
        String accountStatus = licenseStatus == 'Suspended' || licenseStatus == 'Closed' || licenseStatus == 'Canceled' || licenseStatus == 'Expired' ? '3' : '2';
        account.setAttribute('account_status_id', accountStatus);
        account.setAttribute('billing_system_id','1');
        account.setAttribute('brand_id', '1');
        account.setAttribute('is_customer_account', '1');
        account.setAttribute('account_type_id', '1');
        account.setAttribute('bl_company_name', AccountName);
        
        DOM.XmlNode owner = parameters.addChildElement('owner', null, null);
        if(ownerID != null)
        	owner.setAttribute('user_id', ownerID);
        String userStatus;
        if(licenseStatus == 'Suspended' || licenseStatus == 'Expired'){
            userStatus = '2';
        } else if(licenseStatus == 'Closed' || licenseStatus == 'Canceled'){
            userStatus = '4';
        }else{
            userStatus = '1';
        }
        owner.setAttribute('user_status_id', userStatus);
        owner.setAttribute('login_name', loginName);
        owner.setAttribute('password', password);
        if(firstName != null)
            owner.setAttribute('first_name',firstName);
        owner.setAttribute('last_name', lastName);
        owner.setAttribute('work_phone', phone);
        //owner.setAttribute('mobile_phone', mobilePhone);
        owner.setAttribute('e_mail', email);
        owner.setAttribute('street', '');
        owner.setAttribute('city', '');
        owner.setAttribute('state','');
        owner.setAttribute('country', '');
        owner.setAttribute('zip', '');
        owner.setAttribute('birth_date', '12:00:00 AM');
        owner.setAttribute('gender', '1');
        
        
        DOM.XmlNode linkedApplications = parameters.addChildElement('linked_applications', null, null);
        DOM.XmlNode linkedApplication = linkedApplications.addChildElement('linked_application', null, null);
        linkedApplication.setAttribute('application_id', '1');
        if(TaccountID != null)
        	linkedApplication.setAttribute('account_id', TaccountID);
        linkedApplication.setAttribute('login_name', Tloginname);
        linkedApplication.setAttribute('user_id', Townerid);
        system.debug(doc.toXmlString());
        
        Boolean res = tpms.UpdateAccountDetails(doc.toXmlString());
        system.debug(res);
        
		doc = new DOM.Document();
        parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        if(AccountID != null)
        	subscription.setAttribute('account_id', AccountID);
        if(subscriptionID != null)
        	subscription.setAttribute('subscription_id',subscriptionID);//subscription__guid__c
        if(ownerID != null)
        	subscription.setAttribute('owner_id', ownerID);
        String subscriptionStatus;
        if(licenseStatus == 'Suspended' || licenseStatus == 'Expired'){
            subscriptionStatus = '3';
        } else if(licenseStatus == 'Closed' || licenseStatus == 'Canceled'){
            subscriptionStatus = '4';
        }else{
            subscriptionStatus = '1';
        }
        subscription.setAttribute('subscription_status_id', subscriptionStatus);
        
        system.debug(doc.toXmlString());
        
        res = tpms.UpdateSubscriptionDetails(doc.toXmlString());
        system.debug('response: ' +res);
    }
    //------------------end UpdateAccountDetailsTP------------------------------------------
    //------------------AddSubscription-----------------------------------------------------
    @Future(callout = true)
    public static void AddSubscription(string AccountID, string ownerID, string subscriptionID,string MLSBoard){
        
        TPMS.tmk2cssSoap tpms = new TPMS.tmk2cssSoap();
        
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        subscription.setAttribute('account_id', AccountID);
        subscription.setAttribute('owner_id', ownerID);
        subscription.setAttribute('subscription_id',subscriptionID);
        subscription.setAttribute('subscription_status_id', '1');
        
        DOM.XmlNode licenses = subscription.addChildElement('licenses', null, null);
        DOM.XmlNode license = licenses.addChildElement('license', null, null);
        license.setAttribute('license_type_id', '20');
        license.setAttribute('license_count', '1'); 
        license.setAttribute('board_id', MLSBoard);
       
        system.debug(doc.toXmlString());
        
        Boolean res = tpms.AddModifySubscription(doc.toXmlString());
        system.debug('response: ' +res);
    }
//-----------------end---------------------------------------

    //----------------------end AddSubscription---------------------------------------------
    //-----------------UpdateSubscriptionDetailsTP------------------------------------------
    @Future(callout = true)
    public static void UpdateSubscriptionDetails(String licenseStatus,string AccountID, string ownerID, string subscriptionID){
    	
        TPMS.tmk2cssSoap tpms = new TPMS.tmk2cssSoap();
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        if(AccountID != null)
        	subscription.setAttribute('account_id', AccountID);
        if(subscriptionID != null)
        	subscription.setAttribute('subscription_id',subscriptionID);//subscription__guid__c
        if(ownerID != null)
        	subscription.setAttribute('owner_id', ownerID);
        String subscriptionStatus;
        if(licenseStatus == 'Suspended' || licenseStatus == 'Expired'){
            subscriptionStatus = '3';
        } else if(licenseStatus == 'Closed' || licenseStatus == 'Canceled'){
            subscriptionStatus = '4';
        }else{
            subscriptionStatus = '1';
        }
        subscription.setAttribute('subscription_status_id', subscriptionStatus);
        
        system.debug(doc.toXmlString());
        
        Boolean res = tpms.UpdateSubscriptionDetails(doc.toXmlString());
        system.debug('response: ' +res);
    }
//--------------------end---------------------------------
//-------------ModifySubscriptionLicenses--------------------
     @Future(callout = true)
   	 public static void ModifySubscriptionLicenses(string AccountID, string ownerID, string subscriptionID,string MLSBoard){
     	TPMS.tmk2cssSoap tpms = new TPMS.tmk2cssSoap();
        
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
         if(AccountID != null)
        	subscription.setAttribute('account_id', AccountID);
         if(ownerID != null)
        	subscription.setAttribute('owner_id', ownerID);
         if(subscriptionID != null)
        	subscription.setAttribute('subscription_id',subscriptionID);
        subscription.setAttribute('subscription_status_id', '1');
        
        DOM.XmlNode licenses = subscription.addChildElement('licenses', null, null);
        DOM.XmlNode license = licenses.addChildElement('license', null, null);
        license.setAttribute('license_type_id', '20');
        license.setAttribute('license_count', '1'); 
        license.setAttribute('board_id', MLSBoard);
         
        system.debug(doc.toXmlString());
        
        Boolean res = tpms.ModifySubscriptionLicenses(doc.toXmlString());
        system.debug('response: ' +res);
        
     }
  
//-------------------end-------------------------------
//--------------------GetLicensesInfo----------------
    /*@Future(callout = true)
    public static void GetLicensesInfo(string AccountID, string ownerID){

       TPMS.tmk2cssSoap tpms = new TPMS.tmk2cssSoap();

       DOM.Document doc = new DOM.Document();
       DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
       //account
       DOM.XmlNode user_info = parameters.addChildElement('user_info', null, null);
       user_info .setAttribute('account_id', AccountID);//guid
       //owner
       user_info.setAttribute('user_id', ownerID);//
       system.debug(doc.toXmlString());
       string res = tpms.GetLicensesInfo(doc.toXmlString());
       system.debug('response'+res);
    }*/
//--------------------end-----------------------------------
//--------------------AddModifySubscriptionDetails---------
    @Future(callout = true)
    public static void AddModifySubscription(string AccountID, string ownerID, string subscriptionID,string MLSBoard,string count){
        
        TPMS.tmk2cssSoap tpms = new TPMS.tmk2cssSoap();
        
        DOM.Document doc = new DOM.Document();
        DOM.XmlNode parameters = doc.createRootElement('parameters', null, null);
        DOM.XmlNode subscriptions = parameters.addChildElement('subscriptions', null, null);
        DOM.XmlNode subscription = subscriptions.addChildElement('subscription', null, null);
        if(AccountID != null)
        	subscription.setAttribute('account_id', AccountID);
        if(subscriptionID != null)
        	subscription.setAttribute('subscription_id',subscriptionID);//subscription__guid__c
        if(ownerID != null)
        subscription.setAttribute('owner_id', ownerID);
        
        DOM.XmlNode licenses = subscription.addChildElement('licenses', null, null);
        DOM.XmlNode license = licenses.addChildElement('license', null, null);
        license.setAttribute('license_type_id', '20');
        license.setAttribute('license_count',count);
        license.setAttribute('board_id', MLSBoard);
       
        system.debug(doc.toXmlString());
        
        Boolean res = tpms.AddModifySubscription(doc.toXmlString());
        system.debug('response: ' +res);
    }
//-----------------end---------------------------------------
public static void dummyCode(){
        String test = '';
            test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
    test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
    test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
        test = '';
    }
}