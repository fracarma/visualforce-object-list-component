@isTest
private class MapUtilsTest {

	@isTest
	private static void createMapOfObjectsTest() {
		List<Account> sObjectList = new List<Account>();
		Account a1 = AccountUtils.createDefaultTestAccount();
		Account a2 = AccountUtils.createDefaultTestAccount();

		insert a1;
		insert a2;
		List<Opportunity> oppList = new List<Opportunity>();
		
		for(Integer i = 0; i < 10; i++) {
			Opportunity opp = OpportunityUtils.createDefaultTestOpportunity();
			opp.AccountId = a1.Id;
			oppList.add(opp);
		}
		for(Integer i = 0; i < 5; i++) {
			Opportunity opp = OpportunityUtils.createDefaultTestOpportunity();
			opp.AccountId = a2.Id;
			oppList.add(opp);
		}
		
		Map<String,sObject> mapResBlank = mapUtils.createMapOfObjects(null, 'AccountId');
		System.assertEquals(0, mapResBlank.keyset().size());
		
		Map<String,sObject> mapRes = mapUtils.createMapOfObjects(oppList, 'AccountId');
		System.assertNotEquals(null, mapRes.get(a1.Id));
		System.assertNotEquals(null, mapRes.get(a2.Id));

	}

	@isTest
	private static void createMapOfObjectsTestToFail() {
		List<Account> sObjectList = new List<Account>();
		Account a1 = AccountUtils.createDefaultTestAccount();
		Account a2 = AccountUtils.createDefaultTestAccount();

		insert a1;
		insert a2;
		List<Opportunity> oppList = new List<Opportunity>();
		
		for(Integer i = 0; i < 10; i++) {
			Opportunity opp = OpportunityUtils.createDefaultTestOpportunity();
			opp.AccountId = a1.Id;
			oppList.add(opp);
		}
		for(Integer i = 0; i < 5; i++) {
			Opportunity opp = OpportunityUtils.createDefaultTestOpportunity();
			opp.AccountId = a2.Id;
			oppList.add(opp);
		}

		Boolean res = false;
		try{
			Map<String,sObject> mapRes = mapUtils.createMapOfObjects(oppList, '');
		} catch(CustomException e){
			res = true;
		}

		System.assertEquals(true, res);

		res = false;
		
		try {
			oppList[0].AccountId = null;
			Map<String,sObject> mapRes = mapUtils.createMapOfObjects(oppList, 'AccountId');
		} catch (CustomException e) {
			system.debug('@@Exception on '+e.getStackTraceString()+' : '+e.getMessage());
			res = true;
		}
		System.assertEquals(true, res);

	}
}