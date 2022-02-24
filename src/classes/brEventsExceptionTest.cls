/**
 * Created by mitfity on 16.08.2019.
 */

@IsTest
private class brEventsExceptionTest {

    @IsTest
    static void testException() {
        Boolean exceptionWorks = false;

        try {
            throw new brEventsException('test');
        } catch (brEventsException e) {
            exceptionWorks = true;
        } finally {
            System.assertEquals(true, exceptionWorks);
        }
    }
}