Let's update our controller to use method security and make sure that the requester actually owns the data being requested.

1. Use method security to enforce ownership.

   Above the `CashCardController#findById` signature, configure Spring Security to compare the cash card's owner to the logged-in user with the `@PostAuthorize` annotation like so:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardController.java
   text: "findById"
   description:
   ```

   ```java
   @PostAuthorize("returnObject.body.owner == authentication.name")
   @GetMapping("/{requestedId}")
   public ResponseEntity<CashCard> findById(@PathVariable Long requestedId) {
         return this.cashCards.findById(requestedId)
              .map(ResponseEntity::ok)
              .orElseGet(() -> ResponseEntity.notFound().build());
   }
   ```

   `@PostAuthorize` needs a new import, too:

   ```java
   import org.springframework.security.access.prepost.PostAuthorize;
   ```

1. Understand what's going on.

   So, what's happening in the `@PostAuthorize` annotation?

   In the lesson, we explained that `returnObject` is the `ResponseEntity<CashCard>` return value. So `returnObject.body.owner` will give us the _owner_ of the cash card being returned.

   Now, if that `owner` doesn't match the user requesting it, Spring Security will throw an `AccessDeniedException`.

   With that explained, let's run the test to see if a user can still access a cash card that they don't own.

1. Rerun the tests.

   Now, when you run the test, it passes!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardApplicationTests > shouldReturnForbiddenWhenCardBelongsToSomeoneElse() PASSED
   ...
   BUILD SUCCESSFUL in 4s
   ```

We did it!