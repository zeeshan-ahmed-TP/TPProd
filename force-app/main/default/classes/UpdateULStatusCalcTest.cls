@isTest
public class UpdateULStatusCalcTest {

     @testSetup static void createTestData(){
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
        Test.startTest();
    }
    static testMethod void testMethod1() 
    {
        Test.startTest();
        
        string qri = 'Select Id, name, Product__c, Status__c,Quantity__c, TWS_MS_AccountId__c, TWS_MS_SubscriptionId__c, TWS_MS_UserId__c from User_Licensing__c Limit 1';
        ID BatchId = Database.executeBatch(new GlobalBatch(qri, UpdateULStatusCalculator.getInstance()),200);
        
        Test.stopTest();
    }
}