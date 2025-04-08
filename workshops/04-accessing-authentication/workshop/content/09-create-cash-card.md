We have one more remaining security hole: creating `CashCard`s.

The authenticated, authorized user supplied by Spring Security should be used as the `owner` when creating a new `CashCard`.

But, our code isn't written this way! Our `POST` endpoint expects the `owner` to be submitted as part of the `CashCard` payload. This is bad!

Why? We risk allowing users to create `CashCard`s for _someone else_!

Let's do a quick check to see if we're allowing this now.

1. Try to create a `CashCard` for the wrong user.

   Start the application in one of the Terminal panes.

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew bootRun
   ```

   Then in the other Terminal pane, try to create a new Cash Card, but for some random user that's _not_ `sarah1`.

   ```shell
   [~/exercises] $ http -A bearer -a $TOKEN :8080/cashcards amount=314.15 owner=anyone
   HTTP/1.1 201
   ...
   {
      "amount": 314.15,
      "id": 1,
      "owner": "anyone"
   }
   ```

   Yikes! The `owner` is _not_ `sarah1` from our JWT. Our `POST` endpoint is insecure!

   Let's fix this and ensure that only the authenticated, authorized user owns the `CashCard`s they are creating.

1. Update the `POST` test.

   To prove that we don't need to submit an `owner`, let's remove it completely from the payload of our test.

   Edit `shouldCreateANewCashCard` in `src/test/java/academy/spring/cashcard/CashCardApplicationTests.java` to remove the `owner`.

   ```editor:select-matching-text
   file: ~/exercises/src/test/java/example/cashcard/CashCardApplicationTests.java
   text: "shouldCreateANewCashCard"
   description:
   ```

   ```java
   void shouldCreateANewCashCard() throws Exception {
       String location = this.mvc.perform(post("/cashcards")
               ...
               // delete the "owner" below
               .content("""
                       {
                           "amount" : 250.00
                       }
                       """))
       ...
   ```

1. Run the tests.

   What do you think will happen when we run the tests? They will likely fail, but can you guess why?

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   CashCardApplicationTests > shouldCreateANewCashCard() FAILED
   jakarta.servlet.ServletException: Request processing failed: org.springframework.data.relational.core.conversion.DbActionExecutionException: Failed to execute InsertRoot{entity=CashCard[id=null, amount=250.0, owner=null], idValueSource=GENERATED}
   ```

   Interesting! It seems that we tried to create a new record in the `CASH_CARD` table in the database, but `owner=null` is not allowed.

   Let's use the techniques we've learned in this lab to fix this.

1. Update the `POST` endpoint in the controller.

   Once again we'll use the `@CurrentOwner` to ensure that the correct `owner` is saved with the new `CashCard`.

   **_Tip:_** While you're at it, use the handy `CashCardRequest` record we've provided for you. Take a moment to check it out, as we'll go over it in more detail soon.

   ```java
    @PostMapping
    public ResponseEntity<CashCard> createCashCard(@RequestBody CashCardRequest cashCardRequest, UriComponentsBuilder ucb, @CurrentOwner String owner) {
        CashCard cashCard = new CashCard(cashCardRequest.amount(), owner);
        CashCard savedCashCard = this.cashCards.save(cashCard);
        ...
    }
   ```

1. Run the tests.

   Once again everything passes!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 7s
   ```

Spring Security for the win!

### Learning Moment: Why Use the `CashCardRequest`?

Take a moment to compare the `CashCard` and `CashCardRequest` records:

```java
public record CashCard(@Id Long id, Double amount, String owner) { ... }

public record CashCardRequest(Double amount) { ... }
```

Clearly, the `CashCardRequest` looks similar to the `CashCard`, but only supports the `amount` field.

So, why is it important to use the `CashCardRequest` for, well, cash card requests? The answer is that _it is more secure to do so_:

1. Unlike using `CashCard`, as we did before, there's no chance someone will update the controller code to accidentally pull the owner from the request body, and use it incorrectly.
1. It's easier to write code that detects if the owner is passed as part of the request body and fail, allowing API clients to correct their insecure behavior more quickly.

The lesson is this: your API should only support the minimum data needed for it to operate correctly.
