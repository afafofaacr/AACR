/**
 * Created by mitfity on 29.07.2019.
 */

import {LightningElement, api, track} from 'lwc';
import fieldsTemplateMap from './fieldsTemplateMap.js';
import acInputField from './acInputField.html';
import input from './input.html';
import textarea from './textarea.html';
import richText from './richText.html';
import picklist from './picklist.html';
import multiPicklist from './multiPicklist.html';

export default class AcInputField extends LightningElement {
    @api field; 

    attributes = {};
    templates = {
        input, textarea, richText, picklist, multiPicklist
    };

    @api
    get value() {
        const editor = this.template.querySelector('.ac-input');

        return editor.value;
    }

    /**
     * Displays the error messages and returns false if the input is invalid. If the input is valid, reportValidity()
     * clears displayed error messages and returns true.
     */
    @api
    reportValidity() {
        const editor = this.template.querySelector('.ac-input');

        return editor.reportValidity();
    }

    render() {
        const { field, templates } = this;

        if (field == null) {
            return acInputField;
        }

        let type = field.type.toLowerCase();

        if (type === 'textarea' && field.isHtmlFormatted) {
            type = 'richtext';
        }

        const fieldConfig = fieldsTemplateMap[type];

        if (fieldConfig == null) {
            return acInputField;
        }

        let attributes = fieldConfig.attributes;

        attributes.label = field.label;
        attributes.name = field.apiName;
        attributes.required = field.required || field.dbRequired;

        if (type === 'picklist' || type === 'multipicklist') {
            attributes.options = field.picklistValues;
        } else if (type === 'string' || type === 'textarea') {
            attributes.maxlength = field.length;
        } else if (type === 'integer') {
            attributes.digits = field.digits;
            attributes.max = Math.pow(10, field.digits) - 1;
        } else if (type === 'double') {
            attributes.precision = field.precision;
            attributes.scale = field.scale;
            attributes.step = 1 / Math.pow(10, field.scale);
            attributes.max = Math.pow(10, field.precision - field.scale) - 1;
        }

        this.attributes = attributes;

        if (templates.hasOwnProperty(fieldConfig.template)) {
            return templates[fieldConfig.template];
        }

        return acInputField;
    }
}