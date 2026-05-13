We'll need Spring Security and Spring Data to work together in order to simplify our code.

For example, we can use the `@Query` annotation from Spring Data to replace this boilerplate with a custom query.

Let's start with _hard-coding_ the user. This is not a long-term solution, of course, but let's see the impact of this first simple step on our path towards data-authorization bliss.

1. Hard-code the user.

   In the `CashCardRepository#findAll` method, remove its `default` implementation and replace it with a `@Query` implementation like this:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardRepository.java
   text: "findAll"
   description:
   ```

   ```java
   @Query("select * from cash_card cc where cc.owner = 'esuez5'")
   Iterable<CashCard> findAll();
   ```

   You'll need to add a new `import` statement as well:

   ```java
   import org.springframework.data.jdbc.repository.query.Query;
   ```

   This hard-coded and restrictive query is definitely going to mess up our tests! Let's run them and see what's happening.

1. Run the tests.

   When we run the tests we see that `CashCardApplicationTests#shouldReturnAllCashCardsWhenListIsRequested` is failing.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardApplicationTests > shouldReturnAllCashCardsWhenListIsRequested() FAILED
       java.lang.AssertionError: JSON path "$.length()" expected:<2> but was:<1>
   ...
   > Task :test FAILED
   ```

   This is great! We expect this response since this test is expecting a result for `sarah1`, and we are hard-coding the owner to be `esuez5`.

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardApplicationTests.java
   text: "shouldReturnAllCashCardsWhenListIsRequested"
   description:
   ```

   It would have been strange if nothing failed!

We know our new `@Query` is working, so now let's make it a bit smarter.
