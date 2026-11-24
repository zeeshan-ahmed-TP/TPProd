public with sharing class PaymentExtController {
    private Id paymentId;
    public PaymentExtController(ApexPages.StandardController stdController) {
        paymentId= stdController.getId();
    }
    public PageReference onSubmit() {
        if (paymentId != null) {
            SBAA.ApprovalAPI.submit(paymentId, SBAA__Approval__c.Payment__c);
        }
        return new PageReference('/' + paymentId);
    }
    /*public PageReference onRecall() {
        if (paymentId != null) {
            SBAA.ApprovalAPI.recall(paymentId, SBAA__Approval__c.Payment__c);
        }
        return new PageReference('/' + paymentId);
    }*/
}