/**
 * Created by afaf.awad on 8/25/2021.
 */

public with sharing class ServiceNow2ApexArray {
    public List<Result> result {get;set;}

    public ServiceNow2ApexArray(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'result') {
                        result = arrayOfResult(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class Closed_by {
        public String link {get;set;}
        public String value {get;set;}

        public Closed_by(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
//                    System.debug('ClosedBy parser == ' + parser.getText());
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'link') {
                            link = parser.getText();
                        } else if (text == 'value') {
                            value = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Closed_by consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Result {
        public String u_preferred_contact_method {get;set;}
        public String parent {get;set;}
        public String caused_by {get;set;}
        public String watch_list {get;set;}
        public String active_escalation {get;set;}
        public String upon_reject {get;set;}
        public String sys_updated_on {get;set;}
        public String support_manager {get;set;}
        public String approval_history {get;set;}
        public String skills {get;set;}
        public String number_Z {get;set;} // in json: number
        public String problem {get;set;}
        public String state {get;set;}
        public String u_salesforce_ref {get;set;}
        public String case_Z {get;set;} // in json: case
        public String sys_created_by {get;set;}
        public String knowledge {get;set;}
        public String order {get;set;}
        public String assigned_on {get;set;}
        public String cmdb_ci {get;set;}
        public String delivery_plan {get;set;}
        public String u_external_user_s_email {get;set;}
        public String contract {get;set;}
        public String impact {get;set;}
        public String active {get;set;}
        public String work_notes_list {get;set;}
        public String priority {get;set;}
        public String sys_domain_path {get;set;}
        public String u_record_producer {get;set;}
        public String business_duration {get;set;}
        public String first_response_time {get;set;}
        public String group_list {get;set;}
        public String u_salesforce_error_log {get;set;}
        public String sync_driver {get;set;}
        public String approval_set {get;set;}
        public String universal_request {get;set;}
        public String short_description {get;set;}
        public String correlation_display {get;set;}
        public String delivery_task {get;set;}
        public String work_start {get;set;}
        public String additional_assignee_list {get;set;}
        public String notify {get;set;}
        public String service_offering {get;set;}
        public String sys_class_name {get;set;}
        public Closed_by closed_by_obj {get;set;}
        public String closed_by {get;set;}
        public String follow_up {get;set;}
        public String contact_local_time {get;set;}
        public String sn_app_cs_social_social_profile {get;set;}
        public String reassignment_count {get;set;}
        public String contact_time_zone {get;set;}
        public String notes_to_comments {get;set;}
        public String assigned_to {get;set;}
        public String product {get;set;}
        public String sla_due {get;set;}
        public String change {get;set;}
        public String comments_and_work_notes {get;set;}
        public String partner {get;set;}
        public String escalation {get;set;}
        public String upon_approval {get;set;}
        public String partner_contact {get;set;}
        public String correlation_id {get;set;}
        public String asset {get;set;}
        public String made_sla {get;set;}
        public String u_reference_page_url {get;set;}
        public String u_external_phone_number {get;set;}
        public String task_effective_number {get;set;}
        public Closed_by resolved_by_obj {get;set;}
        public String resolved_by {get;set;}
        public String u_external_user_full_name {get;set;}
        public String sys_updated_by {get;set;}
        public Closed_by opened_by {get;set;}
        public String user_input {get;set;}
        public String sys_created_on {get;set;}
        public String contact {get;set;}
        public Closed_by sys_domain {get;set;}
        public String route_reason {get;set;}
        public String closed_at {get;set;}
        public String follow_the_sun {get;set;}
        public String business_service {get;set;}
        public String entitlement {get;set;}
        public String time_worked {get;set;}
        public String expected_start {get;set;}
        public String opened_at {get;set;}
        public String work_end {get;set;}
        public Closed_by case_report {get;set;}
        public String resolved_at {get;set;}
        public String subcategory {get;set;}
        public String work_notes {get;set;}
        public String u_membership_id {get;set;}
        public String assignment_group {get;set;}
        public String cause {get;set;}
        public String description {get;set;}
        public String proactive {get;set;}
        public String calendar_duration {get;set;}
        public String close_notes {get;set;}
        public String auto_close {get;set;}
        public String sys_id {get;set;}
        public String contact_type {get;set;}
        public String resolution_code {get;set;}
        public String urgency {get;set;}
        public String company {get;set;}
        public String activity_due {get;set;}
        public String consumer {get;set;}
        public String comments {get;set;}
        public String approval {get;set;}
        public String due_date {get;set;}
        public String sys_mod_count {get;set;}
        public String sys_tags {get;set;}
        public String active_account_escalation {get;set;}
        public String location {get;set;}
        public String category {get;set;}
        public String account {get;set;}

        public Result(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'u_preferred_contact_method') {
                            u_preferred_contact_method = parser.getText();
                        } else if (text == 'parent') {
                            parent = parser.getText();
                        } else if (text == 'caused_by') {
                            caused_by = parser.getText();
                        } else if (text == 'watch_list') {
                            watch_list = parser.getText();
                        } else if (text == 'active_escalation') {
                            active_escalation = parser.getText();
                        } else if (text == 'upon_reject') {
                            upon_reject = parser.getText();
                        } else if (text == 'sys_updated_on') {
                            sys_updated_on = parser.getText();
                        } else if (text == 'support_manager') {
                            support_manager = parser.getText();
                        } else if (text == 'approval_history') {
                            approval_history = parser.getText();
                        } else if (text == 'skills') {
                            skills = parser.getText();
                        } else if (text == 'number') {
                            number_Z = parser.getText();
                        } else if (text == 'problem') {
                            problem = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'u_salesforce_ref') {
                            u_salesforce_ref = parser.getText();
                        } else if (text == 'case') {
                            case_Z = parser.getText();
                        } else if (text == 'sys_created_by') {
                            sys_created_by = parser.getText();
                        } else if (text == 'knowledge') {
                            knowledge = parser.getText();
                        } else if (text == 'order') {
                            order = parser.getText();
                        } else if (text == 'assigned_on') {
                            assigned_on = parser.getText();
                        } else if (text == 'cmdb_ci') {
                            cmdb_ci = parser.getText();
                        } else if (text == 'delivery_plan') {
                            delivery_plan = parser.getText();
                        } else if (text == 'u_external_user_s_email') {
                            u_external_user_s_email = parser.getText();
                        } else if (text == 'contract') {
                            contract = parser.getText();
                        } else if (text == 'impact') {
                            impact = parser.getText();
                        } else if (text == 'active') {
                            active = parser.getText();
                        } else if (text == 'work_notes_list') {
                            work_notes_list = parser.getText();
                        } else if (text == 'priority') {
                            priority = parser.getText();
                        } else if (text == 'sys_domain_path') {
                            sys_domain_path = parser.getText();
                        } else if (text == 'u_record_producer') {
                            u_record_producer = parser.getText();
                        } else if (text == 'business_duration') {
                            business_duration = parser.getText();
                        } else if (text == 'first_response_time') {
                            first_response_time = parser.getText();
                        } else if (text == 'group_list') {
                            group_list = parser.getText();
                        } else if (text == 'u_salesforce_error_log') {
                            u_salesforce_error_log = parser.getText();
                        } else if (text == 'sync_driver') {
                            sync_driver = parser.getText();
                        } else if (text == 'approval_set') {
                            approval_set = parser.getText();
                        } else if (text == 'universal_request') {
                            universal_request = parser.getText();
                        } else if (text == 'short_description') {
                            short_description = parser.getText();
                        } else if (text == 'correlation_display') {
                            correlation_display = parser.getText();
                        } else if (text == 'delivery_task') {
                            delivery_task = parser.getText();
                        } else if (text == 'work_start') {
                            work_start = parser.getText();
                        } else if (text == 'additional_assignee_list') {
                            additional_assignee_list = parser.getText();
                        } else if (text == 'notify') {
                            notify = parser.getText();
                        } else if (text == 'service_offering') {
                            service_offering = parser.getText();
                        } else if (text == 'sys_class_name') {
                            sys_class_name = parser.getText();
                        } else if (text == 'closed_by') {
//                            System.debug('closedby text = ' + parser.getText());
                            if(parser.getText() == '{'){
                                closed_by_obj = new Closed_by(parser);
                            }else {
                                closed_by = parser.getText();
                            }
                        } else if (text == 'follow_up') {
                            follow_up = parser.getText();
                        } else if (text == 'contact_local_time') {
                            contact_local_time = parser.getText();
                        } else if (text == 'sn_app_cs_social_social_profile') {
                            sn_app_cs_social_social_profile = parser.getText();
                        } else if (text == 'reassignment_count') {
                            reassignment_count = parser.getText();
                        } else if (text == 'contact_time_zone') {
                            contact_time_zone = parser.getText();
                        } else if (text == 'notes_to_comments') {
                            notes_to_comments = parser.getText();
                        } else if (text == 'assigned_to') {
                            assigned_to = parser.getText();
                        } else if (text == 'product') {
                            product = parser.getText();
                        } else if (text == 'sla_due') {
                            sla_due = parser.getText();
                        } else if (text == 'change') {
                            change = parser.getText();
                        } else if (text == 'comments_and_work_notes') {
                            comments_and_work_notes = parser.getText();
                        } else if (text == 'partner') {
                            partner = parser.getText();
                        } else if (text == 'escalation') {
                            escalation = parser.getText();
                        } else if (text == 'upon_approval') {
                            upon_approval = parser.getText();
                        } else if (text == 'partner_contact') {
                            partner_contact = parser.getText();
                        } else if (text == 'correlation_id') {
                            correlation_id = parser.getText();
                        } else if (text == 'asset') {
                            asset = parser.getText();
                        } else if (text == 'made_sla') {
                            made_sla = parser.getText();
                        } else if (text == 'u_reference_page_url') {
                            u_reference_page_url = parser.getText();
                        } else if (text == 'u_external_phone_number') {
                            u_external_phone_number = parser.getText();
                        } else if (text == 'task_effective_number') {
                            task_effective_number = parser.getText();
                        } else if (text == 'resolved_by') {
//                            System.debug('resolved_by text = ' + parser.getText());
                            if(parser.getText() == '{'){
                                resolved_by_obj = new Closed_by(parser);
                            }else {
                                resolved_by = parser.getText();
                            }
                        } else if (text == 'u_external_user_full_name') {
                            u_external_user_full_name = parser.getText();
                        } else if (text == 'sys_updated_by') {
                            sys_updated_by = parser.getText();
                        } else if (text == 'opened_by') {
                            opened_by = new Closed_by(parser);
                        } else if (text == 'user_input') {
                            user_input = parser.getText();
                        } else if (text == 'sys_created_on') {
                            sys_created_on = parser.getText();
                        } else if (text == 'contact') {
                            contact = parser.getText();
                        } else if (text == 'sys_domain') {
                            sys_domain = new Closed_by(parser);
                        } else if (text == 'route_reason') {
                            route_reason = parser.getText();
                        } else if (text == 'closed_at') {
                            closed_at = parser.getText();
                        } else if (text == 'follow_the_sun') {
                            follow_the_sun = parser.getText();
                        } else if (text == 'business_service') {
                            business_service = parser.getText();
                        } else if (text == 'entitlement') {
                            entitlement = parser.getText();
                        } else if (text == 'time_worked') {
                            time_worked = parser.getText();
                        } else if (text == 'expected_start') {
                            expected_start = parser.getText();
                        } else if (text == 'opened_at') {
                            opened_at = parser.getText();
                        } else if (text == 'work_end') {
                            work_end = parser.getText();
                        } else if (text == 'case_report') {
                            case_report = new Closed_by(parser);
                        } else if (text == 'resolved_at') {
                            resolved_at = parser.getText();
                        } else if (text == 'subcategory') {
                            subcategory = parser.getText();
                        } else if (text == 'work_notes') {
                            work_notes = parser.getText();
                        } else if (text == 'u_membership_id') {
                            u_membership_id = parser.getText();
                        } else if (text == 'assignment_group') {
                            assignment_group = parser.getText();
                        } else if (text == 'cause') {
                            cause = parser.getText();
                        } else if (text == 'description') {
                            description = parser.getText();
                        } else if (text == 'proactive') {
                            proactive = parser.getText();
                        } else if (text == 'calendar_duration') {
                            calendar_duration = parser.getText();
                        } else if (text == 'close_notes') {
                            close_notes = parser.getText();
                        } else if (text == 'auto_close') {
                            auto_close = parser.getText();
                        } else if (text == 'sys_id') {
                            sys_id = parser.getText();
                        } else if (text == 'contact_type') {
                            contact_type = parser.getText();
                        } else if (text == 'resolution_code') {
                            resolution_code = parser.getText();
                        } else if (text == 'urgency') {
                            urgency = parser.getText();
                        } else if (text == 'company') {
                            company = parser.getText();
                        } else if (text == 'activity_due') {
                            activity_due = parser.getText();
                        } else if (text == 'consumer') {
                            consumer = parser.getText();
                        } else if (text == 'comments') {
                            comments = parser.getText();
                        } else if (text == 'approval') {
                            approval = parser.getText();
                        } else if (text == 'due_date') {
                            due_date = parser.getText();
                        } else if (text == 'sys_mod_count') {
                            sys_mod_count = parser.getText();
                        } else if (text == 'sys_tags') {
                            sys_tags = parser.getText();
                        } else if (text == 'active_account_escalation') {
                            active_account_escalation = parser.getText();
                        } else if (text == 'location') {
                            location = parser.getText();
                        } else if (text == 'category') {
                            category = parser.getText();
                        } else if (text == 'account') {
                            account = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Result consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }


    public static ServiceNow2ApexArray parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new ServiceNow2ApexArray(parser);
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



    private static List<Result> arrayOfResult(System.JSONParser p) {
        List<Result> res = new List<Result>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Result(p));
        }
        return res;
    }



}