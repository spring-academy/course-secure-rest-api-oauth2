In this lesson, you'll learn about how to add request-level authorization rules to an application. By the end, you'll understand for which circumstances request-level authorization is the best model.

## Using `authorizeHttpRequests`

Request-level authorization is active by default in a Spring Security-enabled application. The default rule is _"all requests require authentication"_.

As you've already seen a few times at this point, that looks like this:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authorize) -> authorize
            .anyRequest().authenticated()
        )
        // ...
}
```

Inside the `authorizeHttpRequests` DSL are several other methods for standard request matchers. The main ones are:

- `requestMatchers(String...)`: This method configures authorization to apply a given rule based on the given ant-based URI patterns
- `anyRequest()`: This method configures authorization to apply to any request

Rules are processed from top to bottom, the same way as if-else-if statements work. That means that _the first rule that matches is the one that applies_.

## Avoiding Common Missteps

Given the first-match-wins paradigm, here is a bad example of `authorizeHttpRequests` usage. Can you tell what's wrong?

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authorize) -> authorize
            .anyRequest().authenticated()
            .requestMatchers("/cashcards").hasAuthority("SCOPE_cashcard:read")
        )
        // ...
}
```

If you aren't quite sure, here's a hint. If these were `if` statements, they'd look like this:

```java
// if-else-if statement example
if (true) { // any request means that every request matches, right?
    System.out.println("any request");
} else if (the request matches "/cashcards") {
    System.out.println("cash cards");
}
```

In this case, what would print out when the request is `/cashcards`? Or `/error`? Or `/23jk4nw3kljwne`?

That's right! Because `anyRequest` is listed first, that's what is always going to be picked.

Luckily, if you use `anyRequest` too early, Spring Security will catch this for you. Note, though, that there are other ways to accidentally make this mistake, like listing `/cashcards/**` first, and then `/cashcards/{id}` after that.

Consider the following code:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authorize) -> authorize
            .requestMatchers("/cashcards/**").authenticated()
            .requestMatchers("/cashcards/{id}").hasAuthority("SCOPE_cashcard:read")
        )
        // ...
}
```

What might be the intent of the above code? It could be to say:

> If the path is `/cashcards/{id}`, it requires read authority, but otherwise, it just requires authentication.

However, this would be wrong!

This is because the rules are _always processed from top to bottom_, again, just like if-else-if statements.

Since `/cashcards/{id}` is more specific than `/cashcards/**`, it should be listed first like so:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authorize) -> authorize
            .requestMatchers("/cashcards/{id}").hasAuthority("SCOPE_cashcard:read")
            .requestMatchers("/cashcards/**").authenticated()
        )
        // ...
}
```

Note that the difference between the two code examples is subtle, but important!

## Using Coarse-Grained Authorization

Okay, now you're more aware of the pitfalls. Let's talk about how to use coarse-grained request-matching rules effectively.

There are three main areas where these rules are helpful:

1. Static Resources
2. RESTful Resources
3. Catch-all rules

Let's talk about each of these in detail.

### Static Resources

The first common use of coarse-grained authorization is static resources, like CSS, Javascript, and image files.

Wait... I need to secure my _static resources, too?!_

Yes! First, remember that Javascript and CSS are code, and the _principle of least privilege_ says that unauthorized folks shouldn't have access to something they don't need. What parts of your Java code are you fine with unauthorized users seeing? Probably very little or none of it!

Second, the browser is a dangerous place! Spring Security helps by ensuring that every request responds with the secure headers you learned about earlier in this course.

In many cases, your static resources are all public, which would look like this:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authorize) -> authorize
            .requestMatchers("/error", "/css/**", "/js/**", "/images/**").permitAll()
            // ...
        )
        // ...
}
```

`permitAll()` means to allow the requests without requiring any authentication. In other words, all the non-authorization filters still apply.

**_Tip:_** The `/error` endpoint is a Spring Boot endpoint for reporting errors. It's quite common to want that to be permitted, at least during development, so that you can always see any errors that Boot reports.

### RESTful Resources

If you can articulate your authorization rules in terms of how you have organized your REST resources, then request-level authorization is a great place to be.

For example, you can break up the Cash Card application into read and write operations using HTTP methods like so:

| Pattern               | Permission Needed |
| --------------------- | ----------------- |
| `GET /cashcards/{id}` | read              |
| `GET /cashcards/`     | read              |
| `POST /cashcards`     | write             |

Since in our application only `GET`s require read, you can use Spring Security's if-else-if pattern matching to your advantage like so:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authorize) -> authorize
            .requestMatchers(GET, "/cashcards/**").hasAuthority("SCOPE_cashcard:read")
            .requestMatchers("/cashcards/**").hasAuthority("SCOPE_cashcard:write")
            // ...
        )
        // ...
}
```

The effect of these rules is to say the following:

> If the request is for a cashcard resource, then if it's a `GET`, require the `cashcard:read` scope; otherwise require the `cashcard:write` scope.

This coarse-grained checking is nice because you don't have to remember to add a new rule when you introduce a new operation on the cash card resource. Not having to remember is a nice security posture!

### Catch-all Rules

We've already seen a little bit of the power of Spring-Security's catch-all rules, but let's finish this out with the most basic and always needed one, `anyRequest()`.

When you list `anyRequest()` at the end, it's your `else` statement. When you add this, it means that, no matter what you may have forgotten or what requirements you might not know about, everything will at least get this level of security.

_Always_ have at least an `anyRequest()` at the end of your definition!

You can do it how we've been doing it to this point like this:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authorize) -> authorize
            // ...
            .anyRequest().authenticated()
        )
        // ...
}
```

Or you can be more aggressive and do it like this:

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests((authorize) -> authorize
            // ...
            .anyRequest().denyAll()
        )
        // ...
}
```

The effect of the latter is a more aggressive version of the _principle of least privilege_. It means that you anticipate that anything you haven't explicitly allowed is denied to everyone.

Next, let's hop into a lab where you can see these rules in action!
