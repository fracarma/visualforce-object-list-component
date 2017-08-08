public without sharing class SOQLUtils {

	public static String createQuery(Set<String> fieldNameList, String objectName){
		return createQuery(fieldNameList,objectName,null);
	}

	public static String createQuery(Set<String> fieldNameList, String objectName, String whereClause) {
		if(objectName == null){
			throw new customException('objectName cannot be null');
		}
		if(fieldNameList == null){
			throw new customException('fieldNameList cannot be null');
		}
		if(fieldNameList.size() == 0){
			fieldNameList.add('Id');
		}
		String query = 'SELECT ';
		for(Object fieldName: fieldNameList){
			query += fieldName + ',';
		}
		query = query.removeEnd(',');
		query += ' FROM '+objectName;
		
		if(whereClause == null){
			return query;
		}

		query += ' WHERE '+whereClause;

		return query;
	}

}