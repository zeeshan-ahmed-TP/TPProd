@isTest
public class taskTriggerHandlerTest {
    @isTest 
    static void testTask1() {
        Task task = new Task(Subject = 'Test Sub',aircall__CallId__c = '12345',CallDisposition = '[\'ProSoft Inbound Call\',\'TPInbound_test\',\'TPSales_test\',\'TPCS_test\',\'TP Directory\',\'aircall\',\'inbound\',\'answered_call\',\'13152326180\']');
        insert task;
        update task;
    }
}