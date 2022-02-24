/**
 * Created by lauren.lezberg on 8/16/2020.
 */

public with sharing class CallableTest implements Callable{
    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'sendAttendee' {
                return '123456789';
            }
            when 'updateAttendee' {
                return null;
            }
            when 'goToVenue' {
                return 'https://www.google.com';
            }
            when else {
                throw new AACRCustomException('Failure to execute action: ' + action, 'V_FreemanIntegration.call()', 'FreemanIntegration');
            }
        }
    }

}