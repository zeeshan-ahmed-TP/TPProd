@isTest
private class UserLicensingTriggerHandler_Test {
    
    @testSetup static void createTestData(){
        UserLicensingTriggerHandler.dummyCode();
        List<Account> lstAccounts = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();
        Account account = new Account();
        account.Name = 'ULTesting';
        account.Phone='12345';
        account.Five_Street_License__c = 5;
        account.Market_Snapshot_License__c = 5;
        account.Top_Producer_CRM_License__c = 5;
        account.Top_Producer_Websites_License__c = 5;
        account.Email__c = 'test@gmail.com';
        lstAccounts.add(account);
        
        Account account1 = new Account();
        account1.Name = 'ULTesting1';
        account1.Phone='123451';
        account1.Five_Street_License__c = 5;
        account1.Market_Snapshot_License__c = 5;
        account1.Top_Producer_CRM_License__c = 5;
        account1.Top_Producer_Websites_License__c = 5;
        account1.Email__c = 'test1@gmail.com';
        lstAccounts.add(account1);
        
        insert lstAccounts;          
        Contact contact = new Contact(AccountId = account.Id, FirstName = 'FName',LastName = 'LName' + String.ValueOf(account.Id).subString(0,3), isPrimaryContact__c = true);
        lstContacts.add(contact);   
        
        Contact contact1 = new Contact(AccountId = account1.Id, FirstName = 'FName1',LastName = 'LName1' + String.ValueOf(account1.Id).subString(0,3), isPrimaryContact__c = true);
        lstContacts.add(contact1);
        
        insert lstContacts;
        
        List<User_Licensing__c> lstUL = new List<User_Licensing__c>();
        
        User_Licensing__c userLicensingObj = new User_Licensing__c();
        userLicensingObj.Account__c=account.id;
        userLicensingObj.Parent_Account__c = account.id;
        userLicensingObj.Status__c='Pending Fulfillment';
        userLicensingObj.Product__c='Top Producer Website';
        userLicensingObj.TPAccountId__c = '12345';
        userLicensingObj.TPUserID__c = '12345';
        userLicensingObj.TPSubscriptionID__c = '12345';
        userLicensingObj.Quantity__c = 1;
        lstUL.add(userLicensingObj);
        
        User_Licensing__c userLicensingObj1 = new User_Licensing__c();
        userLicensingObj1.Account__c=account.id;
        userLicensingObj1.Parent_Account__c = account.id;
        userLicensingObj1.Status__c='Fulfilled';
        userLicensingObj1.Product__c='Top Producer CRM';
        userLicensingObj1.TPAccountId__c = '12345';
        userLicensingObj1.Username__c = 'user.name';
        userLicensingObj1.Password__c = 'password';
        userLicensingObj1.TPUserID__c = '12345';
        userLicensingObj1.TPSubscriptionID__c = '12345';
        userLicensingObj1.Quantity__c = 1;
        lstUL.add(userLicensingObj1);
        
        insert lstUL;
        userLicensingObj1.Quantity__c = 4;
        update userLicensingObj1;
        Test.startTest();
    }
    @isTest
    static void fiveStreetTest(){
        try{
            List<Account> lstAccounts = [SELECT ID FROM Account WHERE Name IN ('ULTesting','ULTesting1')];
            Account account = lstAccounts.get(0);
            Account account1 = lstAccounts.get(1);
            User_Licensing__c license = new User_Licensing__c();
            license.Account__c=account.id;
            license.Parent_Account__c = account.id;
            license.Status__c='Pending Fulfillment';
            license.Product__c='FiveStreet';
            Test.startTest();
            insert license;
            license.Status__c='Fulfilled';
            license.Quantity__c = 2;
            license.Parent_Account__c = account1.id;
            update license;
            license.Status__c='Canceled';
            update license;
            Test.stopTest();
        }
        catch(Exception e){
            System.debug('Exception due to--->: '+e.getMessage()+'   Line Number-->: '+e.getLineNumber());
        }
    }
    @isTest
    static void tpWebsiteInsertTest(){
        try{
            List<Account> lstAccounts = [SELECT ID FROM Account WHERE Name IN ('ULTesting','ULTesting1')];
            Account account = lstAccounts.get(0);
            Account account1 = lstAccounts.get(1);
            User_Licensing__c userLicensingObj=[Select Id,name,Status__c,Username__c,Password__c,TPAccountId__c,TPUserID__c,Quantity__c,Parent_Account__c from User_Licensing__c Limit 1];
            
            userLicensingObj.Status__c= 'Fulfilled';
            userLicensingObj.Username__c = 'user.name';
            userLicensingObj.Password__c = 'password';
            userLicensingObj.TPAccountId__c = '12345';
            userLicensingObj.TPUserID__c = '12345';
            userLicensingObj.Quantity__c = 2;
            userLicensingObj.Parent_Account__c = account1.id;
            update userLicensingObj;
            Test.startTest();
            userLicensingObj.Status__c='Canceled';
            update userLicensingObj;
            Test.stopTest();
        }
        catch(Exception e){
            System.debug('Exception due to--->: '+e.getMessage()+'   Line Number-->: '+e.getLineNumber());
        }
    }
    
