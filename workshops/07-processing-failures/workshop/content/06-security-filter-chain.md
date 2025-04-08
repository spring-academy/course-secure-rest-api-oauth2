We need to get Spring Security to use our custom entry point instead of the default implementation.

To do this we'll construct a `SecurityFilterChain` bean, which you learned about in a previous lesson.

1. Create a new `SecurityFilterChain`.

   In `CashCardApplication`, publish a `SecurityFilterChain` like this one:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardApplication.java
   text: "@SpringBootApplication"
   description:
   ```

   ```java
   @Bean
   SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
           http
               .authorizeHttpRequests((authorize) -> authorize.anyRequest().authenticated())
               .oauth2ResourceServer((oauth2) -> oauth2
                   .jwt(Customizer.withDefaults())
           );
       return http.build();
   }
   ```

   Be sure to add all the new required `import` statements:

   ```java
   import org.springframework.context.annotation.Bean;
   import org.springframework.security.config.Customizer;
   import org.springframework.security.config.annotation.web.builders.HttpSecurity;
   import org.springframework.security.web.AuthenticationEntryPoint;
   import org.springframework.security.web.SecurityFilterChain;
   ```

   This is equivalent to the one that Spring Boot publishes for you.

   Now that we're leaving the default one behind, though, it's time to declare our own.

   **_Note:_** Remember that when you supply a `SecurityFilterChain` bean, you should always declare both your authorization rules and well as your authentication mechanisms, even if there's only one that you're customizing.

1. Add the custom entry point.

   Now, tell `oauth2ResourceServer` that you want it to use our custom authentication entry point.

   First, add it to the `appSecurity` method signature, like this:

   ```java
   @Bean
   SecurityFilterChain appSecurity(HttpSecurity http,
          ProblemDetailsAuthenticationEntryPoint entryPoint) throws Exception { ... }
   ```

   Next, apply that `entryPoint` to `oauth2ResourceServer#authenticationEntryPoint` in the following way:

   ```java
   @Bean
   SecurityFilterChain appSecurity(HttpSecurity http,
          ProblemDetailsAuthenticationEntryPoint entryPoint) throws Exception {
           http
           .authorizeHttpRequests((authorize) -> authorize.anyRequest().authenticated())
           .oauth2ResourceServer((oauth2) -> oauth2
               .authenticationEntryPoint(entryPoint) // <== Add it here!
               .jwt(Customizer.withDefaults())
           );
       return http.build();
   }
   ```

   We've added a lot of code between the `SecurityFilterChain` and the `ProblemDetailsAuthenticationEntryPoint` changes we implemented!

   Let's find out how this has affected the expectations in our new test.

1. Run the tests.

   Now run the tests again, and you'll see that all of the `CashCardSpringSecurityTests` fail.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardSpringSecurityTests > shouldNotAllowTokensThatAreExpired() FAILED
       java.lang.AssertionError: Response header 'WWW-Authenticate'
       Expected: a string containing "Jwt expired"
            but: was null
   ...
   CashCardSpringSecurityTests > shouldShowAllTokenValidationErrors() FAILED
       java.lang.AssertionError: Response should contain header 'WWW-Authenticate'
   ...
   CashCardSpringSecurityTests > shouldNotAllowTokensWithAnInvalidAudience() FAILED
       java.lang.AssertionError: Response header 'WWW-Authenticate'
       Expected: a string containing "aud claim is not valid"
            but: was null
   ...
   > Task :test FAILED
   ```

We've actually taken a step backwards: the `WWW-Authenticate` is now missing from our error response!