/**
 * Created by mitfity on 13.02.2018.
 */

public with sharing class brFieldWrap implements brIFieldWrap {

    private Boolean dbRequired;
    private String apiName;
    private String label;
    private Boolean required;
    private String type;
    private List<Map<String, Object>> picklistValues;
    private Integer digits;
    private Integer length;
    private Integer precision;
    private Integer scale;
    private Boolean htmlFormatted;

    public brFieldWrap(Schema.FieldSetMember f, SObjectType sObjectType) {
        this.dbRequired = f.dbRequired;
        this.apiName = f.fieldPath;
        this.label = f.label;
        this.required = f.required;
        this.type = String.valueOf(f.getType());

        Schema.SObjectField field = sObjectType.getDescribe().fields.getMap().get(this.apiName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

        this.digits = fieldDescribe.getDigits();
        this.length = fieldDescribe.getLength();
        this.precision = fieldDescribe.getPrecision();
        this.scale = fieldDescribe.getScale();
        this.htmlFormatted = fieldDescribe.isHtmlFormatted();

        if (this.type == 'PICKLIST' || this.type == 'MULTIPICKLIST') {
            this.picklistValues = new List<Map<String, Object>>();

            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                if (entry.isActive()) {
                    Map<String, Object> listItem = new Map<String, Object>();
                    listItem.put('value', entry.getValue());
                    listItem.put('label', entry.getLabel());
                    this.picklistValues.add(listItem);
                }
            }
        }
    }

    public brFieldWrap(Boolean dbRequired) {
        this.dbRequired = dbRequired;
    }

    @AuraEnabled
    public Boolean getDbRequired() {
        return this.dbRequired;
    }

    @AuraEnabled
    public String getApiName() {
        return this.apiName;
    }

    @AuraEnabled
    public String getLabel() {
        return this.label;
    }

    @AuraEnabled
    public Boolean getRequired() {
        return this.required;
    }

    @AuraEnabled
    public String getType() {
        return this.type;
    }

    @AuraEnabled
    public List<Map<String, Object>> getPicklistValues() {
        return this.picklistValues;
    }

    @AuraEnabled
    public Integer getDigits() {
        return this.digits;
    }

    @AuraEnabled
    public Integer getLength() {
        return this.length;
    }

    @AuraEnabled
    public Integer getPrecision() {
        return this.precision;
    }

    @AuraEnabled
    public Integer getScale() {
        return this.scale;
    }

    @AuraEnabled
    public Boolean getIsHtmlFormatted() {
        return this.htmlFormatted;
    }
}