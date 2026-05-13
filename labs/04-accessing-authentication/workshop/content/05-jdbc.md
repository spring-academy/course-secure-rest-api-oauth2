While our implementation `CashCardController#findAll` works, the fact is that the database can perform this filtering operation far more efficiently and securely than we can with our hand-written looping and filtering code.

Also, imagine we had millions, or billions, or trillions of cash cards in the database. We'd pull all of those into memory and loop through each one. Yikes!

Luckily, we're already using Spring Data JDBC. Spring Data JDBC allows you to expand the base implementation of the `CrudRepository` by using query methods. In conjunction with our `Authentication` object, we can make the database do our work for us.

1. Update the Repository.

   Open the `CashCardRepository` interface and add a `findByOwner` method that returns an `Iterable<CashCard>`, like so:

   ```editor:open-file
   file: ~/exercises/src/main/java/example/cashcard/CashCardRepository.java
   ```

   ```java
   public interface CashCardRepository extends CrudRepository<CashCard, Long> {
     Iterable<CashCard> findByOwner(String owner);
   }
   ```

   **_Note:_** You're just scratching the surface here on Spring Data JDBC's capabilities! Make sure to take a look at its numerous others ways [to query a SQL databases](https://docs.spring.io/spring-data/relational/reference/repositories/query-methods-details.html).

1. Update the Controller.

   Now, in the `CashCardController` class, modify the `findAll` method with the following code, which uses our new `CashCardRepository` query method to do the owner filtering for us:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardController.java
   text: "findAll"
   description:
   ```

   ```java
   @GetMapping
   public ResponseEntity<Iterable<CashCard>> findAll(Authentication authentication) {
       var result = this.cashCards.findByOwner(authentication.getName());
       return ResponseEntity.ok(result);
   }
   ```

   Nice! Our code is simpler, more efficient, and now it's secure, due the fact that you're filtering our data to only the principal supplied by the `Authentication`.

1. Run the tests and query the API.

   If you run the test with no modifications, it should still pass!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 5s
   ```

   Feel free to **restart the application** and fetch all of `sarah1`'s cash cards from the API, too.

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

   This is called **refactoring**: _changing the implementation of the code **without** changing the functionality._

There are other refactorings we can do to change the implementation, but have the same results. Next, let's try another one.
