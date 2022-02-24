/**
 * Created by mitfity on 17.07.2019.
 */

@IsTest
private class brParticipationExceptionTest {

    @IsTest
    static void testException() {
        Boolean exceptionThrown = false;

        try {
            throw new brParticipationException('');
        } catch (brParticipationException e) {
            exceptionThrown = true;
        } finally {
            System.assertEquals(true, exceptionThrown);
        }
    }
}