/**
 * Created by mitfity on 29.07.2019.
 */

export default {
    'anytype': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'text'
        }
    },
    'base64': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'text'
        }
    },
    'boolean': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'checkbox'
        }
    },
    'combobox': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'text'
        }
    },
    'currency': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'text'
        }
    },
    'datacategorygroupreference': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'text'
        }
    },
    'date': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'date'
        }
    },
    'datetime': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'datetime'
        }
    },
    'double': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'number'
        }
    },
    'email': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'email',
            pattern: '[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?'
        }
    },
    'id': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'text'
        }
    },
    'integer': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'number',
            step: 1
        }
    },
    'multipicklist': {
        template: 'multiPicklist',
        componentDef: 'brSelect',
        attributes: {
        }
    },
    'percent': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'number',
            formatter: 'percent'
        }
    },
    'phone': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'tel'
        }
    },
    'picklist': {
        template: 'picklist',
        componentDef: 'brSelect',
        attributes: {
        }
    },
    'reference': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'text'
        }
    },
    'richtext': {
        template: 'richText',
        componentDef: 'brInputRichText',
        attributes: {
        }
    },
    'string': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'text'
        }
    },
    'textarea': {
        template: 'textarea',
        componentDef: 'lightning:textarea',
        attributes: {
        }
    },
    'url': {
        template: 'input',
        componentDef: 'lightning:input',
        attributes: {
            type: 'url'
        }
    }
}