    @isTest
    static void tpWebsiteUpdateTest(){
        
    }
    
    @isTest
    static void tpCRMMSTest1(){
        try{
            List<Account> lstAccounts = [SELECT ID FROM Account WHERE Name IN ('ULTesting','ULTesting1')];
            Account account = lstAccounts.get(0);
            Account account1 = lstAccounts.get(1);
            List<User_Licensing__c> lstUL = [Select Id from User_Licensing__c where Product__c = 'Top Producer CRM'];
            for(User_Licensing__c userLicensingObj : lstUL){
                userLicensingObj.Status__c= 'Probation';
                userLicensingObj.Quantity__c = 2;
            }
            Test.startTest();
            update lstUL;
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception due to--->: '+e.getMessage()+'   Line Number-->: '+e.getLineNumber());
        }
    }
    @isTest
    static void tpCRMMSTest(){
        try{
            List<Account> lstAccounts = [SELECT ID FROM Account WHERE Name IN ('ULTesting','ULTesting1')];
            Account account = lstAccounts.get(0);
            Account account1 = lstAccounts.get(1);
            User_Licensing__c userLicensingObj=new User_Licensing__c();
            userLicensingObj.Account__c=account.id;
            userLicensingObj.Parent_Account__c=account.id;
            userLicensingObj.Status__c='Pending Fulfillment';
            userLicensingObj.Product__c='Top Producer CRM';
            userLicensingObj.TPAccountId__c = '12345';
            userLicensingObj.TPUserID__c = '12345';
            userLicensingObj.Quantity__c = 1;
            insert userLicensingObj;
            userLicensingObj.Status__c= 'Fulfilled';
            userLicensingObj.Username__c = 'user.name';
            userLicensingObj.Password__c = 'password';
            userLicensingObj.Quantity__c = 2;
            userLicensingObj.Parent_Account__c = account1.id;
            update userLicensingObj;
            
            MLS_Association__c mlsAssoc = new MLS_Association__c(Name = 'Arizona Regional Multiple Listing Service',MLS_Status__c = 'Active');
            insert mlsAssoc;
            MLS_Board__c mlsBoard = new MLS_Board__c(MLS_Association__c = mlsAssoc.Id,Primary_BoardId__c = true,Name = 'MLS Board',MLS_Board_ID__c = '1234');
            insert mlsBoard;
            
            User_Licensing__c userLicensingObj1 =new User_Licensing__c();
            userLicensingObj1.Account__c=account.id;
            userLicensingObj1.Parent_Account__c = account.id;
            userLicensingObj1.Status__c='Pending Fulfillment';
            userLicensingObj1.Product__c='Market Snapshot';
            userLicensingObj1.TPAccountId__c = '12345';
            userLicensingObj1.TPUserID__c = '12345';
            userLicensingObj1.TPSubscriptionID__c = '12345';
            userLicensingObj1.MLSCount__c = '1234;4321;';
            userLicensingObj1.Quantity__c = 1;
            insert userLicensingObj1;
            
             MLS__c mls = new MLS__c(MLS_Board__c = mlsBoard.Id,MLS_Association__c = mlsAssoc.Id,User_Licensing__c = userLicensingObj1.Id,MLS__c = account.Id);
            insert mls;
            
            userLicensingObj1.Status__c= 'Fulfilled';
            userLicensingObj1.Username__c = 'user.name';
            userLicensingObj1.Password__c = 'password';
            userLicensingObj1.TPAccountId__c = '12345';
            userLicensingObj1.TPUserID__c = '12345';
            userLicensingObj1.TPSubscriptionID__c = '12345';
            userLicensingObj1.Quantity__c = 2;
            userLicensingObj1.Parent_Account__c = account1.id;
            Test.startTest();
            try{
                update userLicensingObj1;
            }catch(Exception ex){
                
            }
            Test.stopTest();
            TPMSUtility.dummyCode();
            TPWebsite.dummyCode();
            TPMS.dummyCode();
            UserLicensingTriggerHandler.dummyCode();
            UserInfo.NewUserLogin('12345','54321','123456789101112131415');
            
        }
        catch(Exception e){
            System.debug('Exception due to--->: '+e.getMessage()+'   Line Number-->: '+e.getLineNumber());
        }
    }
    
