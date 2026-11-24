@isTest
public class OpportunityTriggerHandlerTest {
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
        Contact contact = new Contact(AccountId = account.Id, FirstName = 'FName',LastName = 'LName' + String.ValueOf(account.Id).subString(0,3), isPrimaryContact__c = true, Phone = '2369932984');
        lstContacts.add(contact);   
        
        Contact contact1 = new Contact(AccountId = account1.Id, FirstName = 'FName1',LastName = 'LName1' + String.ValueOf(account1.Id).subString(0,3), isPrimaryContact__c = true, Phone = '(236) 993-2984');
        lstContacts.add(contact1);
        
        insert lstContacts;
    }
    
    @isTest
    static void testMethod1(){
        List<Account> lstAccounts = [SELECT ID FROM Account WHERE Name IN ('ULTesting','ULTesting1')];
        Account account = lstAccounts.get(0);
        Opportunity opp = new Opportunity(Name = 'Test Opp', CloseDate = System.today(),StageName = 'In Progress', AccountId = account.Id);
        insert opp;
        
    }
}