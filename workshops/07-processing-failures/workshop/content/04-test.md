Let's follow the test-first pattern that we've used several times in this course.

We'll use a test to outline our desired expectations, then update the implementation to satisfy these requirements.

Let's add a test to show how our application should handle all errors from an invalid token.

In this case, we'll make sure our token is both _expired_ and has an _invalid audience_.

Then, we'll add expectations that state that _all_ of the authorization errors are returned in the error response, not just one.

With that, let's create a test that uses a super-invalid token.

1. Test for multiple authentication failures.

   In `CashCardSpringSecurityTests`, create a new test that contains all of the expectations we described above:

   ```editor:open-file
   file: ~/exercises/src/test/java/example/cashcard/CashCardSpringSecurityTests.java
   ```

   ```java
   @Test
   void shouldShowAllTokenValidationErrors() throws Exception {
       String expired = mint((claims) -> claims
               .audience(List.of("https://wrong"))
               .issuedAt(Instant.now().minusSeconds(3600))
               .expiresAt(Instant.now().minusSeconds(3599))
       );
       this.mvc.perform(get("/cashcards").header("Authorization", "Bearer " + expired))
               .andExpect(status().isUnauthorized())
               .andExpect(header().exists("WWW-Authenticate"))
               .andExpect(jsonPath("$.errors..description").value(
                           containsInAnyOrder(containsString("Jwt expired"), containsString("aud claim is not valid"))));
   }
   ```

   Be sure to add the two new `import` statements:

   ```java
   import static org.hamcrest.Matchers.containsInAnyOrder;
   import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
   ```

   That's a pretty big test!

   Notice that this test combines the two errors _and_ the two expectations from our other invalid-token tests: `shouldNotAllowTokensThatAreExpired` and `shouldNotAllowTokensWithAnInvalidAudience`.

   It leverages the autowired `JwtEncoder` to create a test JWT that's already expired _and_ has the wrong audience.

   Let's run our tests and see what happens.

1. Run the tests.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardSpringSecurityTests > shouldShowAllTokenValidationErrors() FAILED
    java.lang.AssertionError: No value at JSON path "$.errors..description"
        ...
        Caused by:
        java.lang.IllegalArgumentException: json can not be null or empty
            at com.jayway.jsonpath.internal.Utils.notEmpty(Utils.java:401)
   ...
   > Task :test FAILED
   ```

   Unsurprisingly, our test fails trying to parse the error format we're proposing but have not implemented.

We're finally ready to update our Spring Security configuration to handle multiple authentication errors at the same time. Let's do it!
