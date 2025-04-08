Since we've added the `read` scope for `GET` requests, it makes sense for us to add a `write` scope for `POST` requests.

We'll take that idea a step further: Let's add the write access for _any remaining_ `/cashcards` endpoints.

1. Add the `write` scope to the `SecurityFilterChain`.

   Add the following additional request matcher to the `SecurityFilterChain`:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardApplication.java
   text: "requestMatchers"
   description:
   ```

   ```java
   ...
   .requestMatchers(HttpMethod.GET,"/cashcards/**")
         .hasAuthority("SCOPE_cashcard:read")
   // Add the requestMatchers below
   .requestMatchers("/cashcards/**")
         .hasAuthority("SCOPE_cashcard:write")
   ...
   ```

   With this request matcher, you're saying that users must be granted the `cashcard:write` scope for URIs that begin with `/cashcards`, but aren't covered by the `GET`'s `read` scope.

   Because this is positioned _after_ the `GET`-specific rule, it'll only be run for non-`GET` `/cashcards` endpoints.

   The implication is that this rule will apply to our `POST /cashcards` endpoint, _as well as any other non-`GET` endpoints_ that are added down the road.

   Now before continuing, double-check your configuration against the following listing:

   ```java
   @Bean
   SecurityFilterChain appSecurity(HttpSecurity http,
         AuthenticationEntryPoint entryPoint)
         throws Exception {
      http
         .authorizeHttpRequests((authorize) -> authorize
            .requestMatchers(HttpMethod.GET,"/cashcards/**")
               .hasAuthority("SCOPE_cashcard:read")
            .requestMatchers("/cashcards/**")
               .hasAuthority("SCOPE_cashcard:write")
            .anyRequest().authenticated()
         )
         .oauth2ResourceServer((oauth2) -> oauth2
            .authenticationEntryPoint(entryPoint)
            .jwt(Customizer.withDefaults())
         );
      return http.build();
   }
   ```

   How did this change impact our tests?

1. Run the tests.

   If you run the tests, you'll find that the `CashCardApplicationTests#shouldCreateANewCashCard` is failing again (as promised!).

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardApplicationTests > shouldCreateANewCashCard() FAILED
       java.lang.AssertionError: Status expected:<200> but was:<403>
   ...
   > Task :test FAILED
   ```

   We've added the `write` scope to the `SecurityFilterChain`, so what's missing?

   Like in the last step, once we add an authorization rule to our `SecurityFilterChain`, we need to update the corresponding tests.

   Let's do that now.

1. Add the `write` scope to the `POST` test

   In the `CashCardApplicationTests#shouldCreateANewCashCard` method, update the `authorities` by adding the `write` scope to its `@WithMockUser` annotation:

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardApplicationTests.java
   text: "@WithMockUser(username=\"esuez5\""
   description:
   ```

   ```java
   @WithMockUser(username="esuez5", authorities = {"SCOPE_cashcard:read", "SCOPE_cashcard:write"})
   @Test
   @DirtiesContext
   void shouldCreateANewCashCard() throws Exception { ... }
   ```

1. Rerun the tests.

   Now, if you run all the tests, they'll pass!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 4s
   ```

That's great!

Next, let's play around with the running application and see our scope changes in action.
