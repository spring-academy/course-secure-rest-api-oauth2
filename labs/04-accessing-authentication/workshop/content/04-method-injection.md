Remember when you read about `Authentication` as a parameter for a method in the previous lesson? We need to do that in our Controller.

1. Add `Authentication` to `findAll`

   Open `src/main/java/example/cashcard/CashCardController.java` and edit the `findAll`
   method and add the `Authentication` object as part of the method's parameter like so, making sure to add the new `import` statement:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardController.java
   text: "findAll"
   description:
   ```

   ```java
   import org.springframework.security.core.Authentication;
   ...

   @GetMapping
   public ResponseEntity<Iterable<CashCard>> findAll(Authentication authentication) {
     return ResponseEntity.ok(this.cashCards.findAll());
   }
   ```

1. Manually filter the data.

   Currently, this method returns every cash card in the database. Yikes! A given user should not be able to see everyone's data! As a next step, then, change the method so that it only returns cash cards that belong to the current owner.

   You can do this by comparing `Authentication#getName` to `CashCard#owner` like so:

   ```java
   import java.util.ArrayList;
   ...
   @GetMapping
   public ResponseEntity<Iterable<CashCard>> findAll(Authentication authentication) {
     var filtered = new ArrayList<CashCard>();
     this.cashCards.findAll().forEach(cashCard -> {
         if (cashCard.owner().equals(authentication.getName())){
             filtered.add(cashCard);
         }
     });
     return ResponseEntity.ok(filtered);
   }
   ```

   Hmm, that's quite a bit of manual looping and filtering.

   There's probably a better way of doing this, but let's start with this simple and readable implementation and see if it works.

1. Run the tests.

   Do you think our tests will pass now? Try it!

   If you run the test again it should pass. The code was fixed and is filtering out everything but `sarah1`'s cash cards!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 5s
   ```

1. Query the API and verify.

   First, **_Restart the application._** by hitting `CTRL-C` on the running Terminal pane, then rerunning `./gradlew bootRun`.

   Next, fetch all cash cards, supplying `sarah1`'s JWT:

   ```shell
   [~/exercises] http :8080/cashcards -A bearer -a $TOKEN
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

   It worked! Thanks to the `Authentication#getName` we can get the owner and filter the response.

That manual looping is kind of lame, though. Let's do better.
