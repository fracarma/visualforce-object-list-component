@isTest
private class ObjectListComponentControllerTest {

    @testSetup
    static void setupData() {
        
        Account acc = TestDataGenerator.createAccount();
        insert acc;

        insert TestDataGenerator.createContact(acc.Id);
        insert TestDataGenerator.createContact(acc.Id);
        insert TestDataGenerator.createContact(acc.Id);
    }

    @isTest
    static void loadComponent() {
    	Account[] accList = [SELECT Id FROM Account  LIMIT 1];
    	Account acc = (accList.size() > 0)? accList[0] : null;
    	ObjectListComponentController controller = new ObjectListComponentController();

    	controller.orderByJSON = '{"fieldName" : "Name", "order" : "DESC"}';
    	controller.parentObjectId = acc.Id;
    	controller.fieldToShowInSectionTitleString = 'Name';
    	controller.childObjectTypeString = 'Contact';
    	controller.lookupFieldString = 'AccountId';

    }     

    @isTest
    static void tryCatchTest() {
    	Account[] accList = [SELECT Id FROM Account  LIMIT 1];
    	Account acc = (accList.size() > 0)? accList[0] : null;
    	ObjectListComponentController controller = new ObjectListComponentController();

    	controller.orderByJSON = '{%$&/"fieldName" : "Name", "order" : "DESC"}';
    	controller.parentObjectId = acc.Id;
    	controller.fieldToShowInSectionTitleString = 'Name';
    	controller.childObjectTypeString = 'Contact';
    	controller.lookupFieldString = 'AccountId';

    	controller.restorechildObject();
    	controller.removechildObject();
    	controller.savechildObjectMap();
    }        

    @isTest
    static void testRemoveAndRestoreMethods() {
    	Account[] accList = [SELECT Id FROM Account  LIMIT 1];
    	Account acc = (accList.size() > 0)? accList[0] : null;
    	ObjectListComponentController controller = new ObjectListComponentController();

    	controller.parentObjectId = acc.Id;
    	controller.fieldToShowInSectionTitleString = 'Name';
    	controller.childObjectTypeString = 'Contact';
    	controller.lookupFieldString = 'AccountId';

    	controller.initExistingchildObject();
    	
    	Integer childObjectMapSize = controller.childObjectMap.size();
    	controller.childObjectToRemoveKey = 0;
    	controller.removechildObject();
    	System.assertEquals(childObjectMapSize, controller.childObjectMap.size());
    	controller.childObjectToRestoreKey = 0;
    	controller.restorechildObject();

    	controller.createNewchildObject();
    	childObjectMapSize = controller.childObjectMap.size();
    	controller.childObjectToRemoveKey = childObjectMapSize - 1;
    	controller.removechildObject();
    	System.assertNotEquals(childObjectMapSize, controller.childObjectMap.size());
    }    
    
    @isTest
    static void testSaveMethod() {
    	Account[] accList = [SELECT Id FROM Account  LIMIT 1];
    	Account acc = (accList.size() > 0)? accList[0] : null;
    	ObjectListComponentController controller = new ObjectListComponentController();

    	controller.parentObjectId = acc.Id;
    	controller.fieldToShowInSectionTitleString = 'Name';
    	controller.childObjectTypeString = 'Contact';
    	controller.lookupFieldString = 'AccountId';

    	controller.initExistingchildObject();
    	controller.savechildObjectMap();
    	
    	Integer childObjectMapSize = controller.childObjectMap.size();
    	controller.childObjectToRemoveKey = 0;
    	controller.removechildObject();

    	controller.createNewchildObject();

    	try {
    		controller.savechildObjectMap();
    	} catch(Exception e) {
    		System.debug(e.getMessage());
    	}

    	childObjectMapSize = controller.childObjectMap.size();
    	Contact contact = (Contact) controller.childObjectMap.get(childObjectMapSize -1).childObject;
    	contact.accountId = acc.Id;
    	contact.LastName = 'Test last name';

    	controller.savechildObjectMap();
    }      

    @isTest
    static void testEditAndCancel() {
    	Account[] accList = [SELECT Id FROM Account  LIMIT 1];
    	Account acc = (accList.size() > 0)? accList[0] : null;
    	ObjectListComponentController controller = new ObjectListComponentController();

    	controller.parentObjectId = acc.Id;
    	controller.fieldToShowInSectionTitleString = 'Name';
    	controller.childObjectTypeString = 'Contact';
    	controller.lookupFieldString = 'AccountId';

    	controller.initExistingchildObject();
    	
    	controller.enterEditMode();
    	System.assertEquals(true,controller.isEditMode);
    	controller.cancel();
    	System.assertEquals(false,controller.isEditMode);

    	controller.childObjectMap.clear();
    	delete [SELECT Id FROM Contact];
    	controller.initExistingchildObject();

    	System.assertEquals(0, controller.childObjectMap.size());
    	controller.enterEditMode();
    	System.assertEquals(1, controller.childObjectMap.size());
    }      

    @isTest 
    static void testOtherMethods() {
    	Account[] accList = [SELECT Id FROM Account  LIMIT 1];
    	Account acc = (accList.size() > 0)? accList[0] : null;
    	ObjectListComponentController controller = new ObjectListComponentController();

    	controller.parentObjectId = acc.Id;
    	controller.fieldToShowInSectionTitleString = 'Name';
    	controller.childObjectTypeString = 'Contact';
    	controller.lookupFieldString = 'AccountId';

    	controller.initExistingchildObject();
    	
    	controller.refreshFieldKey = 0;
    	controller.refreshFieldList();

    }    

    @isTest
    static void testGetterSetters() {
    	Account[] accList = [SELECT Id FROM Account  LIMIT 1];
    	Account acc = (accList.size() > 0)? accList[0] : null;
    	ObjectListComponentController controller = new ObjectListComponentController();

    	controller.parentObjectId = acc.Id;
    	controller.parentObjectId = acc.Id;
    	controller.lookupFieldString = 'AccountId';
    	controller.fieldToShowInSectionTitleString = 'Name';
    	controller.childObjectTypeString = 'Contact';
    	controller.childObjectTypeString = 'Contact';
    	controller.fieldToShowInSectionTitleString = 'Name';
    	controller.lookupFieldString = 'AccountId';

    	system.debug(controller.isChildObjectMapEmpty);
    }    


}