/**
 * Created by mitfity on 18.07.2019.
 */

public with sharing class brSecurity {

    /**
     * Checks for user permissions and throw error if user is permitted for an action.
     *
     * @param sObject
     * @param accessType
     * @param fields
     */
    public static void performAccessCheck(String accessType, Schema.SObjectType sObjectType,
            List<Schema.SObjectField> fields) {
        if ((accessType == 'read' && !isAuthorizedToView(sObjectType, fields))
                || (accessType == 'write' && !isAuthorizedToCreate(sObjectType, fields))
                || (accessType == 'edit' && !isAuthorizedToUpdate(sObjectType, fields))
                || (accessType == 'delete' && !isAuthorizedToDelete(sObjectType))) {
            System.debug('access not granted: ' + sObjectType.getDescribe().getLabel());
            throw new AuraHandledException('Access not granted: ' + sObjectType.getDescribe().getLabel());
        }
    }

    /**
     * Function overload for performAccessCheck, so that you do not have to pass null as a fields parameter.
     *
     * @param sObject
     * @param accessType
     */
    public static void performAccessCheck(String accessType, Schema.SObjectType sObjectType) {
        performAccessCheck(accessType, sObjectType, null);
    }

    /**
     * Checks if current user has permission to view the given object type and fields.
     *
     * @param sObjectType
     * @param fields
     *
     * @return
     */
    public static Boolean isAuthorizedToView(Schema.SObjectType sObjectType, List<Schema.SObjectField> fields) {
        System.debug('isAuthorizedToView');
        if (!sObjectType.getDescribe().isAccessible()){
            System.debug('access is not accessible');
            return false;
        }

        if (fields == null) {
            return true;
        }

        for (Schema.SObjectField f : fields) {
            if (!f.getDescribe().isAccessible()){
                System.debug('field is not accessible');
                return false;
            }
        }
        return true;
    }

    /**
     * Checks if current user has permission to update the given object type and fields.
     *
     * @param sObjectType
     * @param fields
     *
     * @return
     */
    public static Boolean isAuthorizedToUpdate(Schema.SObjectType sObjectType, List<Schema.SObjectField> fields) {
        if (!sObjectType.getDescribe().isUpdateable()){
            return false;
        }

        if (fields == null) {
            return true;
        }

        for (Schema.SObjectField f : fields) {
            if (!f.getDescribe().isUpdateable()){
                return false;
            }
        }
        return true;
    }

    /**
     * Checks if current user has permission to create the given object type and fields.
     *
     * @param sObjectType
     * @param fields
     *
     * @return
     */
    public static Boolean isAuthorizedToCreate(Schema.SObjectType sObjectType, List<Schema.SObjectField> fields) {
        System.debug('isAuthorizedToCreate...');
        if (!sObjectType.getDescribe().isCreateable()){
            System.debug('object is not creatable');
            return false;
        }

        if (fields == null) {
            return true;
        }

        for (Schema.SObjectField f : fields) {
            if (!f.getDescribe().isCreateable()){
                System.debug('field is not creatable');
                return false;
            }
        }
        return true;
    }

    /**
     * Check to see if current user can delete given object type.
     *
     * @param sObjectType
     *
     * @return
     */
    public static Boolean isAuthorizedToDelete(Schema.SObjectType sObjectType) {
        return sObjectType.getDescribe().isDeletable();
    }

    /**
     * Filters field map and returns only accessible fields.
     *
     * @param fieldMap
     *
     * @return
     */
    public static Map<String, Schema.SObjectField> getAccessibleFields(Map<String, Schema.SObjectField> fieldMap,
            String accessType) {
        Map<String, Schema.SObjectField> accessibleFields = new Map<String, Schema.SObjectField>();
        List<String> fieldNames = new List<String>(fieldMap.keySet());

        for (String fieldName : fieldNames) {
            System.debug('field: ' + fieldName);
            Schema.SObjectField field = fieldMap.get(fieldName);


            if (field.getDescribe().getType().name() == 'ENCRYPTEDSTRING') {
                continue;
            }

            System.debug('accessType: ' + accessType);
            System.debug('updateable: ' + field.getDescribe().isUpdateable());
            if (accessType == 'any' || (accessType == 'read' && field.getDescribe().isAccessible())
                    || (accessType == 'create' && field.getDescribe().isCreateable())
                    || (accessType == 'update' && field.getDescribe().isUpdateable())
                    ) {
                SYstem.debug('adding ' + fieldName + ' to list');
                accessibleFields.put(fieldName, field);
            }
        }

        return accessibleFields;
    }

    /**
     * Filters field map and returns only accessible fields.
     *
     * @param fieldMap
     *
     * @return
     */
    public static Map<String, Schema.SObjectField> getAccessibleFields(Map<String, Schema.SObjectField> fieldMap) {
        return getAccessibleFields(fieldMap, 'read');
    }
}