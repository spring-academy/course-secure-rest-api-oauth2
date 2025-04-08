In this lesson, you'll learn the difference between request- and method-level authorization and how each shows up in Spring Security. You'll also learn how to decide which type of authorization to use.

As a quick reminder, Spring Security helps with three things:

- **Defense:** determining if the request is safe to process
- **Authentication:** determining who is making the request
- **Authorization:** determining if they have the needed permissions

This module focuses on the last item: **Authorization**.

## Request-Level Authorization

There are two main ways to model your authorization in Spring Security. The first is at the request level and the second is at the method level.

To model authorization at the request level means to make a statement that sounds like the following:

> If the **request** follows **pattern** X then require **authority** Y to honor the request.

A concrete example of that might be:

> If the **request URI is `/cashcards`** then require the **cashcard:read scope** to honor the request.

Let's take a minute to define each of these terms:

- _request:_ Any part of the HTTP request; practically speaking, anything that can be read from an `HttpServletRequest` instance
- _pattern:_ The **matching rule** that decides whether the given request material matches
- _authority:_ The **authorization rule** that applies for the request material that matches the pattern

While Spring Security allows you to map any part of the request to any authorization rule, the most common is to map a URI to a specific permission.

You've actually already seen this in play by this point. Do you remember the default filter chain definition? It has a declaration in it called `authorizeHttpRequests`:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authz) -> authz.anyRequest().authenticated())
        // ...
}
```

This authorization rule can be read like this:

> If the request follows the pattern [any request] then require [authenticated] to honor the request.

Or, in plain English:

> For any request, require the user to be authenticated.

We could add a hypothetical `/cashcards` rule in the following way:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authz) -> authz
            .requestMatchers("/cashcards").hasAuthority("cashcard:read")
            .anyRequest().authenticated()
        )
        // ...
}
```

Then Spring Security would require the `cashcard:read` authority for the `/cashcards` URI, and just any authentication for every other request.

**_Note:_** Generally speaking, `authenticated()` is the simplest state for any authenticated user that the other authorization rules build off of. For example, `hasAuthority()` implies `authenticated()`.

## Method-Level Authorization

The other approach to modeling authorization in Spring Security is at the method level.

To use method-security, activate it by adding the `@EnableMethodSecurity` annotation to any Spring `@Configuration` class. As you saw in the last lab of the previous module, it's common to have a configuration class dedicated to security configurations, and this annotation would normally go there.

Once activated, you can attach rules to individual methods, often Spring MVC controller methods.

For example, you could configure `CashCardController#findAll` to require the `cashcard:read` permission by adding the `@PreAuthorize` annotation like so:

```java
@GetMapping("/cashcards")
@PreAuthorize("hasAuthority(‘cashcard:read')")
public ResponseEntity<Iterable<CashCard>> findAll(@CurrentOwner String owner) {
    // ...
}
```

Similar to calling `requestMatchers("/cashcards").hasAuthority("cashcard:read")`, this effectively tells Spring Security:

> If the _findAll_ _method_ is invoked, require _the cashcard:read scope_ to permit the invocation.

## What's the Difference?

The two snippets you've seen so far are functionality equivalent. So why have both?

### Being HTTP-agnostic

First, remember that this is a little bit of a coincidence. Since Spring MVC maps requests to method invocations, an MVC method call is a lot like an HTTP request. Such is not always the case.

For example, method security applies to any public method of any Spring-managed bean. So, if you annotate your application's service layer instead, it can remain HTTP-agnostic. This can be especially useful if a bean is accessed via a protocol that is not HTTP.

When might this scenario occur? Imagine that you need to expose the Cash Card `findAll` functionality to a system that uses a message queue via Spring AMQP instead of the HTTP REST API. You can certainly extract the `findAll` business logic out of the controller and into a service-layer class, but the authorization rules would be "trapped" in the HTTP layer if you continue to use request-level authorization. Switching to method-level authorization in the service layer would let the authorization rules apply to HTTP, AMQP, or any other usage of that service layer class.

### What Request Security Can Do That Method Security Can't

Next, our `/cashcards` example is a bit over-simplified since it refers to just one request URI. But, consider a more complex example like the following:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        // ...
        .authorizeHttpRequests((authz) -> authz
            .requestMatchers("/css/**", "/js/**").permitAll() // <1>
            .requestMatchers("/admin/**").hasRole("ADMIN") // <2>
            .anyRequest().authenticated() // <3>
        // ...
}
```

This configuration does three important things that method security cannot do:

1. It protects endpoints that don't resolve to a method invocation, like your static content: CSS files, JavaScript files, etc.
2. It protects entire sections of the website in a single declaration, like requiring that only ADMINs can use `/admin` endpoints .
3. It provides a catch-all for when new endpoints are introduced to the application.

### What Method Security Can Do That Request Security Can't

Also, method security can secure the method invocation as well as the method return. Request security can only secure the request, not the response.

For example, you can use the `@PostAuthorize` annotation to ensure that the requested cash card actually belongs to the end user before returning it like so:

```java
@GetMapping("/cashcard/{id}")
@PostAuthorize("returnObject.body.owner == authentication.name")
public ResponseEntity<CashCard> findById(@RequestParam("id") String id) {
    // ...
}
```

It also can secure services and repositories, which are necessarily decoupled from the HTTP request.

## And really, you need both

Finally, if you know how to use them in a complementary way, they work together quite nicely.

To understand this last point, let's learn some more security terminology:

- _coarse-grained authorization_: Authorization rules that make a decision on only a single factor (like any request that starts with `/admin`)
- _fine-grained authorization:_ Authorization rules that make a decision based on multiple factors (like method parameters, return values, and the method signature)

By design, method security is great for _fine-grained authorization_ and request security is great for _coarse-grained_. A non-trivial application will likely need both, kind of like how everyone needs to be screened at the airport (coarse-grained), and sometimes special checks are needed for specific passengers (fine-grained).

We'll see this point more clearly in the upcoming lab where we add method-level security.

Up next, let's take a look at what authorization looks like in OAuth 2.0 and how that shows up in these two authorization models in Spring Security.
