In this lesson, you'll learn how to activate method authorization in Spring Security and put it into action. We'll specifically pay close attention to where method authorization can do things that _request_ authorization _cannot_.

## Enabling Method Security

First, note that Spring Security does not enable method security by default. This is because Spring Security supports more than one set of method annotations and it needs to know which you'd like to use.

In this lesson, we'll focus on the so-called "pre-post" annotations since that's the Spring Security default.

To enable these annotations, annotate any `@Configuration` class with `@EnableMethodSecurity` like so:

```java
@EnableMethodSecurity
@Configuration
public class SecurityConfig { ... }
```

Once you've done this, you can use method authorization throughout your Spring application.

Let's dive into how to do that.

## Secure a Method

Adding `@EnableMethodSecurity` configures Spring Security to intercept and secure any public Spring-managed class or method annotated with its pre-post annotations. The ones we'll need for this course are:

- `@PreAuthorize("rule")`: Block this method invocation unless the given rule passes
- `@PostAuthorize("rule")`: Block this method return unless the given rule passes

**_Note:_** There are also `@PreFilter` and `@PostFilter`, though their use is uncommon and out-of-scope for this course. Also, there are two other annotation models that Spring Security supports historically. You're welcome to read the references to learn more.

Earlier in the course, you learned that the two main use cases for method security are:

1. Securing the non-HTTP layers of your application and
2. Performing fine-grained authorization.

Let's take a closer look at those now.

## Securing a Service

Method security is useful for securing non-HTTP layers of your application.

Consider a Spring-managed `@Service` component that only customer service representatives can use. With a configuration like this:

```java
@Service
public class CustomerService {
    @PreAuthorize("hasRole(‘CUSTOMER_SERVICE')")
    public Customer cancelAccount(UUID id);
}
```

Now, only those with the `CUSTOMER_SERVICE` role would be allowed to cancel accounts.

Strategically, it's quite nice to publish authorization rules at the service layer in the event that some of our applications don't use HTTP.

## Protecting Against Insecure Direct Object Reference

Method security is also useful for fine-grained authorization, and [Insecure Direct Object Reference](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/05-Authorization_Testing/04-Testing_for_Insecure_Direct_Object_References) mitigation is a primary example of that.

Consider that in our Cash Card application, anyone with the `cashcard:read` permission can request `/cashcards/99` _even if that card doesn't belong to them_! Clearly, we want to protect the user's data; only the user who owns a card should be able to see its contents.

How would you prevent this with what you know already?

You might, for example, check that the cashcard belongs to the logged-in user before returning it like so:

```java
@GetMapping("/{id}")
public ResponseEntity<CashCard> findById(@PathParam("id") String id, @CurrentOwner String owner) {
    CashCard card = ...
    if (!card.getOwner().equals(authentication.getName())) {
        throws new AccessDeniedException("denied");
    }
    // ...
}
```

And this would be fine.

But! The good news is that Spring Security comes with support for these kinds of fine-grained authorization checks. Instead of embedding your authorization logic in your method, use `@PostAuthorize` like so:

```java
@GetMapping("/{id}")
@PostAuthorize("returnObject.body.owner == authentication.name")
public ResponseEntity<CashCard> findById(@PathParam("id") String id) {
    CashCard card = ...
    // ...
}
```

Spring Security will perform the same check we described earlier and throw any needed exception for you. In this way, the cash card cannot be returned unless it actually belongs to the user who is logged in.

While we're here, let's be clear on the syntax. `returnObject` is a special variable the Spring Security understands to mean the return value of the method. Since a `ResponseEntity` is returned from this method, `returnObject` represents the `ResponseEntity` instance.

The rest is standard SpEL and can be conceptually expanded in the following way:

```java
// Expanded example:
ResponseEntity<CashCard> returnObject = findById(id);
Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
if (returnObject.getBody().getOwner().equals(authentication.getName())) {
    return returnObject;
} else {
    throw new AccessDeniedException("access is denied");
}
```

### Couldn't We Have Queried the Database?

You'll have a chance to practice this second use case in the upcoming lab, but before we get there, you might be wondering about the efficiency of that approach. Why aren't we doing this instead so that unauthorized access never makes it into memory?

```java
@GetMapping("/{id}")
public ResponseEntity<CashCard> findById(@PathParam("id") String id, @CurrentOwner String owner) {
    CashCard card = this.cashcards.findByIdAndOwner(id, owner);
    // ...
}
```

As is the case with many coding decisions, there are tradeoffs.

The performance benefit of this approach is that if the access is unauthorized, your application won't construct a `CashCard` object since the query will return no results.

The drawback is that your application can no longer differentiate between a 403 and a 404. In both cases – unauthorized access and invalid `CashCard` id – there are no results.
