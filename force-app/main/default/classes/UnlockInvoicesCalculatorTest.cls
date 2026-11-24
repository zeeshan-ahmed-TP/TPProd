@isTest(SeeAllData=true)
public class UnlockInvoicesCalculatorTest {
	static testMethod void testMethod1() 
    {
        Test.startTest();
        
        string qri = 'Select Id,blng__LastPaymentRunProcessingMessage__c,blng__CorrectiveAction__c from blng__Invoice__c Limit 1';
        ID BatchId = Database.executeBatch(new GlobalBatch(qri, UnlockInvoicesCalculator.getInstance()), 200);
        
        Test.stopTest();
    }
}