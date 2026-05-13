Let's start with our tests.

Notice that at `CashCardApplicationTests` is annotated with the `@WithMockUser` annotation. This annotation is what is automatically configuring authentication in our tests.

But, this is no longer specific enough since `@WithMockUser` defaults to a username of `user`.

We want to specify `sarah1` as the user for our tests to see how it behaves against our data set.

1. Specify the correct mock user.

   We need to tell our test which principal to use, which is `sarah1`.

   Modify the `@WithMockUser` annotation at the top of the test method to specify `sarah1` as the user like so:

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardApplicationTests.java
   text: "@WithMockUser"
   description:
   ```

   ```java
   @SpringBootTest
   @AutoConfigureMockMvc
   @WithMockUser(username = "sarah1")
   class CashCardApplicationTests {
    ...
   }
   ```

   Well that was easy! Is that all we need to do?

1. Modify our expectations.

   Take a look at `shouldReturnAllCashCardsWhenListIsRequested` in `CashCardApplicationTests`:

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardApplicationTests.java
   text: "shouldReturnAllCashCardsWhenListIsRequested"
   description:
   ```

   ```java
   @Test
   void shouldReturnAllCashCardsWhenListIsRequested() throws Exception {
       ...
          .andExpect(jsonPath("$.length()").value(3))
          .andExpect(jsonPath("$..owner").value(hasItem("sarah1")))
          .andExpect(jsonPath("$..owner").value(hasItem("esuez5")));
    }
   ```

   And look at our sample data:

   ```json
   [
     {
       "amount": 123.45,
       "id": 99,
       "owner": "sarah1"
     },
     {
       "amount": 1.0,
       "id": 100,
       "owner": "sarah1"
     },
     {
       "amount": 150.0,
       "id": 101,
       "owner": "esuez5"
     }
   ]
   ```

   We know that `sarah1` has only two cards, and `esuez5`'s Cash Cards should definitely _not_ be returned if `sarah1` is the requesting user!

   So, let's adjust the test accordingly.

   First, change the number of results returned to `2`:

   ```java
   @Test
   void shouldReturnAllCashCardsWhenListIsRequested() throws Exception {
       this.mvc.perform(get("/cashcards"))
               .andExpect(jsonPath("$.length()").value(2));
    }
   ```

   Then, replace `owner` expectations and expect that all the values should be equal to `sarah1` like so:

   ```java
   @Test
   void shouldReturnAllCashCardsWhenListIsRequested() throws Exception {
       this.mvc.perform(get("/cashcards"))
               .andExpect(jsonPath("$.length()").value(2))
               .andExpect(jsonPath("$..owner").value(everyItem(equalTo("sarah1"))));
    }
   ```

   You'll need the following additional `import` statements:

   ```java
   import static org.hamcrest.Matchers.equalTo;
   import static org.hamcrest.Matchers.everyItem;
   ```

1. Run the tests.

   Run the tests to see the results.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardApplicationTests > shouldReturnAllCashCardsWhenListIsRequested() FAILED
       java.lang.AssertionError: JSON path "$.length()" expected:<2> but was:<3>
   ```

   Even though we've specified `sarah1` as the user we are still getting everyone's Cash Cards back!

### Learning Moment: Defaults Aren't Enough

Though Spring Security does supply many defaults for us, it does not know how to use the principal from the JWT to filter our data.

We need to update our Controller to take the authenticated user into consideration when fetching Cash Cards from the database.

Let's do that now.
