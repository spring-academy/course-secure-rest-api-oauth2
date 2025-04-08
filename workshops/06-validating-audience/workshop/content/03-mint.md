In this lab, we'll need a real token, so we'll be using the new `mint()` methods instead of mocking the authentication process with `@WithMockUser`.

Let's try creating a test that mints a valid token, and gets a valid response.

1. Add a new test to verify that tokens are required.

   Start by adding this _incomplete_ test in `CashCardSpringSecurityTests`, which will test that our application requires valid tokens to make requests.

   ```editor:open-file
   file: ~/exercises/src/test/java/example/cashcard/CashCardSpringSecurityTests.java
   ```

   ```java
   @Test
   void shouldRequireValidTokens() throws Exception {
       this.mvc.perform(get("/cashcards/100"))
           .andExpect(status().isOk());
   }
   ```

   Run the tests and verify that we're `Unauthorized` without a token:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardSpringSecurityTests > shouldRequireValidTokens() FAILED
       java.lang.AssertionError: Status expected:<200> but was:<401>
   ```

   That's good! It seems like tokens are required.

   Now, let's add a token and get our test passing.

1. Mint a token to fix the test.

   Now, modify our new test method to mint a token, and include it using the `Authorization: Bearer` header, as follows:

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardSpringSecurityTests.java
   text: "shouldRequireValidTokens"
   description:
   ```

   ```java
   @Test
   void shouldRequireValidTokens() throws Exception {
       String token = mint();
       this.mvc.perform(get("/cashcards/100").header("Authorization", "Bearer " + token))
           .andExpect(status().isOk());
   }
   ```

   Run the tests and see what the results are now:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 7s
   ```

   Great! We're minting tokens and making money. Or, at least making tests pass!

Now, let's make sure that we require a valid audience.

