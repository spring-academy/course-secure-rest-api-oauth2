This is an interesting point: because have decided to create a custom entry point, we are now responsible for implementing some of the functionality that existed in the default entry point. Setting the `WWW-Authenticate` header is one such responsibility.

Let's add back the missing header.

1. Add the `WWW-Authenticate` header via delegation.

   Change our custom authentication entry point to _delegate_ to `BearerTokenAuthenticationEntryPoint`.

   This will have the effect of re-adding the missing header.

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/ProblemDetailsAuthenticationEntryPoint.java
   text: "public void commence"
   description:
   ```

   ```java
   @Component
   public class ProblemDetailsAuthenticationEntryPoint implements AuthenticationEntryPoint {

       private final AuthenticationEntryPoint delegate = new BearerTokenAuthenticationEntryPoint();

       @Override
       public void commence(HttpServletRequest request, HttpServletResponse response,
               AuthenticationException authException) throws IOException, ServletException {
               this.delegate.commence(request, response, authException);
       }
   }
   ```

   But wait a moment! We didn't add the `WWW-Authenticate` back at all!

   All we did was call `this.delegate.commence(...)`.

   What's happening there? What is the `delegate`?

   ### Learning Moment: Favor Composition over Inheritance

   A common design principle to Spring Security components is delegation. That's because Spring Security favors composition over inheritance.

   This comes into play here as you consider how you'll add the `WWW-Authenticate` header into your `AuthenticationEntryPoint`. Certainly, `BearerTokenAuthenticationEntryPoint` could do it! Thus it might be tempting to have our custom entry point _subclass_ `BearerTokenAuthenticationEntryPoint`.

   But, that `BearerTokenAuthenticationEntryPoint` cannot be extended because it is declared as `final`!

   "Why does Spring Security do this to me?!" I hear you say.

   The answer is that, generally speaking, Spring Security wants you to _delegate_ instead of subclass.

   Now that we have that bit of context, let's see how our tests are doing.

1. Rerun the tests.

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

   Ok, we're back to the `JSON path` errors we had earlier before we started adding our custom entry pont.

Now we can add extra Problem Details that will include the token authorization errors, such as expiration and invalid audience errors.

Let's do that now.
