public class UpdateULStatusCalculator implements ICalculate{
    
    private static UpdateULStatusCalculator instance = null;
    
    private UpdateULStatusCalculator(){
    }  
    
    // Making sure Class is Singlton    
    public static UpdateULStatusCalculator getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(instance == null)
        {
            instance = new UpdateULStatusCalculator();
        }
        return instance;
    } 
    
    public void Calculate(List<sObject> lRecords){
        List<User_Licensing__c> records = (List<User_Licensing__c>) lRecords;
        for(User_Licensing__c ul : records){
            ul.Status__c = 'Fulfilled';
        }
        update records;
        for(User_Licensing__c ul : records){
            ul.Status__c = 'Canceled';
        }
        update records;
    }
    
    public string Name()
    {
        return 'User Licensing Update Status Batch';
    }
}