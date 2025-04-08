Throughout the lessons in this module we've made it clear that authorization often happens at several layers of an application. You've already learned about authorizing the request and its corresponding controller layer. Then, you read about authorizing the service layer.

In this lesson, you'll learn about how to enforce authorization rules at the _database layer_. We'll do this by adding Spring Security authentication material into Spring Data queries.

## Enabling Spring Data Authorization

Like method authorization, data authorization is not enabled by default. Additionally, it's not on the classpath by default, so we'll need to do a bit more work to use it.

To activate data authorization, you need to add the `spring-security-data` dependency to your application's `build.gradle` file:

```groovy
dependencies {
  implementation 'org.springframework.boot:spring-boot-starter-web'
  testImplementation 'org.springframework.boot:spring-boot-starter-test'
  // add the spring-security-data dependency:
  implementation 'org.springframework.security:spring-security-data'
}
```

Having done that, you can now refer to the `Authentication` instance in your queries, like so:

```java
@Query("SELECT * FROM cash_card cc WHERE cc.owner = :#{authentication.name}")
```

As you can see, it supports the same SpEL syntax that we already saw in method security, which means that this is effectively the same as doing the following in a `PreparedStatement`:

```java
String query = "SELECT * FROM cash_card cc WHERE cc.owner = ?";
String owner = SecurityContextHolder.getContext().getAuthentication().getName();
PreparedStatement ps = connection.prepareStatement(query);
ps.setValue(1, owner);
```

## Preventing User Data from Leaking

Data authorization support is nice in that it can help you from accidentally leaking sensitive information across users.

Consider, for example, the `GET /cashcards` endpoint in our Cash Card API:

```java
@GetMapping
public ResponseEntity<Iterable<CashCard>> findAll() {
    Iterable<CashCard> cards = this.cashcards.findAll();
    // ...
}
```

It's quite reasonable to have the `findAll` controller handler method call the `findAll` repository method, but do you really want to return _all cash cards in the entire database?_

Of course not! What a cash card owner actually wants is to retrieve only the cards that belong to them. So far, we've achieved this by first invoking the `findByOwner` method on the repository:

```java
@GetMapping
public ResponseEntity<Iterable<CashCard>> findAll(@CurrentOwner String owner) {
    Iterable<CashCard> cards = this.cashcards.findByOwner(owner);
    // ...
}
```

Now, we can do one better and move the user logic to the repository by changing `findAll`'s query to include the user from the Authentication instance like so:

```java
@Query("SELECT * FROM cash_card cc WHERE cc.owner = :#{authentication.name}")
Iterable<CashCard> findAll();
```

There are two nice things about this: First, it removes boilerplate code, and second it ensures that services cannot accidentally call `findAll` and leak user data. We've centralized the card-owner logic from potentially many services to this one repository call. Hence, we've reduced the security "surface area".

### Clarity in Method Signatures

Like the other authorization techniques we've discussed in earlier lessons, data authorization has alternatives and their associated tradeoffs.

In this case, you might prefer the clarity that `findByOwner(String owner)` gives to the reader; it's obvious that the owner is included in the query. By comparison, you can't tell just by `findAll`'s name that the owner is included.

To address this, you can instead prevent leaking user data by always declaring the appropriate `findBy` method and then overriding the `findAll` method like so:

```java
Iterable<CashCard> findByOwner(String owner);
default Iterable<CashCard> findAll() {
    throw new UnsupportedOperationException("unsupported,
    please use findByOwner instead");
}
```

Now that you've learned all about data authorization, let's head over to the lab to practice!
