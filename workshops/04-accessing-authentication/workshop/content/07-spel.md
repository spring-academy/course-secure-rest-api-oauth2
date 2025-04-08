You can use the SpEL (Spring Expression Language) to get more specific information.

1. Apply a SpEL expression.

   Once again, modify the `CashCardController#findAll` method with the SpEL expression `expression="authentication.name"`, which fetches the `name` from the `Authentication`.

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardController.java
   text: "findAll"
   description:
   ```

   ```java
   @GetMapping
   public ResponseEntity<Iterable<CashCard>> findAll(@CurrentSecurityContext(expression="authentication.name") String owner) {
     var result = this.cashCards.findByOwner(owner);
     return ResponseEntity.ok(result);
   }
   ```

   Now, you're using the SpEL expression `authentication.name` that will be assigned to the `owner`. Isn't that nice?

1. Test and verify.

   This is familiar!

   Since we just refactored implementation with no functionality changes, our tests and request results should remain unchanged.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 5s
   ```

   Feel free to **restart the application** and request all of `sarah1`'s cash cards, too.

   ```shell
   [~/exercises] $ http :8080/cashcards -A bearer -a $TOKEN
   ...
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
     }
   ]
   ```

Next, let's try something fancy.
