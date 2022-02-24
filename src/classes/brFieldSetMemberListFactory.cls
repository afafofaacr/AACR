/**
 * Created by mitfity on 12.04.2018.
 */

public with sharing class brFieldSetMemberListFactory {

    private brFieldSetMemberListFactory() {
    }

    private static List<brIFieldWrap> mockFieldSetMemberList;

    /**
     * Constructs a brIFieldWrap list based on the given field set.
     *
     * @param fieldSet
     * @param accessType
     *
     * @return
     */
    public static List<brIFieldWrap> construct(Schema.FieldSet fieldSet, String accessType) {
        System.debug('contruct: ' + fieldSet + ' accessType: ' + accessType);
//        if (Test.isRunningTest() && mockFieldSetMemberList != null) {
//            return mockFieldSetMemberList;
//        }

        List<brIFieldWrap> fieldSetMemberList = new List<brIFieldWrap>();

        if (fieldSet == null) {
            return fieldSetMemberList;
        }

        SObjectType objectType = fieldSet.SObjectType;
        Map<String, Schema.SObjectField> accessibleFieldsMap = objectType.getDescribe().fields.getMap();
        System.debug('accessibleFieldMap: ' + accessibleFieldsMap);

        accessibleFieldsMap = brSecurity.getAccessibleFields(accessibleFieldsMap, accessType);
        System.debug('accessibleFieldMap after security: ' + accessibleFieldsMap);

        for (Schema.FieldSetMember member : fieldSet.getFields()) {
            if (accessibleFieldsMap.containsKey(member.getFieldPath().toLowerCase())) {
                fieldSetMemberList.add(new brFieldWrap(member, objectType));
            }
        }

        return fieldSetMemberList;
    }

    /**
     * Constructs a brIFieldWrap list based on the given field set.
     *
     * @param fieldSet
     *
     * @return
     */
    public static List<brIFieldWrap> construct(Schema.FieldSet fieldSet) {
        return construct(fieldSet, 'read');
    }

    /**
     * Provides a mock response to the 'construct' method during a test context.
     *
     * @param mockFields
     */
    @TestVisible
    private static void setMock(List<SObjectField> mockFields) {
        mockFieldSetMemberList = new List<brIFieldWrap>();
        for (SObjectField field : mockFields) {
            mockFieldSetMemberList.add(new brTestFieldWrap(field));
        }
    }
}