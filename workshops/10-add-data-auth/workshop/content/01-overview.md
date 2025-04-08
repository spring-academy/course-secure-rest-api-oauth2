This lab will teach you how to implement authorization rules at the database level. You'll achieve this by incorporating Spring Security authentication components into your Spring Data queries.

## A Quick Review

In a previous lab we changed the `CashCardRepository#findAll` method to return only those cards belonging to the authenticated user.

Go ahead, give that implementation a look:

```editor:select-matching-text
file: ~/exercises/src/main/java/example/cashcard/CashCardRepository.java
text: "findAll"
description:
```

```java
public interface CashCardRepository extends CrudRepository<CashCard, Long> {
   ...
   default Iterable<CashCard> findAll() {
	  SecurityContext context = SecurityContextHolder.getContext();
	  Authentication authentication = context.getAuthentication();
	  String owner = authentication.getName();
	  return findByOwner(owner);
   }
}
```

When examining this code, you'll likely concur that it contains excessive boilerplate – it takes 3 lines of code just to get the authenticated user's name!

There should be a more straightforward way to achieve the same result, don't you think?
