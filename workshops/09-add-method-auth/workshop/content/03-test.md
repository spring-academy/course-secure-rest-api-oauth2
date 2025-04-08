We already have a test in `CashCardApplicationTests` for our `GET cashcards/<id>` endpoint: `shouldReturnACashCardWhenDataIsSaved()`.

Take a look at it now:

```editor:select-matching-text
file: ~/exercises/src/test/java/example/cashcard/CashCardApplicationTests.java
text: "shouldReturnACashCardWhenDataIsSaved"
description:
```

```java
@Test
void shouldReturnACashCardWhenDataIsSaved() throws Exception {
      this.mvc.perform(get("/cashcards/99"))
           .andExpect(status().isOk())
           .andExpect(jsonPath("$.id").value(99))
           .andExpect(jsonPath("$.owner").value("sarah1"));
}
```

You can see that it's requesting a cash card whose id is `99` and owner is `sarah1`. If you run that test, it passes, but what happens if you specify a different user?

1. Add a test verifying ownership.

   Create a new test based on `shouldReturnACashCardWhenDataIsSaved` called `shouldReturnForbiddenWhenCardBelongsToSomeoneElse`.

   Then, add a `@WithMockUser` annotation that sets the user to our other good friend `esuez5` with the `SCOPE_cashcard:read` authority like so:

   ```java
   @WithMockUser(username = "esuez5", authorities = {"SCOPE_cashcard:read"})
   @Test
   void shouldReturnForbiddenWhenCardBelongsToSomeoneElse() throws Exception { ... }
   ```

   Of course, `esuez5` should not have access to `sarah1`'s cash cards, so let's change the `isOk()` expectation to `isForbidden()`, since that's what we want to happen when `esuez5` requests cash card owned by `sarah1`, `cashcard#99` in this case.

   That's it! No other expectations needed.

   You can see the completed test here:

   ```java
   @WithMockUser(username = "esuez5", authorities = {"SCOPE_cashcard:read"})
   @Test
   void shouldReturnForbiddenWhenCardBelongsToSomeoneElse() throws Exception {
         this.mvc.perform(get("/cashcards/99"))
              .andExpect(status().isForbidden());
   }
   ```

   Let's see how our new test passes or fails at the moment.

1. Run the tests.

   When you run the tests you'll see our new test fails in the following way:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardApplicationTests > shouldReturnForbiddenWhenCardBelongsToSomeoneElse() FAILED
    java.lang.AssertionError: Status expected:<403> but was:<200>
   ...
   > Task :test FAILED
   ```

   Wait, that's a `200 OK` response! `esuez5` should _not_ have been able to fetch `sarah1`'s cash card!

   Can you tell why Spring Security didn't forbid this request?

   The reason is that the request only requires the `SCOPE_cashcard:read` authority, but _doesn't verify who owns the record!_

   That's no good!

Let's make our Spring Security configuration smarter.
