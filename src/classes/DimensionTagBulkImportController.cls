/**
 * Created by afaf.awad on 6/8/2021.
 */

public with sharing class DimensionTagBulkImportController {

    /**
     * @param fileData
     * @param fields
     * @param idField
     *
     * @return fileData Wrapper: Boolean on whether the column picked from file has valid Salesforce Ids
     *                           List of Salesforce Ids pulled from file, ready to insert new records.
     */
    @AuraEnabled
    public static fileData validateData(String fileData, List<String> fields, String idField) {

        System.debug('fields = ' + fields);
        Boolean validated = true;
        List<String> idStrings = new List<String>();
        try {
            String[] fileLines = new String[]{};
            fileLines = fileData.unescapeCsv().split('\n');
            for (Integer i = 1, j = fileLines.size(); i < j; i++) {
                    String[] inputvalues = new String[]{};
                    inputvalues = fileLines[i].split(',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
//                    System.debug('inputvalues ::: ' + inputvalues);
                    integer rowsize = inputvalues.size();
                    for (integer m = 0; m < rowsize; m++) {
                        if ( fields.get(m) == idField ) {
                            System.debug('fields.get(m) = ' + fields.get(m));
                            if ( String.isNotBlank(inputvalues[m]) ) {
                                if( inputvalues[m].deleteWhitespace() instanceof Id) {
                                System.debug('Validate Id: ' + inputvalues[m] );
                                    idStrings.add(inputvalues[m].deleteWhitespace());
                                }else {
                                    System.debug('inputValue not instance of id ' + i + ' = ' + inputvalues[m] instanceof Id);
                                    validated = false;
                                    break;
                                }
                            }else {
                                System.debug('inputValue is blank ' + i + ' = ' + inputvalues[m]);
                                validated = false;
                                break;
                            }
                        }
                    }
            }
        } catch (Exception e) {
            System.debug('exception' + e);
            throw new AACRCustomException(e.getMessage(), e.getStackTraceString(), 'DimensionTagBulkImportController');
        }

        System.debug('validated = ' + validated);
        return new fileData(validated,idStrings);
    }

    @AuraEnabled
    public static TagImportResults createTagRecords(String stringRecordIds, String dimTagId){
        List<Id> recordIds = (List<Id>)JSON.deserialize(stringRecordIds, List<Id>.class);
        List<SObject> tagRecords = new List<SObject>();
        Dimension_Tags__mdt dimTag = DimensionTagHelper.getDimTagRecord(dimTagId);
        sObject sObj = recordIds[0].getSobjectType().newSObject(recordIds[0]);
        String objectTag = sObj.getSObjectType() + '_Dimension_Tag__c';
        for(String recId : recordIds){
            tagRecords.add(DimensionTagHelper.bulkCreateTagRecord(dimTag,recId, objectTag));
        }

        // DML statement
        TagImportResults importResults = new TagImportResults();
        importResults.success = true;
        List<ImportResults> results = new List<ImportResults>();
        List<Database.SaveResult> updateResults = Database.insert(tagRecords, false);
//         Iterate through each returned result
        for(Integer i=0;i<updateResults.size();i++){
            ImportResults r = new ImportResults();
            if (updateResults.get(i).isSuccess()) {
                sObject tagObject = tagRecords.get(i);
                r.recordId = (Id) tagObject.get('Object_Lookup__c');
                r.tagId = updateResults.get(i).getId();
                r.message = 'Record Created';
            }else {
                // Operation failed, so get all errors
                Database.Error error = updateResults.get(i).getErrors().get(0);
                String errorMessage = error.getStatusCode() + ': ' + error.getMessage();
                tagRecords.get(i);
                system.debug('Failed ID ' + tagRecords.get(i));
                System.debug('Object fields that affected this error: ' + error.getFields());
                r.recordId = (Id) tagRecords.get(i).get('Object_Lookup__c');
                r.message = errorMessage;
            }
            results.add(r);
        }
        for(ImportResults ir: results){
            if(ir.message != 'Record Created') {
                importResults.success = false;
                break;
            }
        }

        importResults.importResults = results;

        return importResults;
    }

    public class fileData{
        @AuraEnabled
        public Boolean validated;
        @AuraEnabled
        public List<String> recordIds;

        public fileData(Boolean validate, List<String> recordIds){
            this.validated = validate;
            this.recordIds = recordIds;
        }
    }

    public class TagImportResults{
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public List<ImportResults> importResults;
    }

    public class ImportResults{
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public Id tagId;
        @AuraEnabled
        public String message;

    }

}