    @isTest
    static void tpSocialConnectTest(){
        try{
            List<Account> lstAccounts = [SELECT ID FROM Account WHERE Name IN ('ULTesting','ULTesting1')];
            Account account = lstAccounts.get(0);
            Account account1 = lstAccounts.get(1);
            User_Licensing__c userLicensingObj=new User_Licensing__c();
            userLicensingObj.Account__c=account.id;
            userLicensingObj.Parent_Account__c=account.id;
            userLicensingObj.Product__c='Top Producer CRM';
            userLicensingObj.TPAccountId__c = '12345';
            userLicensingObj.TPUserID__c = '12345';
            userLicensingObj.Quantity__c = 1;
            userLicensingObj.Status__c= 'Fulfilled';
            userLicensingObj.Username__c = 'user.name';
            userLicensingObj.Password__c = 'password';
            
            insert userLicensingObj;
            
            User_Licensing__c userLicensingObj1 =new User_Licensing__c();
            userLicensingObj1.Account__c=account.id;
            userLicensingObj1.Parent_Account__c = account.id;
            userLicensingObj1.Status__c='Pending Fulfillment';
            userLicensingObj1.Product__c=ProductNames.TPSC;
            userLicensingObj1.TPAccountId__c = '12345';
            userLicensingObj1.TPUserID__c = '12345';
            userLicensingObj1.TPSubscriptionID__c = '12345';
            userLicensingObj1.Quantity__c = 1;
            userLicensingObj1.Start_Time_UTC__c = DateTime.now();
            userLicensingObj1.End_Time_UTC__c = DateTime.now() + 2;
            userLicensingObj1.Location_Radius__c = 30;
            userLicensingObj1.Daily_Budget__c = 50;
            
            try{
                UserLicensingRecursion.flag = true;
             	insert userLicensingObj1;   
            }catch(Exception ex){
                system.debug('Ex: ' + ex.getMessage());
            }
            
            userLicensingObj1.Status__c='Fulfilled';
            UserLicensingRecursion.flag = true;
            update userLicensingObj1;
            
            Test.startTest();
            UserLicensingRecursion.flag = true;
            userLicensingObj1.Location_Radius__c = 40;
            update userLicensingObj1;
            
            UserLicensingRecursion.flag = true;
            userLicensingObj1.Status__c='Canceled';
            update userLicensingObj1;
            FBLeadsHandler.DummyCode();
            Social_Connect_License__e scAssignmentEvent = new Social_Connect_License__e(
                License_Id__c = userLicensingObj1.Id,
                Subscription_Id__c = userLicensingObj1.TPSubscriptionID__c);
            Database.SaveResult sr = EventBus.publish(scAssignmentEvent);
            Test.stopTest();
            
            
        }
        catch(Exception e){
            System.debug('Exception due to--->: '+e.getMessage()+'   Line Number-->: '+e.getLineNumber());
        }
    }
    
