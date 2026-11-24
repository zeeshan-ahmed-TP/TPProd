global without sharing class UnlockInvoicesScheduler implements Schedulable{
	global void execute(SchedulableContext sc)
      {      
          string qri = 'Select Id,blng__LastPaymentRunProcessingMessage__c,blng__CorrectiveAction__c from blng__Invoice__c where blng__CorrectiveAction__c = \'ActionRequired\' And (blng__LastPaymentRunProcessingMessage__c = \'This transaction resulted in a Declined gateway response.\' OR blng__LastPaymentRunProcessingMessage__c = \'This transaction resulted in a Valdation Error gateway response.\' OR blng__LastPaymentRunProcessingMessage__c = \'This transaction resulted in a Permanent Fail gateway response.\')';
          ID BatchId = Database.executeBatch(new GlobalBatch(qri, UnlockInvoicesCalculator.getInstance()), 200);
      } 
}