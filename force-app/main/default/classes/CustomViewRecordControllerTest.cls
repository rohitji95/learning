/**
* @File Name : CustomViewRecordControllerTest.cls
* @Description : Test class for CustomViewRecordController
* @Author : Test Author
* @Last Modified By : Test Author
* @Last Modified On : April 18, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 18, 2025 | Test Author | Initial Version
**/

@isTest
public class CustomViewRecordControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Create test Child_Opportunity__c record
        Child_Opportunity__c testChildOpp = new Child_Opportunity__c(
            Opportunity__c = testOpp.Id,
            Name = 'Test Child Opportunity'
        );
        insert testChildOpp;
    }
    
    @isTest
    static void testGetFieldSetFieldsSuccess() {
        // Test with Account object and a valid field set
        Test.startTest();
        List<String> fieldNames = CustomViewRecordController.getFieldSetFields('Account', 'Standard');
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, fieldNames, 'Field names list should not be null');
        System.assert(fieldNames instanceof List<String>, 'Should return a list of strings');
    }
    
    @isTest
    static void testGetFieldSetFieldsInvalidObject() {
        // Test with invalid object name
        Test.startTest();
        List<String> fieldNames = CustomViewRecordController.getFieldSetFields('InvalidObject', 'Standard');
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, fieldNames, 'Field names list should not be null');
        System.assertEquals(0, fieldNames.size(), 'Should return empty list for invalid object');
    }
    
    @isTest
    static void testGetFieldSetFieldsInvalidFieldSet() {
        // Test with valid object but invalid field set
        Test.startTest();
        List<String> fieldNames = CustomViewRecordController.getFieldSetFields('Account', 'InvalidFieldSet');
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, fieldNames, 'Field names list should not be null');
        System.assertEquals(0, fieldNames.size(), 'Should return empty list for invalid field set');
    }
    
    @isTest
    static void testGetFieldSetFieldsNullParameters() {
        // Test with null parameters
        Test.startTest();
        List<String> fieldNames1 = CustomViewRecordController.getFieldSetFields(null, 'Standard');
        List<String> fieldNames2 = CustomViewRecordController.getFieldSetFields('Account', null);
        List<String> fieldNames3 = CustomViewRecordController.getFieldSetFields(null, null);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, fieldNames1, 'Field names list should not be null');
        System.assertNotEquals(null, fieldNames2, 'Field names list should not be null');
        System.assertNotEquals(null, fieldNames3, 'Field names list should not be null');
        System.assertEquals(0, fieldNames1.size(), 'Should return empty list for null object name');
        System.assertEquals(0, fieldNames2.size(), 'Should return empty list for null field set name');
        System.assertEquals(0, fieldNames3.size(), 'Should return empty list for null parameters');
    }
    
    @isTest
    static void testGetRecordByOppIdExistingRecord() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        Test.startTest();
        Child_Opportunity__c result = CustomViewRecordController.getRecordByOppId(testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Should return a Child_Opportunity__c record');
        System.assertEquals(testOpp.Id, result.Opportunity__c, 'Should return record with correct Opportunity__c');
    }
    
    @isTest
    static void testGetRecordByOppIdNoExistingRecord() {
        // Create a new opportunity without Child_Opportunity__c
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity Without Child',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        Test.startTest();
        Child_Opportunity__c result = CustomViewRecordController.getRecordByOppId(testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(null, result, 'Should return null when no Child_Opportunity__c exists');
    }
    
    @isTest
    static void testGetRecordByOppIdInvalidOppId() {
        // Test with invalid opportunity ID - generate a fake ID dynamically
        String invalidOppId = '001' + String.valueOf(Math.random()).substring(2, 15) + 'AAA';
        
        Test.startTest();
        Child_Opportunity__c result = CustomViewRecordController.getRecordByOppId(invalidOppId);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(null, result, 'Should return null for invalid opportunity ID');
    }
    
    @isTest
    static void testGetRecordByOppIdNullOppId() {
        // Test with null opportunity ID
        Test.startTest();
        Child_Opportunity__c result = CustomViewRecordController.getRecordByOppId(null);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(null, result, 'Should return null for null opportunity ID');
    }
    
    @isTest
    static void testSaveRecordInsertNewRecord() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        // Prepare field values for new record
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Name' => 'New Child Opportunity'
        };
        
        Test.startTest();
        Id recordId = CustomViewRecordController.saveRecord('Child_Opportunity__c', fieldValues, testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, recordId, 'Should return a valid record ID');
        
        // Verify the record was created
        Child_Opportunity__c createdRecord = [SELECT Id, Name, Opportunity__c FROM Child_Opportunity__c WHERE Id = :recordId];
        System.assertEquals('New Child Opportunity', createdRecord.Name, 'Record name should match');
        System.assertEquals(testOpp.Id, createdRecord.Opportunity__c, 'Opportunity__c should be set correctly');
    }
    
    @isTest
    static void testSaveRecordUpdateExistingRecord() {
        // Get existing Child_Opportunity__c record
        Child_Opportunity__c existingRecord = [SELECT Id FROM Child_Opportunity__c WHERE Name = 'Test Child Opportunity' LIMIT 1];
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        // Prepare field values for update
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Id' => existingRecord.Id,
            'Name' => 'Updated Child Opportunity'
        };
        
        Test.startTest();
        Id recordId = CustomViewRecordController.saveRecord('Child_Opportunity__c', fieldValues, testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(existingRecord.Id, recordId, 'Should return the same record ID for update');
        
        // Verify the record was updated
        Child_Opportunity__c updatedRecord = [SELECT Id, Name, Opportunity__c FROM Child_Opportunity__c WHERE Id = :recordId];
        System.assertEquals('Updated Child Opportunity', updatedRecord.Name, 'Record name should be updated');
        System.assertEquals(testOpp.Id, updatedRecord.Opportunity__c, 'Opportunity__c should remain correct');
    }
    
    @isTest
    static void testSaveRecordEmptyFieldValues() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        // Prepare empty field values
        Map<String, Object> fieldValues = new Map<String, Object>();
        
        Test.startTest();
        Id recordId = CustomViewRecordController.saveRecord('Child_Opportunity__c', fieldValues, testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, recordId, 'Should return a valid record ID even with empty field values');
        
        // Verify the record was created with only Opportunity__c
        Child_Opportunity__c createdRecord = [SELECT Id, Opportunity__c FROM Child_Opportunity__c WHERE Id = :recordId];
        System.assertEquals(testOpp.Id, createdRecord.Opportunity__c, 'Opportunity__c should be set correctly');
    }
    
    @isTest
    static void testSaveRecordNullFieldValues() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        Test.startTest();
        Id recordId = CustomViewRecordController.saveRecord('Child_Opportunity__c', null, testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, recordId, 'Should return a valid record ID even with null field values');
        
        // Verify the record was created with only Opportunity__c
        Child_Opportunity__c createdRecord = [SELECT Id, Opportunity__c FROM Child_Opportunity__c WHERE Id = :recordId];
        System.assertEquals(testOpp.Id, createdRecord.Opportunity__c, 'Opportunity__c should be set correctly');
    }
    
    @isTest
    static void testSaveRecordInvalidObjectName() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Name' => 'Test Record'
        };
        
        Test.startTest();
        try {
            Id recordId = CustomViewRecordController.saveRecord('InvalidObject', fieldValues, testOpp.Id);
            System.assert(false, 'Should have thrown an exception for invalid object name');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Invalid type'), 'Should throw appropriate exception for invalid object');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveRecordNullObjectName() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Name' => 'Test Record'
        };
        
        Test.startTest();
        try {
            Id recordId = CustomViewRecordController.saveRecord(null, fieldValues, testOpp.Id);
            System.assert(false, 'Should have thrown an exception for null object name');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Invalid type') || e.getMessage().contains('null'), 'Should throw appropriate exception for null object');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveRecordNullOppId() {
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Name' => 'Test Record'
        };
        
        Test.startTest();
        Id recordId = CustomViewRecordController.saveRecord('Child_Opportunity__c', fieldValues, null);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, recordId, 'Should return a valid record ID even with null oppId');
        
        // Verify the record was created
        Child_Opportunity__c createdRecord = [SELECT Id, Opportunity__c FROM Child_Opportunity__c WHERE Id = :recordId];
        System.assertEquals(null, createdRecord.Opportunity__c, 'Opportunity__c should be null when oppId is null');
    }
    
    @isTest
    static void testSaveRecordMultipleFields() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        // Prepare field values with multiple fields
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Name' => 'Multi Field Record',
            'Description' => 'Test Description'
        };
        
        Test.startTest();
        Id recordId = CustomViewRecordController.saveRecord('Child_Opportunity__c', fieldValues, testOpp.Id);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, recordId, 'Should return a valid record ID');
        
        // Verify the record was created with all fields
        Child_Opportunity__c createdRecord = [SELECT Id, Name, Opportunity__c FROM Child_Opportunity__c WHERE Id = :recordId];
        System.assertEquals('Multi Field Record', createdRecord.Name, 'Record name should match');
        System.assertEquals(testOpp.Id, createdRecord.Opportunity__c, 'Opportunity__c should be set correctly');
    }
}
