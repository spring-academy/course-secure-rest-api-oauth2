As you learned already, Spring Security tests by default that the JWT isn't expired.

Let's create one more test to confirm this, using the same approach that we just covered.

1. Add the expired-token test.

   Create a test like the invalid audience one.

   You can copy it for now and rename it to `shouldNotAllowTokensThatAreExpired`, but _change the expectation_ that the JWT has expired.

   Note that we haven't actually expired the token yet, which we'll as the next step.

   ```editor:open-file
   file: ~/exercises/src/test/java/example/cashcard/CashCardSpringSecurityTests.java
   ```

   ```java
   @Test
   void shouldNotAllowTokensThatAreExpired() throws Exception {
       String token = mint();
       this.mvc.perform(get("/cashcards/100").header("Authorization", "Bearer " + token))
               .andExpect(status().isUnauthorized())
               .andExpect(header().string("WWW-Authenticate", containsString("Jwt expired")));
   }
   ```

   When we run the tests, we see that we don't have a message about an expired JWT yet:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardSpringSecurityTests > shouldNotAllowTokensThatAreExpired() FAILED
       java.lang.AssertionError: Status expected:<401> but was:<200>
   ```

   Once again our request is succeeding with a `200 OK` rather than failing with a `401 Unauthorized` because at this point the request _is_ valid!

   Now, we can expire the token and see what happens.

1. Expire the token.

   Next, change the claim set so that the token is expired.

   You'll need to change the `issuedAt`, as well as `expiresAt` values, as follows:

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardSpringSecurityTests.java
   text: "shouldNotAllowTokensThatAreExpired"
   description:
   ```

   ```java
   @Test
   void shouldNotAllowTokensThatAreExpired() throws Exception {
       String token = mint((claims) -> claims
               .issuedAt(Instant.now().minusSeconds(3600))
               .expiresAt(Instant.now().minusSeconds(3599))
       );
       this.mvc.perform(get("/cashcards/100").header("Authorization", "Bearer " + token))
               .andExpect(status().isUnauthorized())
               .andExpect(header().string("WWW-Authenticate", containsString("Jwt expired")));
   }
   ```

   If you run this test, then it should pass.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 7s
   ```

   Perfect! Not only is our expired token resulting in a `401 Unauthorized`, we are also seeing the `Jwt expired` header as well.

No extra configuration is necessary!
