What we want to do is return the cash cards that belong to the authorized, authenticated owner who's using the repository, right?

To do that, we can reference the authenticated user by embedding a SpEL expression into the query.

1. Use the authenticated, authorized user.

   In `CashCardRepository`, replace `esuez5` with `:#{authentication.name}` in the query.

   It should look like this:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardRepository.java
   text: "findAll"
   description:
   ```

   ```java
   @Query("select * from cash_card cc where cc.owner = :#{authentication.name}")
   Iterable<CashCard> findAll();
   ```

   That looks like a pretty normal query with variable substitution!

1. Understand the SpEL expression.

   Let's take a moment to break down and understand the various parts of the SpEL expression we just added:

   - The `:` is how Spring Data JDBC identifies a dynamic parameter, whether that's an indexed parameter like `:1` or something more dynamic like what we're doing.
   - The `#{}` syntax is a common Spring idiom for the start and end of a SpEL expression.
   - The Spring Security part is simply `authentication.name`, or `SecurityContextHolder.getContext().getAuthentication().getName()`

   Pretty straightforward!

   If you run the test, what happens?

1. Rerun the tests.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardApplicationTests > shouldReturnAllCashCardsWhenListIsRequested() FAILED
       jakarta.servlet.ServletException: Request processing failed: org.springframework.expression.spel.SpelEvaluationException: EL1008E: Property or field 'authentication' cannot be found on object of type 'java.lang.Object[]' - maybe not public or not valid?
   ...
   > Task :test FAILED
   ```

   Yikes! What does `SpelEvaluationException: EL1008E` mean?

   This is failing because Spring Data doesn't know how to evaluate the `:#{authentication.name}`.

### Learning Moment: Which Dependency Enables What?

Something not obvious with the hard-coded `@Query` is that it was _not_ using Spring Security data authorization. The hard-coded version was just using standard Spring Data JDBC syntax.

The error _"Property or field 'authentication' cannot be found ... maybe not public or not valid?"_ is an indirect way of saying _"this SpEL property doesn't exist."_

For us, it's really that it doesn't exist _yet!_

The `authentication` SpEL property we want to use is provided by a dependency we haven't included.

Let's add the dependency we need to get our data authorization working properly.
