/**
* @File Name : CustomViewRecordController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : April 18, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 18, 2025 |   | Initial Version
**/

public with sharing class CustomViewRecordController {
	
    @AuraEnabled(cacheable=true)
	public static List<String> getFieldSetFields(String objectName, String fieldSetName) {
        List<String> fieldNames = new List<String>();
        
        // Check if user has read access to the object
        if (!Schema.getGlobalDescribe().get(objectName).getDescribe().isAccessible()) {
            throw new AuraHandledException('Insufficient access to object: ' + objectName);
        }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType != null) {
            Schema.DescribeSObjectResult describeResult = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
            Schema.FieldSet fieldSet = describeResult.fieldSets.getMap().get(fieldSetName);
            if (fieldSet != null) {
                for (Schema.FieldSetMember f : fieldSet.getFields()) {
                    fieldNames.add(f.getFieldPath());
                }
            }
        }
        return fieldNames;
    }

    @AuraEnabled(cacheable=true)
	public static Child_Opportunity__c getRecordByOppId(String oppId) {
        // Check if user has read access to Child_Opportunity__c object
        if (!Schema.sObjectType.Child_Opportunity__c.isAccessible()) {
            throw new AuraHandledException('Insufficient access to Child_Opportunity__c object');
        }
        
        List<Child_Opportunity__c> childOppList =  [ SELECT Id
                                        FROM Child_Opportunity__c
                                        WHERE Opportunity__c = :oppId
                                        LIMIT 1];
        
        if(childOppList <> null && !childOppList.isEmpty()){
            return childOppList[0];
        }
        else{
            return null;
        }
    }

    @AuraEnabled
    public static Id saveRecord(String objectName, Map<String, Object> fieldValues, String oppId) {
        // Check if user has create/update access to the object
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType == null) {
            throw new AuraHandledException('Invalid object name: ' + objectName);
        }
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        if (!describeResult.isCreateable() && !describeResult.isUpdateable()) {
            throw new AuraHandledException('Insufficient access to create/update object: ' + objectName);
        }
        
        SObject record = (SObject) Type.forName('Schema', objectName).newInstance();

        for (String key : fieldValues.keySet()) {
            record.put(key, fieldValues.get(key));
        }
        record.put('Opportunity__c',oppId);

        // Perform DML operation with Security class validation
        List<SObject> recordsToProcess = new List<SObject>{record};
        
        if (record.Id != null) {
            // Update operation - use Security.stripInaccessible for validation
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, recordsToProcess);
            update decision.getRecords();
        } else {
            // Insert operation - use Security.stripInaccessible for validation
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, recordsToProcess);
            insert decision.getRecords();
        }
        return record.Id;
    }
}