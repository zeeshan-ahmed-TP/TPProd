public class customLookUpController {
    public class userEntRecord {
        public string AccountVal; 
        public string Product;
        public string Numb;
        public string exist;
        public string MLS;
        public string subId;
    }
	@AuraEnabled
    public static List < sObject > fetchLookUpValues(String stateVal,String currentObj,String searchKeyWord, String ObjectName , String CurrentRecordId) {
   
        String searchKey = searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        if(ObjectName == 'Account'){
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
            String sQuery =  'select id, Name, RecordType.Name,ParentId from ' +ObjectName + ' where Name LIKE: searchKey AND (ParentId = \''+CurrentRecordId+'\' OR Id = \''+CurrentRecordId+'\')AND RecordType.Name IN (\'Team\', \'Agent\') order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            System.debug('lstOfRecords-->'+lstOfRecords);
            return returnList;
        } else if(ObjectName == 'MLS_Association__c'){
            System.Debug('inside the MLS part');
            String accId = currentObj;
            System.debug('stateVal-->'+stateVal);
            if(String.isNotEmpty(stateVal)){
                //List<Account> accLst = [Select id, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet from Account where Id =: accId limit 1];
                //if(!accLst.isEmpty()){
                    String sQuery =  'select id, Name,Billing_Street__c from ' +ObjectName + ' where Name LIKE: searchKey AND Billing_State_Province__c = \''+stateVal+'\' AND MLS_Status__c = \'Active\'order by createdDate DESC limit 5';
                    List < sObject > lstOfRecords = Database.query(sQuery);
                    for (sObject obj: lstOfRecords) {
                      returnList.add(obj);
                    }
                    System.debug('lstOfRecords-->'+lstOfRecords);
                    return returnList;
                //}
                /*else{
                    return returnList;
                }*/
            }
            else{
                return returnList;
            }
        } else if(ObjectName == 'SBQQ__Subscription__c'){
            String accId = currentObj;
            String sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey AND SBQQ__Account__c = \'' + accId + '\' AND SBQQ__ProductName__c = \'HouseValues\' AND Subscription_Status__c = \'Active\'order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            System.debug('lstOfRecords-->'+lstOfRecords);
            return returnList;
        }
        else{
            return returnList;
        }
        
    }
}