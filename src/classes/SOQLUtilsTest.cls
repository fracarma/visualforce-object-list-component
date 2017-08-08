@isTest
private class SOQLUtilsTest {


    @isTest
    static void methodOneTest() {
    	Set<String> fieldNameSet = new Set<String>{'Id','Name','Other__c'};
        String query = SOQLUtils.createQuery(fieldNameSet, 'Account');
        query = SOQLUtils.createQuery(fieldNameSet, 'Account','Account =: Var');
        system.debug('@@query: '+query);
    }

}