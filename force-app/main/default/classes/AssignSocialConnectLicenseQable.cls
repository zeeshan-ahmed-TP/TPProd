public class AssignSocialConnectLicenseQable implements Queueable{
    
    private final String FS = 'FiveStreet', TPCRM = 'Top Producer CRM', MS = 'Market Snapshot',
        			TPW = 'Top Producer Website', TPAL = 'Top Producer Assistant License', FBL = 'Social Connect';
    Private User_Licensing__c license;
    Private String subscriptionId;
    
    public AssignSocialConnectLicenseQable(User_Licensing__c lic, String subId){
        this.license = lic;
        this.subscriptionId = subId;
    }
    public void execute(QueueableContext context) {
        FBLeadsHandler.CreateFBLicense(String.valueOf(getUTCDateTime(license.Start_Time_UTC__c)),license.End_Time_UTC__c != null? String.valueOf(getUTCDateTime(license.End_Time_UTC__c)) : null,license.Location_Radius__c,license.Daily_Budget__c
                                       
                                       ,license.Account__c,license.Id,subscriptionId);        
    }
    public DateTime getUTCDateTime(DateTime dt){
        Datetime GMTDate = Datetime.newInstanceGmt(
            dt.year(),
            dt.month(),
            dt.day(),
            dt.hour(),
            dt.minute(),
            dt.second());
        return GMTDate;
    }
}