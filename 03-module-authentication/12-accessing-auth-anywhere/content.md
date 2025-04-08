In this lesson, you'll learn how to access the current authentication without Spring MVC, using `SecurityContextHolder`. These principles can be used to access the current authentication anywhere in your Spring application, even outside of Spring-managed beans.

## The `SecurityContextHolder`

You've already learned how to access the `Authentication` instance using Spring MVC and pass it to other layers of your application.

But, what if you can't rely on that? A common example of this is when you're creating a servlet filter, which executes before Spring MVC. Another is when processing things outside the request context, like asynchronous events.

While those examples are out of scope for this course, it's valuable for you to understand how you can gain access to the `Authentication` instance from anywhere in your Spring application so that you can apply these techniques when needed on your own projects.

## Using the Static Class

In the last lab, you used Spring MVC to supply the `Authentication` instance for you in a Controller request handler method.

But, you could have done it this way instead:

```java
SecurityContext context = SecurityContextHolder.getContext();
Authentication authentication = context.getAuthentication();
```

This snippet uses `SecurityContextHolder`, a static class that provides access to the current security context, including the authentication details. You can access it anywhere in your application!

## A Comparison to Spring MVC Method Arguments

To help you see how this is different from what you did in the last lab, consider how the `CashCardController#findAll` method changes if we don't use the `Authentication` supplied by Spring MVC.

As a reminder, this is how we implemented `findAll` in the lab:

```java
@GetMapping
public ResponseEntity<Iterable<CashCard>> findAll(Authentication authentication) {
    var result = this.cashCards.findByOwner(authentication.getName());
    return ResponseEntity.ok(result);
}
```

To use `SecurityContextHolder` instead, it would look like this:

```java
@GetMapping
public ResponseEntity<Iterable<CashCard>> findAll() {
    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    return ResponseEntity.ok(this.cashCards.findByOwner(authentication.getName()));
}
```

As you can see, the main difference is that we use the static `SecurityContextHolder` to obtain the `Authentication` instance manually, instead of letting the container provide it.

If you want to get the `JWT` you can do the following:

```java
@GetMapping
public ResponseEntity<Iterable<CashCard>> findAll() {
    Jwt owner = (Jwt) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    return ResponseEntity.ok(this.cashCards.findByOwner(owner.getSubject()));
}
```

Again, by using `SecurityContextHolder`'s static methods we can access the same authentication information that might be provided by Spring MVC.

## Where Should We Use It?

But wait, why would we use the static-class technique inside Spring MVC?

The truth is we likely would not, given the other options we have demonstrated. We used it in the controller because it was easy to compare and contrast with the existing code.

But, not every class we write will be a Spring-managed class like a Spring MVC controller. If you find yourself within a plain-old-java-object, or POJO, and need the `SecurityContext`, `SecurityContextHolder.getContext()` is a valid option.

The `SecurityContextHolder` uses a `ThreadLocal` to store the security context, which means it is specific to the current thread. Therefore, you can access the authentication information within the same thread throughout your application.

### A POJO Example

Consider this theoretical Cash Card discount-calculator class that uses the currently authenticated user to help determine if they qualify for a special discount:

```java
...
import org.springframework.security.core.context.SecurityContextHolder;
...

public class CashCardDiscountCalculator {
    public boolean currentUserQualifiesForDiscount() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return qualifiesForDiscount(authentication.getName());
    }

    private boolean qualifiesForDiscount(String name) { ... }
}
```

The fictional `CashCardDiscountCalculator` is _not_ annotated with `@Controller` or any other Spring annotations. It's just a POJO. Yet, it is capable of accessing the `SecurityContextHolder` and all of the context within it as needed. Handy!
