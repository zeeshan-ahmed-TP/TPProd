public class LeadConvertClass {
    public static Boolean flag=true;
    public static void LinkAccountLead(List<Lead> leadList){
        try{       
            set<Id> ExistingLeadID=new set<Id>();
            for(Lead lead:leadList)
            {
                ExistingLeadID.add(lead.id);
            }
            
            List<Lead> leadList2=[select id,Email,Status,Campaign__c,Campaign_Name__c,Phone,Account__c,company, website,Industry,NumberOfEmployees,Capture_rectype__c,Account_type__c from Lead where Id in: ExistingLeadID];//Smitha : Added Capture_rectype__c field to the query
            List<Account> AccList=[select id,Email__c,Phone,name,website,Industry,NumberOfEmployees,RecordType.Name from Account limit 1000];//Smitha : Added RecordType.Name field to the query
            List<Campaign> CampList=[select id,Name from Campaign limit 1000];
            
            Map<Id,Account> accMap=new Map<Id,Account>(AccList);
            
            for(Lead lead:leadList2)
            {
                if(lead.Email!=null || lead.Phone!=null ){
                    string leadEmail = lead.Email;
                    string leadPhone = lead.Phone;
                    string leadcombo = leadEmail+leadPhone;
                    //string leadrecordtype = lead.Capture_rectype__c;//Smitha: Added code for storing Lead Record Type
                    string leadrecordtype = lead.Account_type__c;
                    for(Account acc:AccList)
                    {
                        string AccountEmail = acc.Email__c;
                        string AccountPhone = acc.Phone;
                        string Accountcombo = AccountEmail+AccountPhone;
                        string AccountRecType  = acc.RecordType.Name;//Smitha: Added code for storing Account Record Type
                        
                        system.debug('Srtatus'+lead.Status);
                        if( lead.Status != 'Working - Open Deal' && (leadrecordtype == AccountRecType) && ((leadcombo == Accountcombo) ||( leadEmail ==  AccountEmail && leadEmail != null) || (leadPhone == AccountPhone && leadPhone != null)))
                        {
                            lead.Account__c=acc.id;
                      
                            lead.Status = 'Already Customer';
                            
                        }
                    }  
                    
                }         
            }
            
            for(lead camplead: leadlist2)
            {
                if(camplead.Campaign_Name__c!=null)
                {
                    string leadnamecheck = camplead.Campaign_Name__c;
                    for(campaign camp: CampList)
                    {  
                        if(camp.Name == leadnamecheck)
                        {
                            camplead.Campaign__c = camp.Id;
                        }
                    } 
                }
            }  
            upsert leadList2;
        }
        catch(exception e){
            System.debug(e.getMessage()+'line'+e.getLineNumber());
        }
    }
}