    @isTest
    static void homeIntelTest(){
        try{
            List<Account> lstAccounts = [SELECT ID FROM Account WHERE Name IN ('ULTesting','ULTesting1')];
            Account account = lstAccounts.get(0);
            Account account1 = lstAccounts.get(1);
            User_Licensing__c userLicensingObj=new User_Licensing__c();
            userLicensingObj.Account__c=account.id;
            userLicensingObj.Parent_Account__c=account.id;
            userLicensingObj.Product__c='Top Producer CRM';
            userLicensingObj.TPAccountId__c = '12345';
            userLicensingObj.TPUserID__c = '12345';
            userLicensingObj.Quantity__c = 1;
            userLicensingObj.Status__c= 'Fulfilled';
            userLicensingObj.Username__c = 'user.name';
            userLicensingObj.Password__c = 'password';
            
            insert userLicensingObj;
            
            User_Licensing__c userLicensingObj1 =new User_Licensing__c();
            userLicensingObj1.Account__c=account.id;
            userLicensingObj1.Parent_Account__c = account.id;
            userLicensingObj1.Status__c='Pending Fulfillment';
            userLicensingObj1.Product__c=ProductNames.TPHI;
            userLicensingObj1.TPAccountId__c = '12345';
            userLicensingObj1.TPUserID__c = '12345';
            userLicensingObj1.TPSubscriptionID__c = '12345';
            userLicensingObj1.Quantity__c = 1;
            
            try{
                UserLicensingRecursion.flag = true;
             	insert userLicensingObj1;   
            }catch(Exception ex){
                system.debug('Ex: ' + ex.getMessage());
            }
            
            userLicensingObj1.Status__c='Fulfilled';
            UserLicensingRecursion.flag = true;
            update userLicensingObj1;
            HomeIntel_License__e hiAssignmentEvent = new HomeIntel_License__e(
                License_Id__c = userLicensingObj1.Id,
                Subscription_Id__c = userLicensingObj1.TPSubscriptionID__c);
            Database.SaveResult sr = EventBus.publish(hiAssignmentEvent);
            
            Test.startTest();
            
            UserLicensingRecursion.flag = true;
            userLicensingObj1.Status__c='Canceled';
            update userLicensingObj1;
            HomeIntelHandler.DummyCode();
            Test.stopTest();
            
            
        }
        catch(Exception e){
            System.debug('Exception due to--->: '+e.getMessage()+'   Line Number-->: '+e.getLineNumber());
        }
    }
    
    @isTest
    static void ZurpDeProvisionTest(){
        try{
            List<Account> lstAccounts = [SELECT ID FROM Account WHERE Name IN ('ULTesting','ULTesting1')];
            Account account = lstAccounts.get(0);
            Account account1 = lstAccounts.get(1);
            List<User_Licensing__c> lstUL = [Select Id from User_Licensing__c where Product__c = 'Zurple'];
            for(User_Licensing__c userLicensingObj : lstUL){
                userLicensingObj.Status__c= 'Canceled';
            }
            Test.startTest();
            update lstUL;
            ZurpleDeProvisionHandler.dummyCode();
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception due to--->: '+e.getMessage()+'   Line Number-->: '+e.getLineNumber());
        }
    }
    
}