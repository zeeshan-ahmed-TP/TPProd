@isTest
public class ContactTriggerHandlerTest {
    
    
    
    @isTest static void InBeforeToastShowTest() {
        
        Account acc = new Account(Name= 'TestAccount',Total_Subscriptions__c = 10,Active_Subscriptions__c=8);
        
        insert acc;
        
        Contact cnt1 = new Contact(FirstName = 'Test',LastName ='User',Email='test@email.com',Main_Account_Owner__c = false,AccountId = acc.Id);
        
        Insert cnt1;
        
        Contact cnt2 = new Contact(FirstName = 'Testing',LastName ='Man',Email='test@email.com',Main_Account_Owner__c = true,AccountId = acc.Id);
        
        Insert cnt2;
        
        Test.startTest();
        try{
        cnt1.Main_Account_Owner__c = true;
        update cnt1;
        }
        catch(Exception e)
        {
        Boolean expectedExceptionThrown =  e.getMessage().contains(Label.MAO_Exist) ? true : false;
        System.assertEquals(expectedExceptionThrown, true);
        }
       
        Test.stopTest();      
    }
    
}