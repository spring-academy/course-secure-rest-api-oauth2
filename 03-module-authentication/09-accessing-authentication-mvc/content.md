In this lesson, you'll learn three ways to access the authenticated principal in Spring MVC controller methods.

First, though, let's consider some of the use cases when you may need to look up the user:

- You need to know profile or other details about the principal
- You need a primary key or other identifiers about the principal to formulate a query
- You need to declare whether a principal has permission to perform a given action
- You need to propagate credentials to downstream services

In all of these cases, you are going to want to get the currently authenticated principal, and Spring MVC's support is a great way to do just that.

## Method Injection

First, you can get the current `Authentication` instance in any Spring MVC handler method by including it as a method parameter, like so:

```java
@GetMapping
public ResponseEntity<Iterable<CashCard>> findAll(Authentication authentication) { ... }
```

When Spring MVC invokes this handler method, it will look up the `Authentication` instance and supply it automatically.

**_Note:_** In Spring MVC, a _handler_ method is one that "handles" an HTTP request. Some examples are those annotated with `@RequestMapping`, `@GetMapping`, and so on.

When this happens, you can access the principal, the credentials, and the authorities in the method body as needed. This includes being able to pass the user information down to service and repository layers in your application.

Note that for the greatest flexibility `Authentication#getPrincipal` returns `Object`. This is helpful when integrating Spring Security with custom user representations.

However, using `Authentication#getPrincipal` directly can cause unwanted casting. To assist with that, Spring Security provides `@CurrentSecurityContext`, which we'll talk about next.

## Principal Type Conversion

The `@CurrentSecurityContext` annotation allows you to remove some of the boilerplate around getting specific values like the principal from the current authentication.

As you already learned, you can call `Authentication#getPrincipal` yourself. Or, you can use `@CurrentSecurityContext` to have Spring Security handle the type conversion for you.

For example, with Bearer JWT Authentication, `Authentication#getPrincipal` holds a `Jwt` instance. Given that, you can get the underlying `Jwt` instance by changing the earlier snippet to:

```java
@GetMapping
public ResponseEntity<Iterable<CashCard>> findAll(@CurrentSecurityContext(expression = "authentication.principal") Jwt jwt) { ... }
```

This is handy if you are needing to get JWT-specific information, like calling `Jwt#getIssuer` or `Jwt#getAudience`.

**_Note:_** The `@CurrentSecurityContext` annotation is _only_ processed by Controller methods. Keep this in mind since from a language perspective, Java will allow it on any method.

You can obtain any attribute from the `Authentication` instance that you need. For example, the above snippet can be simplified to call `Authentication#getName` like so:

```java
@GetMapping
public ResponseEntity<Iterable<CashCard>> findAll(@CurrentSecurityContext(expression = "authentication.name") String owner) { ... }
```

While this is a nice improvement, there is still boilerplate like the [SpEL expression](https://docs.spring.io/spring-framework/docs/3.0.x/reference/expressions.html). It's a good security practice to remove duplication; you don't have to secure code that you don't write!

Moreover, SpEL expressions aren't compiled along with your code and so it's a good idea to keep SpEL expressions to a minimum since errors in such expressions might not be revealed until they are encountered at runtime.

To help you with this, `@CurrentSecurityContext` also supports meta-annotations.

## Meta-Annotations

You can consolidate the repetitive nature of getting authentication information by creating a custom annotation and configuring it as a meta-annotation.

A _[meta-annotation](https://github.com/spring-projects/spring-framework/wiki/Spring-Annotation-Programming-Model#meta-annotations)_ is an annotation that aliases another annotation.

For example, recall that in your fictional Cash Card application, the user is referred to as the owner of each card. You can create a custom annotation called `@CurrentOwner` that extracts the owner's name like so:

```java
@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
@CurrentSecurityContext(expression="authentication.name")
public @interface CurrentOwner {
}
```

This annotation is now an alias for `@CurrentSecurityContext(expression="authentication.name")`. Now it can simplify the signature, like this:

```java
@GetMapping
public ResponseEntity<Iterable<CashCard>> findAll(@CurrentOwner String owner) { ... }
```

Now that reads wonderfully and conveys exactly its purpose!

### @AuthenticationPrincipal

Actually, Spring Security ships with its own meta-like annotation for `@CurrentSecurityContext` called `@AuthenticationPrincipal`.

It is the equivalent of `@CurrentSecurityContext(expression="authentication.principal")` and supports SpEL expressions as well. It can come in handy if all you need is the principal and don't want to create your own meta-annotation; this is especially nice if your principal is a custom class.

We won't use it in this course, but stay tuned!
