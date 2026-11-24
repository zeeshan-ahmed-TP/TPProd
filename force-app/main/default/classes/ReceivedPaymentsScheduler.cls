global without sharing class ReceivedPaymentsScheduler implements Schedulable{
	global void execute(SchedulableContext sc)
      {      
          string qri = 'SELECT Id,blng__Order__c,blng__Account__c,blng__Balance__c,blng__PaymentStatus__c,blng__DueDate__c,Aging_Invoice__c, blng__Account__r.User_Licensing_Status__c FROM blng__Invoice__c Where Record_Type__c = \'Top Producer\' and Aging_Invoice__c = true and blng__InvoiceStatus__c != \'Cancelled\' and blng__PaymentBatch__c != \'Batch 2\' and blng__PaymentBatch__c != \'Batch 5\' and Written_Off__c = false';
          ID BatchId = Database.executeBatch(new GlobalBatch(qri, ReceivedPaymentsCalculator.getInstance()), 10);
      } 
}