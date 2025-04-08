As mentioned in the lesson, there are tradeoffs with the approach we've implemented for filtering cash cards by their owner:

> ... you might prefer the clarity that `findByOwner(String owner)` gives to the reader; it's obvious that the owner is included in the query. By comparison, you can't tell just by `findAll`'s name that the owner is included.

If you prefer being explicit with your query parameters, Spring Data can do that, too. For example, you can simply make calling the default `findAll` on our repository illegal, and require users of this repository to explicitly supply the `owner`, like so:

```editor:select-matching-text
file: ~/exercises/src/main/java/example/cashcard/CashCardRepository.java
text: "findAll"
description:
```

```java
public interface CashCardRepository extends CrudRepository<CashCard, Long> {
   Iterable<CashCard> findByOwner(String owner);

   default Iterable<CashCard> findAll() {
      throw new UnsupportedOperationException("unsupported, please use findByOwner instead");
   }
}
```

This helps make sure that developers in the future don't accidentally use the less-secure `findAll` repository method and fetch everyone's cash cards.

Now, it's possible that they _need_ to do this and will treat the data returned securely, but at least the error-throwing version here would make them strongly consider other options.
