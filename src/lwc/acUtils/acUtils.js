/**
 * Created by mitfity on 24.07.2019.
 */

/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
const reduceErrors = errors => { 
    console.log('errors: ' + JSON.stringify(errors));
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            .filter(error => !!error)
            .map(error => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map(e => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                else if (typeof error === 'string') {
                    return error;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter(message => !!message)
    );
};

/**
 * Retrieves single string error message.
 * @param errors
 * @returns {string}
 */
const getErrorMessage = errors => {
    const reducedErrors = reduceErrors(errors);

    return reducedErrors.length ? reducedErrors.join('. ') : 'Unknown error';
};

/**
 * Parses and returns URL params.
 */
const getUrlParams = () => {
    let params = {};

    window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi,
        (m, key, value) => params[key] = value);

    return params;
};

export default {
    reduceErrors, getUrlParams, getErrorMessage
}