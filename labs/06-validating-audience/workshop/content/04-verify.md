It's our choice which audiences our `resourceserver` will allow.

As you can see in our minter, we've chosen an audience of `cashcard-client`.

Let's add a test that validates that the `cashcard-client` audience is required to make valid requests.

1. Create a new invalid-audience test.

   Let's add a new test that configures a blatantly invalid audience and expects the correct indications of this error.

   Take note of the header, which should specify `aud claim is not valid`.

   ```editor:open-file
   file: ~/exercises/src/test/java/example/cashcard/CashCardSpringSecurityTests.java
   ```

   ```java
   @Test
   void shouldNotAllowTokensWithAnInvalidAudience() throws Exception {
       String token = mint((claims) -> claims.audience(List.of("https://wrong")));

       this.mvc.perform(get("/cashcards/100").header("Authorization", "Bearer " + token))
                .andExpect(status().isUnauthorized())
                .andExpect(header().string("WWW-Authenticate", containsString("aud claim is not valid")));
   }
   ```

1. Run the tests.

   Run the tests and check out the results:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardSpringSecurityTests > shouldNotAllowTokensWithAnInvalidAudience() FAILED
       java.lang.AssertionError: Status expected:<401> but was:<200>
   ```

   Well, that's interesting!

   It's kind of funny to see `200 OK` as a _failure_ result, but that's what it is in this case, since we want the test to eventually fail due to an invalid JWT audience.

   Now, let's make the appropriate configuration changes, so that we know the audience is wrong.

1. Update our Spring Security configuration.

   We need to configure the valid `audiences` for our application.

   In the `application.yml`, add an audience value of `cashcard-client` to our existing OAuth2 `resourceserver` configuration.

   It should look like this:

   ```editor:select-matching-text
   file: ~/exercises/src/main/resources/application.yml
   text: "resourceserver"
   description:
   ```

   ```yaml
   spring:
     security:
       oauth2:
         resourceserver:
           jwt:
             public-key-location: classpath:authz.pub
             audiences: cashcard-client # <== Add this!
   ```

   By adding the `audiences` property, you're telling Spring Security to ensure that each JWT contains an `aud` claim with a value of `cashcard-client`.

1. Verify the audience is enforced.

   Running the test again will pass!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 7s
   ```

   Great! We're now properly validating the audience defined in the JWT.

But, what if the JWT is expired?

