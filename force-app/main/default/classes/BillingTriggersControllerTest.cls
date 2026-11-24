@isTest(SeeAllData=true)
public class BillingTriggersControllerTest {
	static testMethod void testMethod1() 
    {
        Test.startTest();
        
        blng__Invoice__c inv = [Select Id,blng__LastPaymentRunProcessingMessage__c,blng__CorrectiveAction__c from blng__Invoice__c Where blng__PaymentStatus__c = 'Unpaid' Limit 1];
        BillingTriggersController.deleteInvoice(inv.Id);
        
        Test.stopTest();
    }
}