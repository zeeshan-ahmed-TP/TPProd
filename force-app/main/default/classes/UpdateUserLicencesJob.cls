public class UpdateUserLicencesJob implements Queueable {
    
    private List<User_Licensing__c> lstUserLicensing;
    
    public UpdateUserLicencesJob(List<User_Licensing__c> lstUL){
        this.lstUserLicensing = lstUL;
    }
    
    public void execute(QueueableContext context){
        for(User_Licensing__c userLicensing : lstUserLicensing){
            userLicensing.Status__c = userLicensing.Account__r.User_Licensing_Status__c;   
        }
        if(lstUserLicensing.size() > 0){
            update lstUserLicensing;
        }
    }
}