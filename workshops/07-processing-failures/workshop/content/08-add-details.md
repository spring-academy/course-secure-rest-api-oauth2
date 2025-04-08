Spring Framework 6 added support for the Problem Details spec, so let's use that functionality here in your custom authentication entry point to provide more error details in the response.

The goal is to have the response include extra error details.

As a refresher, we're looking for response details such as the following:

```json
{
  "type": "https://tools.ietf.org/html/rfc6750#section-3.1",
  "title": "Invalid Token",
  "status": 401,
  "errors": [
    {
      "errorCode": "invalid_token",
      "description": "Jwt expired at <DATE HERE>",
      "uri": "https://tools.ietf.org/html/rfc6750#section-3.1"
    },
    {
      "errorCode": "invalid_token",
      "description": "The aud claim is not valid",
      "uri": "https://tools.ietf.org/html/rfc6750#section-3.1"
    }
  ]
}
```

We'll need to add the appropriate Problem Details behavior our new entry point.

Let's use an `ObjectMapper` to help with that.

1. Autowire an `ObjectMapper`.

   In `ProblemDetailsAuthenticationEntryPoint`, autowire `ObjectMapper` using constructor-injection like this:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/ProblemDetailsAuthenticationEntryPoint.java
   text: "ProblemDetailsAuthenticationEntryPoint"
   description:
   ```

   ```java
   @Component
   public class ProblemDetailsAuthenticationEntryPoint implements AuthenticationEntryPoint {

       private final AuthenticationEntryPoint delegate = new BearerTokenAuthenticationEntryPoint();

       private final ObjectMapper mapper;

       public ProblemDetailsAuthenticationEntryPoint(ObjectMapper mapper) {
               this.mapper = mapper;
       }
       ...
   }
   ```

   The `ObjectMapper` will give us the ability to turn a Java object into JSON, which we can add to our error response.

1. Add the errors.

   When the validation fails, Spring Security throws a `JwtValidationException`, which contains all the `OAuth2Error`'s for the invalid JWT.

   So now, enhance the code to look for the collection of `OAuth2Error`'s and populate a `ProblemDetails` instance with that information like so:

   ```java
   @Override
   public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException)
           throws IOException, ServletException {

       this.delegate.commence(request, response, authException);

       if (authException.getCause() instanceof JwtValidationException validation) {
           ProblemDetail detail = ProblemDetail.forStatus(401);
           detail.setType(URI.create("https://tools.ietf.org/html/rfc6750#section-3.1"));
           detail.setTitle("Invalid Token");
           detail.setProperty("errors", validation.getErrors());
           this.mapper.writeValue(response.getWriter(), detail);
       }
   }
   ```

   If we're adding all `JwtValidationException`s, will our new test be happy?

1. Run the tests.

   Now, when we run our tests, they pass!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardSpringSecurityTests > shouldShowAllTokenValidationErrors() PASSED
   ...
   BUILD SUCCESSFUL in 4s
   ```

Let's ping the API and see what the responses look like now.