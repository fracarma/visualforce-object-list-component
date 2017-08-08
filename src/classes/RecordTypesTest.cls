@isTest
private class RecordTypesTest {

    static List<RecordType> getRecordTypes(Schema.SObjectType sobjectType) {
        return [
            SELECT Id, DeveloperName, Name, NamespacePrefix, BusinessProcessId, IsActive
            FROM RecordType
            WHERE SObjectType = :sobjectType.getDescribe().getName()
            ORDER BY DeveloperName
        ];
    }

    @isTest
    static void allRecordTypesByIdTest() {
        Map<Id, RecordType> expectedRecordTypesById = new Map<Id, RecordType>();
        for(RecordType recordType : getRecordTypes(Schema.Account.SObjectType)) {
            expectedRecordTypesById.put(recordType.Id, recordType);
        }

        Test.startTest();

        Map<Id, RecordType> allAccountRecordTypesById = new RecordTypes(Schema.SObjectType.Account).getAllRecordTypesById();
        System.assertEquals(expectedRecordTypesById, allAccountRecordTypesById);

        Test.stopTest();
    }

    @isTest
    static void allRecordTypesByDeveloperNameTest() {
        List<RecordType> expectedRecordTypes = getRecordTypes(Schema.Account.SObjectType);

        Test.startTest();

        Map<String, RecordType> allAccountRecordTypesByDeveloperName = new RecordTypes(Schema.SObjectType.Account).getAllRecordTypesByDeveloperName();
        for(RecordType recordType : expectedRecordTypes) {
            System.assert(allAccountRecordTypesByDeveloperName.containsKey(recordType.DeveloperName));
        }

        Test.stopTest();
    }

    @isTest
    static void getRecordTypeByDeveloperNameTest() {
        final String recordTypeName = 'Prospecting';

        Id expectedRecordTypeId = Schema.Account.SObjectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).RecordTypeId;

        Test.startTest();

        Id recordTypeId = new RecordTypes(Schema.SObjectType.Account).getRecordTypeByDeveloperName(recordTypeName).Id;
        System.assertEquals(expectedRecordTypeId, recordTypeId);

        Test.stopTest();
    }    

    @isTest
    static void getDefaultRecordTypeTest() {

        Test.startTest();

        RecordTypes recordTypes = new RecordTypes(Schema.SObjectType.Account);
        System.assertNotEquals(null, recordTypes.getDefaultRecordType());
         /* FraCarma: Test the singleton design */
        System.assertNotEquals(null, recordTypes.getDefaultRecordType());

        Test.stopTest();
    }

    @isTest
    static void getRecordTypeByNameFailureTest() {
        final String fakeRecordTypeName = 'This is a fake record type name';

        Test.startTest();

        try {
            RecordType fakeRecordType = new RecordTypes(Schema.SObjectType.Account).getRecordTypeByDeveloperName(fakeRecordTypeName);
            System.assert(false, 'An exception should be thrown during the previous line - this assert makes sure that we throw an error');
        } catch(RecordTypes.RecordTypeException e) {
            String expectedErrorMessage = 'The record type \'' + fakeRecordTypeName + '\' was not found for ' + String.valueOf(Schema.Account.SObjectType.getDescribe().getLabel());
            System.assert(e.getMessage().contains(expectedErrorMessage));
        }

        Test.stopTest();
    }    

    @isTest
    static void getRecordTypeByIdTest() {
        final Id recordTypeId =  getRecordTypes(Schema.Account.SObjectType)[0].Id;

        Id expectedRecordTypeId = Schema.Account.SObjectType.getDescribe().getRecordTypeInfosById().get(recordTypeId).RecordTypeId;

        Test.startTest();

        Id retrievedRecordTypeId = new RecordTypes(Schema.SObjectType.Account).getRecordTypeById(recordTypeId).Id;
        System.assertEquals(expectedRecordTypeId, retrievedRecordTypeId);

        Test.stopTest();
    }

    @isTest
    static void getRecordTypeByIdFailureTest() {
        final Id fakeRecordTypeId = '0A25E0000000C8D';

        Test.startTest();

        try {
            RecordType fakeRecordType = new RecordTypes(Schema.SObjectType.Account).getRecordTypeById(fakeRecordTypeId);
            System.assert(false, 'An exception should be thrown during the previous line - this assert makes sure that we throw an error');
        } catch(RecordTypes.RecordTypeException e) {
            String expectedErrorMessage = 'The record type \'' + fakeRecordTypeId + '\' was not found for ' + String.valueOf(Schema.Account.SObjectType.getDescribe().getLabel());
            System.assert(e.getMessage().contains(expectedErrorMessage));
        }

        Test.stopTest();
    }

    @isTest
    static void cacheQueryTest() {
        //The record type query in RecordTypes should only be executed once & then cached
        Test.startTest();

        System.assertEquals(0, Limits.getQueries());

        RecordTypes accountRecordTypes = new RecordTypes(Schema.SObjectType.Account);

        Integer loopsToMake = 10;
        Integer loopCount = 0;
        for(Integer i = 0; i < loopsToMake; i++) {
            Boolean result = accountRecordTypes.getAllRecordTypesById().keySet().isEmpty();
            loopCount++;
        }

        System.assertEquals(loopsToMake, loopCount);
        System.assertEquals(1, Limits.getQueries());

        Test.stopTest();
    }

    @isTest
    static void cacheSObjectTypeTest() {
        //The SObject type can only be cached once - an error is thrown if the same SObject type is cached multiple times

        //Call one of the constants in AccountRecordTypes so that the account object's record types are cached
        System.assertEquals(0, Limits.getQueries());
        System.debug(AccountRecordTypes.ALL_RECORD_TYPES);
        System.assertEquals(1, Limits.getQueries());

        Test.startTest();

        RecordTypes duplicateAccountRecordTypes = new RecordTypes(Schema.SObjectType.Account);


        Test.stopTest();
    }

}