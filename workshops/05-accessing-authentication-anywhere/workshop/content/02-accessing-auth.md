So far, you've seen that you can get the authentication details using either `Authentication#getName`, `@CurrentSecurityContext(expression="authentication.name")`, or your own meta-annotation (`@CurrentOwner`) to get the name.

You have another option with `SecurityContextHolder`, a static class that holds the authentication details. Because it's _static_, it can be _accessed anywhere_.

Let's try it out!

1. Update the repository.

   To try this out, open the `CashCardRepository` interface and add a default implementation for the `findAll()` method with the following code:

   ```editor:open-file
   file: ~/exercises/src/main/java/example/cashcard/CashCardRepository.java
   ```

   ```java
   default Iterable<CashCard> findAll() {
       SecurityContext context = SecurityContextHolder.getContext();
       Authentication authentication = context.getAuthentication();
       String owner = authentication.getName();
       return findByOwner(owner);
   }
   ```

   Be sure to add the imports needed:

   ```java
   import org.springframework.security.core.context.SecurityContext;
   import org.springframework.security.core.context.SecurityContextHolder;
   import org.springframework.security.core.Authentication;
   ```

   The idea here is that you can adjust the `findAll()` method to ensure that only those cash cards that belong to the logged in user will be returned from `findAll()`.

   By the way, notice that the code isn't checking for `null`. That's because the filter chain, by default, populates the `SecurityContext` with an anonymous authentication instance. This means that neither `SecurityContextHolder#getContext` nor `SecurityContext#getAuthentication` will return `null`.

   **Note:** Stay tuned for a later lesson, where we'll replace this with a Spring-Security-enriched query!

1. Simplify the controller.

   Now, you can change the controller to call `findAll` directly instead of `findByOwner`.

   Find the `CashCardController#findAll` method and do the following two things:

   - Remove the `@CurrentOwner` method parameter from the controller `findAll` method.
   - Instead of calling `findByOwner`, call `findAll` on the repository.

   The resulting method should look like this:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardController.java
   text: "findAll"
   description:
   ```

   ```java
   @GetMapping
   public ResponseEntity<Iterable<CashCard>> findAll() {
       return ResponseEntity.ok(cashCards.findAll());
   }
   ```

   Now that's simple!

1. Run the tests.

   The tests should still pass since what we did here was a _refactoring_ that did not change the behavior of the application, and only changed how the application is implemented.

   So, run the tests and confirm that everything works as well as it used to!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 7s
   ```

Next, let's get a bit of insight into what's happening with the `SecurityContextHolder` at runtime.
