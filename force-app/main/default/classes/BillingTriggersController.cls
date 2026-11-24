public with sharing class BillingTriggersController {

    @AuraEnabled
    public static String deleteInvoice(String recordId) {
        System.debug('Invoice Id: ' + recordId);
        if(recordId != null){
            blng__BillingConfig__c blngConfig = blng__BillingConfig__c.getInstance('DISABLE_TRIGGERS');
            if(blngConfig != null){
                blngConfig.blng__BooleanValue__c = true;
                try {
                    update blngConfig;
                    System.debug('Custom Setting record updated successfully.');
                    List<blng__PaymentTransaction__c> lstPaymentTrans = [Select Id,blng__RequestInvoice__c,blng__ResponseStatus__c from blng__PaymentTransaction__c where blng__RequestInvoice__c =: recordId];
                    if(lstPaymentTrans != null && lstPaymentTrans.size() > 0){
                        for(blng__PaymentTransaction__c paymentTrans : lstPaymentTrans){
                            if(paymentTrans.blng__ResponseStatus__c == 'Approved'){
                                blngConfig.blng__BooleanValue__c = false;
                                update blngConfig;
                                return 'Invoice has successful payment transaction which cannot be deleted.';
                            }
                        }
                        delete lstPaymentTrans;
                    }
                    List<blng__Invoice__c> lstInvoices = [Select Id,Name,blng__PaymentStatus__c from blng__Invoice__c where Id =: recordId];
                    if(lstInvoices != null && lstInvoices.size() > 0){
                        delete lstInvoices;
                    }
                    blngConfig.blng__BooleanValue__c = false;
                    update blngConfig;
                    return 'Successfull';
                } catch (DmlException e) {
                    System.debug('An error occurred while updating the record: ' + e.getMessage());
                }
            }
        }
        return '';
    }

}