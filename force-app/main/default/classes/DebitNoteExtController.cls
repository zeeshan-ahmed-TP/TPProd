public with sharing class DebitNoteExtController {
    private Id DebitNoteId;
    public DebitNoteExtController(ApexPages.StandardController stdController) {
        DebitNoteId= stdController.getId();
    }
    public PageReference onSubmit() {
        if (DebitNoteId != null) {
            SBAA.ApprovalAPI.submit(DebitNoteId, SBAA__Approval__c.Debit_Note__c);
        }
        return new PageReference('/' + DebitNoteId);
    }
   /* public PageReference onRecall() {
        if (DebitNoteId != null) {
            SBAA.ApprovalAPI.recall(DebitNoteId, SBAA__Approval__c.Debit_Note__c);
        }
        return new PageReference('/' + DebitNoteId);
    }*/
}