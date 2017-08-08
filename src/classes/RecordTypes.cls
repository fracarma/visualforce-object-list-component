public without sharing class RecordTypes {

    private static Set<String> cachedSObjectTypes = new Set<String>();

    private Map<Id, RecordType> allRecordTypesById;
    private Map<String, RecordType> allRecordTypesByDeveloperName;
    private String sobjectLabel, sobjectName;
    private Schema.DescribeSObjectResult sobjectResult;
    private RecordType defaultRecordType;

    private static Map<Schema.DescribeSObjectResult, RecordTypes> instanceMap = null;

    public static RecordTypes getInstance(Schema.DescribeSObjectResult sobjectResult){
        if(instanceMap == null){
            instanceMap = new Map<Schema.DescribeSObjectResult, RecordTypes>();
        }
        if(instanceMap.containsKey(sobjectResult)){
            return instanceMap.get(sobjectResult);
        }
        RecordTypes instance = new RecordTypes(sobjectResult);
        instanceMap.put(sobjectResult, instance);
        return instance;
    }

    public RecordTypes(Schema.DescribeSObjectResult sobjectResult) {
        this.sobjectLabel  = sobjectResult.getLabel();
        this.sobjectName   = sobjectResult.getName();
        this.sobjectResult = sobjectResult;

        this.allRecordTypesById = this.getAllRecordTypesById();
        this.allRecordTypesByDeveloperName = this.getAllRecordTypesByDeveloperName();
    }

    public Map<Id, RecordType> getAllRecordTypesById() {
        if(this.allRecordTypesById == null) {
            this.allRecordTypesById = new Map<Id, RecordType>(this.getAllRecordTypes());
        }

        return this.allRecordTypesById;
    }

    public Map<String, RecordType> getAllRecordTypesByDeveloperName() {
        if(this.allRecordTypesByDeveloperName == null) {
            this.allRecordTypesByDeveloperName = new Map<String, RecordType>();

            for(RecordType recordType : this.allRecordTypesById.values()) {
                this.allRecordTypesByDeveloperName.put(recordType.DeveloperName, recordType);
            }
        }

        return this.allRecordTypesByDeveloperName;
    }

    public RecordType getRecordTypeByDeveloperName(String recordTypeDeveloperName) {
        if(!getAllRecordTypesByDeveloperName().containsKey(recordTypeDeveloperName)) {
            throw new RecordTypeException('The record type \'' + recordTypeDeveloperName + '\' was not found for ' + this.sobjectLabel);
        }

        return this.getAllRecordTypesByDeveloperName().get(recordTypeDeveloperName);
    }    

    public RecordType getRecordTypeById(Id recordTypeId) {
        if(!getAllRecordTypesById().containsKey(recordTypeId)) {
            throw new RecordTypeException('The record type \'' + recordTypeId + '\' was not found for ' + this.sobjectLabel);
        }

        return this.getAllRecordTypesById().get(recordTypeId);
    }

    public RecordType getDefaultRecordType(){
        if(defaultRecordType != null){
            return defaultRecordType;
        }
        Map<Id,Schema.RecordTypeInfo> rtMapById = sobjectResult.getRecordTypeInfosById();
        for(Id key: rtMapById.keySet()){
            if(rtMapById.get(key).isDefaultRecordTypeMapping()){
                defaultRecordType = allRecordTypesById.get(key);
                return defaultRecordType;
            }
        }

        return null;
    }

  
    private List<RecordType> getAllRecordTypes() {
        return [
            SELECT Id, DeveloperName, Name, NamespacePrefix, BusinessProcessId, IsActive
            FROM RecordType
            WHERE SObjectType = :this.sobjectName
            ORDER BY DeveloperName
        ];
    }

    @testVisible
    private class RecordTypeException extends Exception {}

}