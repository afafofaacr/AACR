/**
 * Created by afaf.awad on 8/19/2021.
 */

public with sharing class ServiceNow2Apex {

    public Result result { get; set; }

    public ServiceNow2Apex(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'result') {
                        result = new Result(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class Opened_by {
        public String link { get; set; }
        public String value { get; set; }

        public Opened_by(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'link') {
                            link = parser.getText();
                        } else if (text == 'value') {
                            value = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Opened_by consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Result {
        public String u_preferred_contact_method { get; set; }
        public String parent { get; set; }
        public String caused_by { get; set; }
        public String watch_list { get; set; }
        public String active_escalation { get; set; }
        public String upon_reject { get; set; }
        public String sys_updated_on { get; set; }
        public String support_manager { get; set; }
        public String approval_history { get; set; }
        public String skills { get; set; }
        public String number_Z { get; set; } // in json: number
        public String problem { get; set; }
        public String state { get; set; }
        public String u_salesforce_ref { get; set; }
        public String case_Z { get; set; } // in json: case
        public String sys_created_by { get; set; }
        public String knowledge { get; set; }
        public String order { get; set; }
        public String assigned_on { get; set; }
        public String cmdb_ci { get; set; }
        public String delivery_plan { get; set; }
        public String u_external_user_s_email { get; set; }
        public String contract { get; set; }
        public String impact { get; set; }
        public String active { get; set; }
        public String work_notes_list { get; set; }
        public String priority { get; set; }
        public String sys_domain_path { get; set; }
        public String u_record_producer { get; set; }
        public String business_duration { get; set; }
        public String first_response_time { get; set; }
        public String group_list { get; set; }
        public String u_salesforce_error_log { get; set; }
        public String sync_driver { get; set; }
        public String approval_set { get; set; }
        public String universal_request { get; set; }
        public String short_description { get; set; }
        public String correlation_display { get; set; }
        public String delivery_task { get; set; }
        public String work_start { get; set; }
        public String additional_assignee_list { get; set; }
        public String notify { get; set; }
        public String service_offering { get; set; }
        public String sys_class_name { get; set; }
        public String closed_by { get; set; }
        public String follow_up { get; set; }
        public String contact_local_time { get; set; }
        public String sn_app_cs_social_social_profile { get; set; }
        public String reassignment_count { get; set; }
        public String contact_time_zone { get; set; }
        public String notes_to_comments { get; set; }
        public String assigned_to { get; set; }
        public String product { get; set; }
        public String sla_due { get; set; }
        public String change { get; set; }
        public String comments_and_work_notes { get; set; }
        public String partner { get; set; }
        public String escalation { get; set; }
        public String upon_approval { get; set; }
        public String partner_contact { get; set; }
        public String correlation_id { get; set; }
        public String asset { get; set; }
        public String made_sla { get; set; }
        public String u_reference_page_url { get; set; }
        public String u_external_phone_number { get; set; }
        public String task_effective_number { get; set; }
        public String resolved_by { get; set; }
        public String u_external_user_full_name { get; set; }
        public String sys_updated_by { get; set; }
        public Opened_by opened_by { get; set; }
        public String user_input { get; set; }
        public String sys_created_on { get; set; }
        public String contact { get; set; }
        public Opened_by sys_domain { get; set; }
        public String route_reason { get; set; }
        public String closed_at { get; set; }
        public String follow_the_sun { get; set; }
        public String business_service { get; set; }
        public String entitlement { get; set; }
        public String time_worked { get; set; }
        public String expected_start { get; set; }
        public String opened_at { get; set; }
        public String work_end { get; set; }
        public String case_report { get; set; }
        public String resolved_at { get; set; }
        public String subcategory { get; set; }
        public String work_notes { get; set; }
        public String u_membership_id { get; set; }
        public String assignment_group { get; set; }
        public String cause { get; set; }
        public String description { get; set; }
        public String proactive { get; set; }
        public String calendar_duration { get; set; }
        public String close_notes { get; set; }
        public String auto_close { get; set; }
        public String sys_id { get; set; }
        public String contact_type { get; set; }
        public String resolution_code { get; set; }
        public String urgency { get; set; }
        public String company { get; set; }
        public String activity_due { get; set; }
        public String consumer { get; set; }
        public String comments { get; set; }
        public String approval { get; set; }
        public String due_date { get; set; }
        public String sys_mod_count { get; set; }
        public String sys_tags { get; set; }
        public String active_account_escalation { get; set; }
        public String location { get; set; }
        public String category { get; set; }
        public String account { get; set; }

        public Result(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        switch on text {
                            when 'u_preferred_contact_method' {
                                u_preferred_contact_method = parser.getText();
                            }
                            when 'parent' {
                                parent = parser.getText();
                            } when 'caused_by' {
                                caused_by = parser.getText();
                            } when 'watch_list' {
                                watch_list = parser.getText();
                            } when 'active_escalation' {
                                active_escalation = parser.getText();
                            } when'upon_reject' {
                                upon_reject = parser.getText();
                            } when 'sys_updated_on' {
                                sys_updated_on = parser.getText();
                            } when 'support_manager' {
                                support_manager = parser.getText();
                            } when 'approval_history' {
                                approval_history = parser.getText();
                            } when 'skills' {
                                skills = parser.getText();
                            } when 'number' {
                                number_Z = parser.getText();
                            } when 'problem' {
                                problem = parser.getText();
                            } when 'state' {
                                state = parser.getText();
                            } when 'u_salesforce_ref' {
                                u_salesforce_ref = parser.getText();
                            } when 'case' {
                                case_Z = parser.getText();
                            } when 'sys_created_by' {
                                sys_created_by = parser.getText();
                            } when 'knowledge' {
                                knowledge = parser.getText();
                            } when 'order' {
                                order = parser.getText();
                            } when 'assigned_on' {
                                assigned_on = parser.getText();
                            } when 'cmdb_ci' {
                                cmdb_ci = parser.getText();
                            } when 'delivery_plan' {
                                delivery_plan = parser.getText();
                            } when 'u_external_user_s_email' {
                                u_external_user_s_email = parser.getText();
                            } when 'contract' {
                                contract = parser.getText();
                            } when 'impact' {
                                impact = parser.getText();
                            } when 'active' {
                                active = parser.getText();
                            } when 'work_notes_list' {
                                work_notes_list = parser.getText();
                            } when 'priority' {
                                priority = parser.getText();
                            } when 'sys_domain_path' {
                                sys_domain_path = parser.getText();
                            } when 'u_record_producer' {
                                u_record_producer = parser.getText();
                            } when 'business_duration' {
                                business_duration = parser.getText();
                            } when 'first_response_time' {
                                first_response_time = parser.getText();
                            } when 'group_list' {
                                group_list = parser.getText();
                            } when 'u_salesforce_error_log' {
                                u_salesforce_error_log = parser.getText();
                            } when 'sync_driver' {
                                sync_driver = parser.getText();
                            } when 'approval_set' {
                                approval_set = parser.getText();
                            } when 'universal_request' {
                                universal_request = parser.getText();
                            } when 'short_description' {
                                short_description = parser.getText();
                            } when 'correlation_display' {
                                correlation_display = parser.getText();
                            } when 'delivery_task' {
                                delivery_task = parser.getText();
                            } when 'work_start' {
                                work_start = parser.getText();
                            } when 'additional_assignee_list' {
                                additional_assignee_list = parser.getText();
                            } when 'notify' {
                                notify = parser.getText();
                            } when 'service_offering' {
                                service_offering = parser.getText();
                            } when 'sys_class_name' {
                                sys_class_name = parser.getText();
                            } when 'closed_by' {
                                closed_by = parser.getText();
                            } when 'follow_up' {
                                follow_up = parser.getText();
                            } when 'contact_local_time' {
                                contact_local_time = parser.getText();
                            } when 'sn_app_cs_social_social_profile' {
                                sn_app_cs_social_social_profile = parser.getText();
                            } when 'reassignment_count' {
                                reassignment_count = parser.getText();
                            } when 'contact_time_zone' {
                                contact_time_zone = parser.getText();
                            } when 'notes_to_comments' {
                                notes_to_comments = parser.getText();
                            } when 'assigned_to' {
                                assigned_to = parser.getText();
                            } when 'product' {
                                product = parser.getText();
                            } when 'sla_due' {
                                sla_due = parser.getText();
                            } when 'change' {
                                change = parser.getText();
                            } when 'comments_and_work_notes' {
                                comments_and_work_notes = parser.getText();
                            } when 'partner' {
                                partner = parser.getText();
                            } when 'escalation' {
                                escalation = parser.getText();
                            } when 'upon_approval' {
                                upon_approval = parser.getText();
                            } when 'partner_contact' {
                                partner_contact = parser.getText();
                            } when 'correlation_id' {
                                correlation_id = parser.getText();
                            } when 'asset' {
                                asset = parser.getText();
                            } when 'made_sla' {
                                made_sla = parser.getText();
                            } when 'u_reference_page_url' {
                                u_reference_page_url = parser.getText();
                            } when 'u_external_phone_number' {
                                u_external_phone_number = parser.getText();
                            } when 'task_effective_number' {
                                task_effective_number = parser.getText();
                            } when 'resolved_by' {
                                resolved_by = parser.getText();
                            } when 'u_external_user_full_name' {
                                u_external_user_full_name = parser.getText();
                            } when 'sys_updated_by' {
                                sys_updated_by = parser.getText();
                            } when 'opened_by' {
                                opened_by = new Opened_by(parser);
                            } when 'user_input' {
                                user_input = parser.getText();
                            } when 'sys_created_on' {
                                sys_created_on = parser.getText();
                            } when 'contact' {
                                contact = parser.getText();
                            } when 'sys_domain' {
                                sys_domain = new Opened_by(parser);
                            } when 'route_reason' {
                                route_reason = parser.getText();
                            } when 'closed_at' {
                                closed_at = parser.getText();
                            } when 'follow_the_sun' {
                                follow_the_sun = parser.getText();
                            } when 'business_service' {
                                business_service = parser.getText();
                            } when 'entitlement' {
                                entitlement = parser.getText();
                            } when 'time_worked' {
                                time_worked = parser.getText();
                            } when 'expected_start' {
                                expected_start = parser.getText();
                            } when 'opened_at' {
                                opened_at = parser.getText();
                            } when 'work_end' {
                                work_end = parser.getText();
                            } when 'case_report' {
                                case_report = parser.getText();
                            } when 'resolved_at' {
                                resolved_at = parser.getText();
                            } when 'subcategory' {
                                subcategory = parser.getText();
                            } when 'work_notes' {
                                work_notes = parser.getText();
                            } when 'u_membership_id' {
                                u_membership_id = parser.getText();
                            } when 'assignment_group' {
                                assignment_group = parser.getText();
                            } when 'cause' {
                                cause = parser.getText();
                            } when 'description' {
                                description = parser.getText();
                            } when 'proactive' {
                                proactive = parser.getText();
                            } when 'calendar_duration' {
                                calendar_duration = parser.getText();
                            } when 'close_notes' {
                                close_notes = parser.getText();
                            } when 'auto_close' {
                                auto_close = parser.getText();
                            } when 'sys_id' {
                                sys_id = parser.getText();
                            } when 'contact_type' {
                                contact_type = parser.getText();
                            } when 'resolution_code' {
                                resolution_code = parser.getText();
                            } when 'urgency' {
                                urgency = parser.getText();
                            } when 'company' {
                                company = parser.getText();
                            } when 'activity_due' {
                                activity_due = parser.getText();
                            } when 'consumer' {
                                consumer = parser.getText();
                            } when 'comments' {
                                comments = parser.getText();
                            } when 'approval' {
                                approval = parser.getText();
                            } when 'due_date' {
                                due_date = parser.getText();
                            } when 'sys_mod_count' {
                                sys_mod_count = parser.getText();
                            } when 'sys_tags' {
                                sys_tags = parser.getText();
                            } when 'active_account_escalation' {
                                active_account_escalation = parser.getText();
                            } when 'location' {
                                location = parser.getText();
                            } when 'category' {
                                category = parser.getText();
                            } when 'account' {
                                account = parser.getText();
                            } when else {
                                System.debug(LoggingLevel.WARN, 'Result consuming unrecognized property: ' + text);
                                consumeObject(parser);
                            }
                        }
                    }
                }
            }
        }
    }


    public static ServiceNow2Apex parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ServiceNow2Apex(parser);
    }


    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT ||
                    curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                    curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
}

