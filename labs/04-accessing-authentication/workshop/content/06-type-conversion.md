In the related lesson, you learned about the `@CurrentSecurityContext` and how it can help remove some of the boilerplate around getting the current user. Let's try that out.

1. Use `@CurrentSecurityContext`.

   Modify the `CashCardController#findAll` method by adding `@CurrentSecurityContext(expression = "authentication")` before the `Authentication` parameter like so, making sure to add the new import statement:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardController.java
   text: "findAll"
   description:
   ```

   ```java
   import org.springframework.security.core.annotation.CurrentSecurityContext;
   ...
   @GetMapping
   public ResponseEntity<Iterable<CashCard>> findAll(@CurrentSecurityContext(expression = "authentication") Authentication authentication){
     var result = this.cashCards.findByOwner(authentication.getName());
     return ResponseEntity.ok(result);
   }
   ```

   Wait! What??

   Maybe you're wondering now whether you're adding unnecessary code, since you already got the owner using just the `Authentication`. Don't worry. In this case, you need to step back just a little, so you can understand that by using the `@CurrentSecurityContext` you can get a more specific type, in this case the `Authentication`.

   You'll see the benefit of using this annotation in the following sections.

1. Run the tests and query the API.

   If you run the test with no modifications, it should pass!

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

Next, let's refactor once gain and try something more sophisticated.
