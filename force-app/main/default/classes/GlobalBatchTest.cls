@isTest(SeeAllData=true)
public class GlobalBatchTest {
	
    static testMethod void testMethod1() 
    {
        Test.startTest();
        
        string qri = 'SELECT Id,blng__Order__c,blng__Account__c,blng__DueDate__c,Aging_Invoice__c FROM blng__Invoice__c Where blng__Balance__c > 0 and blng__PaymentStatus__c != \'Paid\' Limit 50';
        ID BatchId = Database.executeBatch(new GlobalBatch(qri, MissedPaymentsCalculator.getInstance()),200);
        
        Test.stopTest();
    }
}