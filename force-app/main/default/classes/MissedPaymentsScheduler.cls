global without sharing class MissedPaymentsScheduler implements Schedulable{
	global void execute(SchedulableContext sc)
      {      
          string qri = 'SELECT Id,blng__Order__c,blng__Account__c,blng__DueDate__c,Aging_Invoice__c FROM blng__Invoice__c Where Record_Type__c = \'Top Producer\' and Aging_Invoice__c = false and blng__Balance__c > 0 and blng__PaymentStatus__c != \'Paid\' and blng__InvoiceStatus__c != \'Cancelled\' and blng__PaymentBatch__c != \'Batch 2\' and blng__PaymentBatch__c != \'Batch 5\' and blng__Account__r.User_Licensing_Status__c != \'Closed\'';
          ID BatchId = Database.executeBatch(new GlobalBatch(qri, MissedPaymentsCalculator.getInstance()), 10);
      } 
}