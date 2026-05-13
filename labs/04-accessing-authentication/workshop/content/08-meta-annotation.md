Thinking again at scale for a moment, it'll be cumbersome to have to type `@CurrentSecurityContext(expression="authentication.name")` in every method that needs the current user!

Let's use what you just learned about meta-annotations to simplify things! We've already performed some of these steps for you.

Open up `CurrentOwner.java` to see what's written so far. Look for the line that says `// add annotation here`

```editor:select-matching-text
file: ~/exercises/src/main/java/example/cashcard/CurrentOwner.java
text: "\/\/ add annotation here"
description:
```

1. Create the meta-annotation.

   Next, from the `CashCardController#findAll` remove the `@CurrentSecurityContext(expression="authentication.name")` annotation and replace/paste it for the `// add annotation here` in the `CurrentOwner.java` like so:

   ```editor:select-matching-text
   file: ~/exercises/src/main/java/example/cashcard/CashCardController.java
   text: "findAll"
   description:
   ```

   ```java
   package example.cashcard;

   import java.lang.annotation.ElementType;
   import java.lang.annotation.Retention;
   import java.lang.annotation.RetentionPolicy;
   import java.lang.annotation.Target;

   import org.springframework.security.core.annotation.CurrentSecurityContext;

   @Target({ ElementType.PARAMETER, ElementType.ANNOTATION_TYPE })
   @Retention(RetentionPolicy.RUNTIME)
   @CurrentSecurityContext(expression="authentication.name")
   public @interface CurrentOwner {

   }
   ```

   In this step, you're creating an alias for that in the form of a meta-annotation.

   Next, where the `@CurrentSecurityContext` expression in the `CashCardController#findAll` method was, you can add the `@CurrentOwner` annotation, like so:

   ```java
   @GetMapping
   public ResponseEntity<Iterable<CashCard>> findAll(@CurrentOwner String owner) {
       var result = this.cashCards.findByOwner(owner);
       return ResponseEntity.ok(result);
   }
   ```

   Now our method is more readable, understandable, has the necessary finder method, and it's easy to maintain!

1. Test and verify.

   I'm sure you get it by now: run the tests and they still pass!

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ ./gradlew test
   ...
   BUILD SUCCESSFUL in 5s
   ```
But, we aren't quite done yet.
