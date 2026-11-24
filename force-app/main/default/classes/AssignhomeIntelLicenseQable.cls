public class AssignhomeIntelLicenseQable implements Queueable{
    
    private final String FS = 'FiveStreet', TPCRM = 'Top Producer CRM', MS = 'Market Snapshot',
        			TPW = 'Top Producer Website', TPAL = 'Top Producer Assistant License', FBL = 'Social Connect';
    Private User_Licensing__c license;
    Private String subscriptionId;
    
    public AssignhomeIntelLicenseQable(User_Licensing__c lic, String subId){
        this.license = lic;
        this.subscriptionId = subId;
    }
    public void execute(QueueableContext context) {
        HomeIntelHandler.assignHomeIntelLicense(license.Account__c,license.Id,subscriptionId);
    }
    
}