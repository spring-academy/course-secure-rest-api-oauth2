Let's require that any `GET /cashcards` request has **read access**.

We can do this by adding the appropriate request matcher to the new `SecurityFilterChain`.

1. Add the `read` scope to the `SecurityFilterChain`.

   Go back to the `CashCardApplication#appSecurity` method and add the `SCOPE_cashcard:read` scope for all `cashcards/` requests:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardApplication.java
   text: ".authorizeHttpRequests"
   description:
   ```

   ```java
   ...
   .authorizeHttpRequests((authorize) -> authorize
     .requestMatchers(HttpMethod.GET,"/cashcards/**")
       .hasAuthority("SCOPE_cashcard:read")
     .anyRequest().authenticated()
   ...
   ```

   Be sure to add the new, required `import` statement:

   ```java
   import org.springframework.http.HttpMethod;
   ```

   With this request matcher, you're saying that a JWT must be granted the `cashcard:read` scope in order to access `GET` URIs that begin with `/cashcards` .

   What happens if you run the `CashCardApplicationTests` tests?

1. Rerun the tests.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardApplicationTests > shouldReturnACashCardWhenDataIsSaved() FAILED
    java.lang.AssertionError: Status expected:<200> but was:<403>
   ...
   CashCardApplicationTests > shouldCreateANewCashCard() FAILED
       java.lang.AssertionError: Status expected:<200> but was:<403>
   ...
   CashCardApplicationTests > shouldReturnAllCashCardsWhenListIsRequested() FAILED
       java.lang.AssertionError: Status expected:<200> but was:<403>
   ...
   > Task :test FAILED
   ```

   Look at that! Each test that performs a `GET` has failed.

   ### Learning Moment: Two Requests, One Failure

   Of the above tests that failed, one test performs two separate requests: `CashCardApplicationTests#shouldCreateANewCashCard`.

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardApplicationTests.java
   text: "void shouldCreateANewCashCard()"
   description:
   ```

   Taking a look at the failure stack trace for `shouldCreateANewCashCard()` and the test code, you can see that the first request (the `POST`) succeeded while the second request (the `GET`) failed.

   ```java
   void shouldCreateANewCashCard() throws Exception {
      // POST succeeded
      String location = this.mvc.perform(post("/cashcards")
      ...
      // GET failed
      this.mvc.perform(get(location))
      ...
   }
   ```

   Can you think of why the `POST` didn't fail?

   That's right! The configuration we added is only securing the `GET`. Later on in the lab, we'll add security for the `POST` as well.

1. Configure the `read` scope in the tests.

   Now that our Spring Security configuration requires the `read` scope for all `GET /cashcards` requests, we need to include this scope in our test requests, too.

   Luckily, we only need to make a few changes.

   At the class level, you'll find the `@WithMockUser(username = "sarah1")`. Update this configuration to add the correct scope:

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardApplicationTests.java
   text: "@WithMockUser"
   description:
   ```

   ```java
   @SpringBootTest
   @AutoConfigureMockMvc
   @WithMockUser(username = "sarah1", authorities = {"SCOPE_cashcard:read"})
   class CashCardApplicationTests { ... }
   ```

   Now, if you try the tests again, what happens?

1. Rerun the tests... again!

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

   When you rerun the tests, you'll see that everything passes _except_ for `CashCardApplicationTests#shouldCreateANewCashCard`, which uses user `esuez5` instead of `sarah1` - just to keep us on our toes.

   You need to add the `authorities` to the `@WithMockUser` annotation on `shouldCreateANewCashCard`, too.

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardApplicationTests.java
   text: "@WithMockUser(username=\"esuez5\""
   description:
   ```

   ```java
   @WithMockUser(username="esuez5", authorities = {"SCOPE_cashcard:read"})
   @Test
   @DirtiesContext
   void shouldCreateANewCashCard() throws Exception { ... }
   ```

   Can you guess what's next?

1. Rerun the tests!

   You'll be thrilled to see that the tests finally pass again!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 4s
   ```

   Good job!

We've added a `read` scope, but what about requests that _write_ data?
