public with sharing class MapUtils {

	 /*******************************************************************************************************
	    * @description create a map indexed by a field from a list of SObject
	    * @param listOfObjects the list of SObject that will be used to generate the map
	    * @param fieldToBeIndexed the API Name of the SObject field that will be used for indexing
	    * @return a map of type Map<String,SObject> which contains the indexed element of listOfObjects
	    * @example
	    *	Validate_Opportunity__mdt configList = [SELECT MasterLabel, Connectivity_Product_uniqueness__c, Opportunity_Uniqueness__c, Valid_Customer_Connectivity__c FROM Validate_Opportunity__mdt];
		*	Map<String, sObject> configMap = mapUtils.createMapOfObjects(configList, 'MasterLabel');
		*	Validate_Opportunity__mdt config = (Validate_Opportunity__mdt) configMap.get('XML');
	    */
	public static Map<String,SObject> createMapOfObjects(SObject[] listOfObjects, String fieldToBeIndexed){


		Map<String,SObject> res = new Map<String, SObject>();

		if(listOfObjects == null || listOfObjects.size() == 0){
			return res;
		}

		if(String.isBlank(fieldToBeIndexed)){
			throw new customException('An index field API Name have to be provided');
		}


		for(SObject el: listOfObjects){

			String elStringToIndex = (String) el.get(fieldToBeIndexed);

			if(elStringToIndex == null){
				throw new customException('the index field '+ fieldToBeIndexed +' is null for the element: ' + el.Id);
			}
			res.put(elStringToIndex,el);
		}

		return res;
	}
}