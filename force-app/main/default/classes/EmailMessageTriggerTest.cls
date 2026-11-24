@isTest
public class EmailMessageTriggerTest {
    
    @isTest
    private static void testEmailMessageOnClosedCase(){
        Case c = new Case(status='Closed', Outcome__c='Left Message');
        insert c;
        EmailMessage em = new EmailMessage(parentId=c.id, Subject='Test', Textbody='test', InComing = true);
        insert em;
    }
}