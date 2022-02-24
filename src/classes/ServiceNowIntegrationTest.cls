/**
 * Created by afaf.awad on 9/7/2021.
 */
@IsTest
public with sharing class ServiceNowIntegrationTest {

        @TestSetup public static void setup() {
            Account account = TestDataFactory.buildAccount('Test Account');
            insert account;

            Contact contact = TestDataFactory.buildContact(account.Id);
            insert contact;

            User user = TestDataFactory.buildUser(contact.Id);
            insert user;

            AACR_Error_Log__c userReq = TestDataFactory.buildErrorRequest(contact.Id);
            insert userReq;

            insert new ServiceNow__c(host__c = 'https://aacrdev1.service-now.com/api/now', username__c = 'jitterbit.guest', password__c = '@BC123Test');

        }

    @IsTest
    public static void test_sendSNCase(){
        AACR_Error_Log__c log = [SELECT Id FROM AACR_Error_Log__c LIMIT 1];

        String before = 'Testing base 64 encode';
        Blob beforeblob = Blob.valueOf(before);
        String paramvalue = EncodingUtil.base64Encode(beforeblob);

        Id attachId = SN_HelpFormController.saveChunk(log.Id, 'TEST FILE', paramvalue, 'text/plain', '', 'TEST');

        Test.setMock(HttpCalloutMock.class, new FailureMockHTTPResponseGenerator201());

        Test.startTest();
        ServiceNowIntegration.sendSNCase(log.Id,attachId);
        Test.stopTest();

        Contact con = [SELECT Id FROM Contact LIMIT 1];
        List<ServiceNow_Case__c> snc = [SELECT Id,Name, Contact__c FROM ServiceNow_Case__c WHERE Contact__c =:con.Id];

        System.assertEquals(1, snc.size());
    }


    public class FailureMockHTTPResponseGenerator201 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{\n' +
                    '    "result": {\n' +
                    '        "u_preferred_contact_method": "Email",\n' +
                    '        "parent": "",\n' +
                    '        "caused_by": "",\n' +
                    '        "watch_list": "",\n' +
                    '        "active_escalation": "",\n' +
                    '        "upon_reject": "cancel",\n' +
                    '        "sys_updated_on": "2021-08-26 15:02:24",\n' +
                    '        "support_manager": "",\n' +
                    '        "approval_history": "",\n' +
                    '        "skills": "",\n' +
                    '        "number": "CS0001020",\n' +
                    '        "problem": "",\n' +
                    '        "state": "1",\n' +
                    '        "u_salesforce_ref": "0030200000AIOLfAAP",\n' +
                    '        "case": "Trouble Accessing a Virtual Meeting\u200BCS0001020",\n' +
                    '        "sys_created_by": "jitterbit.guest",\n' +
                    '        "knowledge": "false",\n' +
                    '        "order": "",\n' +
                    '        "assigned_on": "",\n' +
                    '        "cmdb_ci": "",\n' +
                    '        "delivery_plan": "",\n' +
                    '        "u_external_user_s_email": "paulamartinez@aacrtest.org",\n' +
                    '        "contract": "",\n' +
                    '        "impact": "3",\n' +
                    '        "active": "true",\n' +
                    '        "work_notes_list": "",\n' +
                    '        "priority": "5",\n' +
                    '        "sys_domain_path": "/",\n' +
                    '        "u_record_producer": "",\n' +
                    '        "business_duration": "",\n' +
                    '        "first_response_time": "",\n' +
                    '        "group_list": "",\n' +
                    '        "u_salesforce_error_log": "a4S02000000DiJTEA0",\n' +
                    '        "sync_driver": "false",\n' +
                    '        "approval_set": "",\n' +
                    '        "universal_request": "",\n' +
                    '        "short_description": "Trouble Accessing a Virtual Meeting",\n' +
                    '        "correlation_display": "",\n' +
                    '        "delivery_task": "",\n' +
                    '        "work_start": "",\n' +
                    '        "additional_assignee_list": "",\n' +
                    '        "notify": "1",\n' +
                    '        "service_offering": "",\n' +
                    '        "sys_class_name": "sn_customerservice_case",\n' +
                    '        "closed_by": "",\n' +
                    '        "follow_up": "",\n' +
                    '        "contact_local_time": "",\n' +
                    '        "sn_app_cs_social_social_profile": "",\n' +
                    '        "reassignment_count": "0",\n' +
                    '        "contact_time_zone": "",\n' +
                    '        "notes_to_comments": "false",\n' +
                    '        "assigned_to": "",\n' +
                    '        "product": "",\n' +
                    '        "sla_due": "",\n' +
                    '        "change": "",\n' +
                    '        "comments_and_work_notes": "",\n' +
                    '        "partner": "",\n' +
                    '        "escalation": "0",\n' +
                    '        "upon_approval": "proceed",\n' +
                    '        "partner_contact": "",\n' +
                    '        "correlation_id": "",\n' +
                    '        "asset": "",\n' +
                    '        "made_sla": "true",\n' +
                    '        "u_reference_page_url": "https://uat-aacr.cs195.force.com/myAACRHelp?page=a0Z1I00000TqoW3UAJ&site=a0d1I0000011T3OQAU",\n' +
                    '        "u_external_phone_number": "",\n' +
                    '        "task_effective_number": "CS0001020",\n' +
                    '        "resolved_by": "",\n' +
                    '        "u_external_user_full_name": "Paula Martinez",\n' +
                    '        "sys_updated_by": "jitterbit.guest",\n' +
                    '        "opened_by": {\n' +
                    '            "link": "https://aacrdev1.service-now.com/api/now/table/sys_user/20027d7bdbb1f410ce033ed4e2961910",\n' +
                    '            "value": "20027d7bdbb1f410ce033ed4e2961910"\n' +
                    '        },\n' +
                    '        "user_input": "",\n' +
                    '        "sys_created_on": "2021-08-26 15:02:24",\n' +
                    '        "contact": "",\n' +
                    '        "sys_domain": {\n' +
                    '            "link": "https://aacrdev1.service-now.com/api/now/table/sys_user_group/global",\n' +
                    '            "value": "global"\n' +
                    '        },\n' +
                    '        "route_reason": "",\n' +
                    '        "closed_at": "",\n' +
                    '        "follow_the_sun": "false",\n' +
                    '        "business_service": "",\n' +
                    '        "entitlement": "",\n' +
                    '        "time_worked": "",\n' +
                    '        "expected_start": "",\n' +
                    '        "opened_at": "2021-08-26 15:02:24",\n' +
                    '        "work_end": "",\n' +
                    '        "resolved_at": "",\n' +
                    '        "subcategory": "0",\n' +
                    '        "work_notes": "",\n' +
                    '        "u_membership_id": "1173647",\n' +
                    '        "assignment_group": "",\n' +
                    '        "cause": "",\n' +
                    '        "description": "Test",\n' +
                    '        "proactive": "false",\n' +
                    '        "calendar_duration": "",\n' +
                    '        "close_notes": "",\n' +
                    '        "auto_close": "false",\n' +
                    '        "sys_id": "5207c0d01b1a741045f4c9522a4bcbcf",\n' +
                    '        "contact_type": "web",\n' +
                    '        "resolution_code": "",\n' +
                    '        "urgency": "3",\n' +
                    '        "company": "",\n' +
                    '        "activity_due": "",\n' +
                    '        "consumer": "",\n' +
                    '        "comments": "",\n' +
                    '        "approval": "not requested",\n' +
                    '        "due_date": "2021-08-31 15:02:24",\n' +
                    '        "sys_mod_count": "0",\n' +
                    '        "sys_tags": "",\n' +
                    '        "active_account_escalation": "",\n' +
                    '        "location": "",\n' +
                    '        "category": "1",\n' +
                    '        "account": ""\n' +
                    '    }\n' +
                    '}');
            res.setStatusCode(201);
            return res;
        }
    }

}