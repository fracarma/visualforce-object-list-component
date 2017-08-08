# Visualforce Object List Component

VF Component useful for display and CRUD on records. The fields displayed for every records can be defined in one fieldset or more,
controlled by the record type. If one fieldset is needed, the name of the fieldset for the child object has to be declared in the parameter
__fieldSet__. If this parameter is not defined, the component will search for fieldsets with the same API Name of the record Type.

## Example

It works for standard objects:

```
	  <c:ObjectListComponent parentRecordId="{!AccountId}" 
		  childsObjectType="{!$ObjectType.Contact.name}" 
		  childToParentLookupField="{!$ObjectType.Contact.Fields.AccountId.name}"
		  allowChangeRecordTypeForExistingRecords="false"
		  fieldsToShowInSectionTitle="Name"
		  showName="true"/>
```

But also with custom fields/objects:

```
	<c:ObjectListComponent parentRecordId="{!Summary__c.Id}" 
		childsObjectType="{!$ObjectType.Growth_Alert__c.name}" 
		childToParentLookupField="{!$ObjectType.Growth_Alert__c.Fields.Summary__c.name}"
		addRecordType="false"
    fieldSet="field_set_Name"
		allowChangeRecordTypeForExistingRecords="false"
		fieldsToShowInSectionTitle="Name"
		showName="true"
    tableFormat="false"
    orderBy="CreatedDate"
    showButtons="true"
	/>
```

## TODO

1. Describe all the parameters in the README
1. Add some pictures
