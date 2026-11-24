public with sharing class CreditNoteExtController {
    private Id CreditNoteId;
    public CreditNoteExtController(ApexPages.StandardController stdController) {
        CreditNoteId= stdController.getId();
    }
    public PageReference onSubmit() {
        if (CreditNoteId != null) {
            SBAA.ApprovalAPI.submit(CreditNoteId, SBAA__Approval__c.Credit_Note__c);
        }
        return new PageReference('/' + CreditNoteId);
    }
    /*public PageReference onRecall() {
        if (CreditNoteId != null) {
            SBAA.ApprovalAPI.recall(CreditNoteId, SBAA__Approval__c.Credit_Note__c);
        }
        return new PageReference('/' + CreditNoteId);
    }*/
}