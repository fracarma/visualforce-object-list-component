public with sharing class ObjectListComponentController {

    public Id parentObjectId {get;set{
            parentObjectId = value;
            initExistingchildObject();
        }
    }
 
    public Schema.SObjectType childObjectType;
    public Schema.SObjectField lookupField;

    public Boolean hasRecordTypes {get; private set;}
    private Id defaultRecordTypeId;

    public Boolean isInitialized = false;
    
    public String childObjectTypeString {get;set {
            childObjectTypeString = value;
            childObjectType = Schema.getGlobalDescribe().get(childObjectTypeString);
            childObjectSingleLabel = childObjectType.getDescribe().getLabel();
            childObjectPluralLabel = childObjectType.getDescribe().getLabelPlural();

            RecordTypes recordTypesInstance = RecordTypes.getInstance(childObjectType.getDescribe());
            hasRecordTypes = recordTypesInstance.getAllRecordTypesById().size() > 0;
            initExistingchildObject();
        }
    }
    public String lookupFieldString {get;set{
            lookupFieldString = value;
            if(childObjectType == null){
                return;
            }

            lookupField = childObjectType.getDescribe().fields.getMap().get(lookupFieldString);

            initExistingchildObject();

        }
    }

    public Map<Integer,wrapper> childObjectMap {get;set;}
    public Integer childObjectToRemoveKey {get;set;}
    public Integer childObjectToRestoreKey {get;set;}
    public Integer refreshFieldKey {get;set;}
    public Boolean isEditMode {get;private set;}
    public Map<String,Boolean> userPermissionMap            {get; private set;}
    public String fieldSetToUseName {get; set;}
    public String orderByJSON {get; set;}
    public String childObjectSingleLabel {get; private set;}
    public String childObjectPluralLabel {get; private set;}
    
    public String fieldToShowInSectionTitleString {get;set {
            fieldToShowInSectionTitleString = value;
            if(fieldToShowInSectionTitleStringList != null){
                return;
            }

            fieldToShowInSectionTitleStringList = fieldToShowInSectionTitleString.split(',');

        }
    }
    private String[] fieldToShowInSectionTitleStringList;

    public Boolean isChildObjectMapEmpty {get {
            if(childObjectMap == null){
                return true;
            }
            return childObjectMap.size() == 0;
        } 

        private set;
    }

    
    List<SObject> childObjectToDeleteList = new List<SObject>();
    List<SObject> childObjectToUpdateList = new List<SObject>();
    List<SObject> childObjectToInsertList = new List<SObject>();


    // The extension constructor initializes the private member
    // variable parentObject by using the getRecord method from the standard
    // controller.
    public ObjectListComponentController() {
        
        //initExistingchildObject();
    }

     /*******************************************************************************************************
    * @description Build the map with all the existing Addtional childObject already existing in the followUp
    */
    @TestVisible
    private void initExistingchildObject() {
        
        if(!(parentObjectId != null && lookupField != null && childObjectType != null && !isInitialized && fieldToShowInSectionTitleStringList != null)){
            return;
        }

        populatePermissionMap();

        childObjectMap = new Map<Integer,wrapper>();
        Integer key = 0;
        Set<String> fieldNameSet = new Set<String>();
        Map<String, Schema.FieldSet> fieldSetMap = childObjectType.getDescribe().fieldSets.getMap();
        for(Schema.FieldSet fieldSet: fieldSetMap.values()){
            for(Schema.FieldSetMember field: fieldSet.getFields()){
                fieldNameSet.add(field.getFieldPath());
            }
        }

        fieldNameSet.add('Name');

        for(String fieldToShowInSectionTitleString: fieldToShowInSectionTitleStringList){
            fieldNameSet.add(fieldToShowInSectionTitleString);
        }
        
        if(hasRecordTypes){
            fieldNameSet.add('RecordTypeId');
            fieldNameSet.add('RecordType.DeveloperName');
            fieldNameSet.add('RecordType.Name');
        }

         /* FraCarma: unlike inline SOQL, dynamic SOQL can’t use bind variable fields in the query string */
        String parentObjectIdString = String.valueOf(parentObjectId);
        
        String query = SOQLUtils.createQuery(fieldNameSet, childObjectType.getDescribe().getName() , lookupField.getDescribe().getName()+' =: parentObjectIdString');
        if(orderByJSON != null){
            try {
                orderByJSON = orderByJSON.replace('\'', '\"');
                Map<String,Object> orderByParsed = (Map<String,Object>) JSON.deserializeUntyped(orderByJSON); 
                query += ' ORDER BY ' + orderByParsed.get('fieldName');

                if(orderByParsed.containsKey('order')){
                    String asdOrDesc = String.valueOf(orderByParsed.get('order'));
                    query += (asdOrDesc == 'ASC') ? ' ASC' :
                                (asdOrDesc == 'DESC') ? ' DESC' :
                                '';
                }
                
            } catch (Exception e) {
                system.debug('@@Exception on '+e.getStackTraceString()+' : '+e.getMessage());
            }
        }
        
        system.debug('@@query: '+query);

        for(SObject existingchildObject: Database.query(query)){
            childObjectMap.put(key, new wrapper(existingchildObject,
                childObjectType,
                lookupField,
                hasRecordTypes,
                defaultRecordTypeId,
                fieldSetToUseName,
                fieldToShowInSectionTitleStringList));
            key++;
        }

        isInitialized = true;
    }

    private void populatePermissionMap(){
        ObjectPermissionHandler currentUserPermission = ObjectPermissionHandler.getInstance();
        userPermissionMap = currentUserPermission.getUserPermissionMap().get(childObjectType.getDescribe().getName());
    }

         /*******************************************************************************************************
        * @description Create a new childObject on the panel. Simply create a new istance of the wrapper and put it in the map as last element.
        * @return PageReference = null.
        */
    public PageReference createNewchildObject(){
        try {
            Integer key = childObjectMap.size();
            childObjectMap.put(key, new wrapper(parentObjectId, 
                childObjectType,
                lookupField,
                hasRecordTypes,
                defaultRecordTypeId,
                fieldSetToUseName,
                fieldToShowInSectionTitleStringList));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('@@Exception on '+e.getStackTraceString()+' : '+e.getMessage());
        }
        return null;
    }

     /*******************************************************************************************************
        * @description Remove the childObject. The parameter "childObjectToRemoveKey" is provided by the VisualForce.
        *                  If the childObject is not already be inserted and nothing is written in the "Action Type"
                            field the element is removed from the map.
                            In other case, the field toBeCancelled is set to TRUE.
        *
        * @return PageReference = null.
        */
    public PageReference removechildObject(){
        try {
            Wrapper w = childObjectMap.get(childObjectToRemoveKey);
             /* FraCarma: If it is new and blank, I remove it from the map */
            if(!w.toBeUpdated){
                childObjectMap.remove(childObjectToRemoveKey);
                return null;
            }

            w.toBeCancelled = true;

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('@@Exception on '+e.getStackTraceString()+' : '+e.getMessage());
        }
        return null;
    }

      /*******************************************************************************************************
        * @description Restore the childObject. The parameter "childObjectToRestoreKey" is provided by the VisualForce.
        *                  The field toBeCancelled is set to FALSE for the element "childObjectToRestoreKey" of the map.
        *
        * @return PageReference = null.
        */
    public PageReference restorechildObject(){
        try {
            childObjectMap.get(childObjectToRestoreKey).toBeCancelled = false;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('@@Exception on '+e.getStackTraceString()+' : '+e.getMessage());
        }
        return null;
    }

     /**
        * @description Override the standard Save method. Here, some validation are performed on childObjects and finally
        *                are inserted or updated. The standardController is saved too, by its standard method.
        */
    public PageReference savechildObjectMap(){
        
        removeToBeDeletedRecords();
        fillUpsertLists();
        try {
            insert childObjectToInsertList;
            update childObjectToUpdateList;
            delete childObjectToDeleteList;
        } catch (System.DmlException e){
            for (Integer i = 0; i < e.getNumDML(); i++) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getDmlMessage(i)));
            }
            system.debug('@@Exception on '+e.getStackTraceString()+' : '+e.getMessage());
            return null;

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            system.debug('@@Exception on '+e.getStackTraceString()+' : '+e.getMessage());
            return null;
        }
        this.isEditMode = false;
        this.isInitialized = false;
        initExistingchildObject();
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Records saved!'));

        return null;
    }

    public PageReference enterEditMode(){
        this.isEditMode = true;
        if(childObjectMap.size() == 0){
            createNewchildObject();
        }
        return null;
    }    

    public PageReference cancel(){
        this.isEditMode = false;
        this.isInitialized = false;
        initExistingchildObject();
        return null;
    }

    public PageReference refreshFieldList(){
        childObjectMap.get(refreshFieldKey).refreshFieldList();
        return null;
    }

      /**
    *
    * @description Wrapper to add infos on the SObject records.
    */
    public class Wrapper{
        public SObject childObject {get;set;}
        
        /**
        * If TRUE, the SObject during the save procedure will be deleted from DB records 
        */
        public Boolean toBeCancelled {get;set;}
        
        /**
        * If TRUE, the SObject has already been inserted and has been retrieved by a query
        */
        public Boolean toBeUpdated {get;set;}

        public Schema.FieldSetMember[] fieldList {get; private set;}
        public String sectionTitle {get; private set;}

        private Schema.SObjectType childObjectType;
        private Schema.SObjectField lookupField;
        private Boolean hasRecordTypes;
        private Id defaultRecordTypeId;
        private String fieldSetToUseName;
        private String[] fieldToShowInSectionTitleStringList;

   

        public wrapper(Id parentObjectId, Schema.SObjectType childObjectType,
         Schema.SObjectField lookupField,
         Boolean hasRecordTypes,
         Id defaultRecordTypeId,
         String fieldSetToUseName,
         String[] fieldToShowInSectionTitleStringList){
            this.childObject = childObjectType.newSObject();
            this.childObject.put(lookupField,parentObjectId);

            if(hasRecordTypes){
                RecordTypes recordTypesInstance = RecordTypes.getInstance(childObjectType.getDescribe());
                RecordType recordType = recordTypesInstance.getDefaultRecordType();
                if(recordType != null){
                    this.childObject.put('RecordTypeId', recordType.Id);
                }
            }
            this.fieldSetToUseName = fieldSetToUseName;             
            this.childObjectType = childObjectType; 
            this.lookupField = lookupField; 
            this.hasRecordTypes = hasRecordTypes; 
            this.defaultRecordTypeId = defaultRecordTypeId; 
            this.fieldToShowInSectionTitleStringList = fieldToShowInSectionTitleStringList;

            this.toBeCancelled = false;
            this.toBeUpdated = false;
            
            this.fieldList = getFields();
            this.sectionTitle = setSectionTitle();

            
        }

         /* FraCarma: childObject already present in DB */
        public wrapper(SObject childObject,
            Schema.SObjectType childObjectType,
         Schema.SObjectField lookupField,
         Boolean hasRecordTypes,
         Id defaultRecordTypeId,
         String fieldSetToUseName,
         String[] fieldToShowInSectionTitleStringList){

            this.childObjectType = childObjectType; 
            this.lookupField = lookupField; 
            this.hasRecordTypes = hasRecordTypes; 
            this.defaultRecordTypeId = defaultRecordTypeId; 
            this.fieldSetToUseName = fieldSetToUseName; 
            this.childObject = childObject;
            this.fieldToShowInSectionTitleStringList = fieldToShowInSectionTitleStringList;
            
            this.toBeCancelled = false;
            this.toBeUpdated = true;
            
            this.fieldList = getFields();
            this.sectionTitle = setSectionTitle();
        }

        public void refreshFieldList(){
            this.fieldList = getFields();
        }

        private Schema.FieldSetMember[] getFields(){
            List<Schema.FieldSetMember> fieldList = new List<Schema.FieldSetMember>();
            
            if(!hasRecordTypes){
                return fieldList;
            }
            
            Map<String, Schema.FieldSet> fieldSetMap = childObjectType.getDescribe().fieldSets.getMap();

            if(fieldSetToUseName != null){
                if(!fieldSetMap.containsKey(fieldSetToUseName)){
                    system.debug('@@There is no fieldset named '+fieldSetToUseName+' for the object '+childObjectType.getDescribe().getName());
                    return fieldList;
                }
                fieldList.addAll(fieldSetMap.get(fieldSetToUseName).getFields());
                return fieldList;
            }

            Id recordTypeId = (Id) this.childObject.get('RecordTypeId');
            if(recordTypeId == null){
                return fieldList;
            }
            RecordTypes recordTypesInstance = RecordTypes.getInstance(childObjectType.getDescribe());
            RecordType recordType = recordTypesInstance.getRecordTypeById(recordTypeId);
            String recordTypeDeveloperName = (String) RecordType.get('DeveloperName');


            if(!fieldSetMap.containsKey(recordTypeDeveloperName)){
                system.debug('@@ I cannot find the fieldSet for the record type: '+recordTypeDeveloperName +' in fieldSetMap: '+fieldSetMap);
                return fieldList;
            }
            fieldList.addAll(fieldSetMap.get(recordTypeDeveloperName).getFields());
            return fieldList;
        }

        private String setSectionTitle(){
            String sectionTitle = '';
            if(fieldToShowInSectionTitleStringList == null || childObject == null){
                return sectionTitle;
            }
            for(String fieldToShowInSectionTitleString: fieldToShowInSectionTitleStringList){
                try {
                    String[] splittedfieldList = fieldToShowInSectionTitleString.split('\\.');
                    Object fieldValue;
                    if(splittedfieldList.size() > 1) {
                        sObject parentObject = childObject.getSObject(splittedfieldList[0]);
                        fieldValue = parentObject.get(splittedfieldList[1]);
                    } else {
                        fieldValue = childObject.get(fieldToShowInSectionTitleString);
                    }

                    String fieldValueString = (fieldValue != null) ? String.valueOf(fieldValue) : '';
                    sectionTitle += fieldValueString;
                    sectionTitle += '  ';
                } catch (Exception e) {
                    system.debug('@@Exception on '+e.getStackTraceString()+' : '+e.getMessage());
                }
            }

            sectionTitle = sectionTitle.removeEnd('  ');
            return sectionTitle;

        }
    }

         /*******************************************************************************************************
        * @description Looping on the childObjectMap map, every element where toBeCancelled is TRUE and is not in the DB
                     is simply removed from the map. If the element is in the DB, is inserted in the childObjectToDeleteList.
        */
    void removeToBeDeletedRecords(){
        childObjectToDeleteList.clear();
        for(Integer key: childObjectMap.keySet()){
            Wrapper w = childObjectMap.get(key);

            if(w.toBeCancelled && w.toBeUpdated){
                childObjectToDeleteList.add(w.childObject);
            }

            if(w.toBeCancelled){
                childObjectMap.remove(key);
            }
        }
    }

     /*******************************************************************************************************
        * @description Depending on toBeUpdated field, the element of the map is added to childObjectToUpdateList or 
                        childObjectToInsertList list
        */
    void fillUpsertLists(){
        childObjectToInsertList.clear();
        childObjectToUpdateList.clear();

        for(Integer key: childObjectMap.keySet()){
            Wrapper w = childObjectMap.get(key);
            if(w.toBeUpdated && !w.toBeCancelled){
                childObjectToUpdateList.add(w.childObject);
            }
            if(!w.toBeUpdated && !w.toBeCancelled){
                childObjectToInsertList.add(w.childObject);
            }

        }

    }

}