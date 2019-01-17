/*
 * Sets up exception handler.
 * Must be called once before any calls to tester_run().
 */
void tester_setup();

/*
 * Opposite of tester_setup.
 * Should be called at the end.
 */
void tester_cleanup();

/*
 * Executes the given arithmetic function specifier on rs and rt.
 * If an arithmetic overflow occurred, stores 1 in *overflow.
 */
int tester_run(int rs, int rt, int func, int *overflow, int op);
