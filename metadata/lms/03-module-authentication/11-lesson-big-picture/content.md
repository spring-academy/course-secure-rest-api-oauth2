In this lesson, we'll pull back the curtains a bit to give you a larger view of what's going on in Spring Security. You'll learn about what we've been referring to as the Spring Security filter chain, as well as a number of the authentication components that are common to working with Spring Security.

## The Filter Chain

The Spring Security filter chain is a set of security filters that are run in sequence on each request.

![Spring Security Filter Chain flow chart](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-secure-rest-api-oauth2/security-filter-chain.svg "Spring Security Filter Chain flow chart")

Each filter can short-circuit the request and prevent the other filters and servlets from running. This carries some nice security benefits:

- Each filter can focus on its area of security expertise
- No filter needs to worry about downstream filters running if it rejects the request

Generally speaking, filter chain filters can be separated into four categories:

- Defense Filters
- Authentication Filters
- Authorization Filters
- Infrastructural Filters

Let's look at each of these filters in more detail.

## Defense Filters

Before authentication is attempted, Spring Security defends the application against malicious requests. These filters include:

- _CsrfFilter_ - the filter that checks incoming CSRF tokens and issues new ones
- _HeaderFilter_ - the filter that writes secure headers to the HTTP response

Other than certain infrastructural filters, defense filters are the first filters in the filter chain.

## Authentication Filters

Once the request is determined to be safe, the filter chain moves on to authenticating the request.

Each authentication filter handles a single authentication scheme. You'll already recognize a few:

- _BasicAuthenticationFilter_ - Handles HTTP Basic Authentication
- _BearerTokenAuthenticationFilter_ - Handles Bearer Token Authentication (including JWTs)
- _UsernamePasswordAuthenticationFilter_ - Handles Form Login Authentication
- _AnonymousAuthenticationFilter_ - Populates the context with a Null Object authentication instance

While not uniform, each authentication filter uses roughly the following _pseudocode_; also, note the little `<1>`,`<2>`, and `<3>` indicators:

```java
// Note: this is pseudocode!
if (!requestMatcher.matches(request)) {
  // skip this filter
} else {
  Authentication token = getAuthenticationRequest(request) <1>
  try {
    Authentication result = authenticationManager.authenticate(token) <2> <3>
    saveToSecurityContextHolder(result);
    fireSuccessEvent(result);
    handleSuccess(result);
  } catch (AuthenticationException ex) {
    handleFailure(token);
  }
}
```

While a bit more detailed than what you've seen so far, you can see the same three elements from before:

1. `<1>` _parses the request material into a credential_
2. `<2>` _tests that credential and returns a principal and authorities_
3. `<3>` _constructs the principal and authorities_

**_Note:_** We'll have a chance to get into some of the other elements (like events and success and failure handling) a little later on.

Also as you can see, if it detects a credential, it will try to authenticate it, rejecting the request if it fails.

You'll notice a number of authentication components that we've only alluded to at this point, so let's take a look at those now.

### Authentication

`Authentication` is a Spring Security interface that represents both an authentication _token_ (material to be authenticated, like a JWT) and an authentication _result_ (authenticated material).

Each authentication instance contains different values, depending on whether it's a token or a result:

| Authentication Token    | Authentication Result       |
| ----------------------- | --------------------------- |
| principal ("who")       | principal ("who")           |
| credentials ("proof")   | credentials ("proof")       |
| authenticated = _false_ | authenticated = _true_      |
|                         | authorities ("permissions") |

**_Note:_** In some cases, like username/password authentication, the authentication result does not contain the user's password for security reasons.

As you can see by the pseudo-code above:

- If authentication _fails_, the `authenticationManager` throws an exception.
- If the `authenticationManager` returns an `Authentication`, then the authentication _succeeded_.

### AuthenticationManager

`AuthenticationManager` is an interface that tests an authentication token. If the test succeeds, then the `AuthenticationManager` constructs an authentication result.

The `AuthenticationManager` is composed of several `AuthenticationProvider`s, each of which handle a single authentication scheme, like authenticating a JWT.

### SecurityContext

The `SecurityContext` is an object that holds the current `Authentication` like so:

![Spring Security Context Holder](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-secure-rest-api-oauth2/security-context-holder.svg "Spring Security Context Holder")

The reason for `SecurityContext` is so that applications can hold additional security information other than the current user, if they want to; however, this is a feature that is very rarely exercised in Spring Security.

All you need to know for now is that the `SecurityContext` is an infrastructural piece that holds the `Authentication` instance for your later retrieval.

### Reviewing Bearer JWT Authentication

So now let's look again at Bearer JWT Authentication, but this time in terms of the Spring Security authentication API.

1. First, the `BearerTokenAuthenticationFilter` extracts the JWT into a `JwtAuthenticationToken` instance.
2. Then, it passes that authentication token to an `AuthenticationManager`. This `AuthenticationManager` holds a `JwtAuthenticationProvider` instance.
3. Next, `JwtAuthenticationProvider` authenticates the JWT and returns an authenticated instance of `JwtAuthenticationToken` that includes the parsed JWT and granted authorities.
   - Or, if authentication fails, `JwtAuthenticationProvider` throws an `AuthenticationException`.
4. Finally, the filter stores the authentication result in a `SecurityContext` instance for later use.

## Authorization Filters

Once the request is deemed both safe and authenticated, then the filter chain decides if the request is authorized. It does this in the `AuthorizationFilter`.

By default, Spring Security constructs an `AuthorizationFilter` that requires that all requests be authenticated. If the request is not authenticated then this filter rejects the request.

You'll be learning more about authorization in the next module. For now, the most important factor to take away is that authentication filters precede authorization filters, and that each is an intentionally different consideration.

This means, for example, that any request that contains a bearer token in `Authorization: Bearer`, Spring Security will attempt to authenticate. This is true even when the endpoint is public, since even public endpoints may need to respond differently if there's an end user in context.

## The `SecurityFilterChain` Bean

The filter chain is represented by a single bean named `SecurityFilterChain`. It can hold an arbitrary number of security filters that it will execute on every request.

### The Default Bean

A default one is set up for you that looks (exhaustively) like this:

```java
@Bean
SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .addFilter(webAsyncManagerIntegrationFilter) // infrastructure
        .securityContext(withDefaults()) // infrastructure
        .servletApi(withDefaults()) // infrastructure
        .csrf(withDefaults()) // defense
        .headers(withDefaults()) // defense
        .logout(withDefaults()) // authentication
        .sessionManagement(withDefaults()) // authentication
        .requestCache(withDefaults()) // authentication
        .formLogin(withDefaults()) // authentication
        .httpBasic(withDefaults()) // authentication
        .anonymous(withDefaults()) // authentication
        .exceptionHandling(withDefaults()) // infrastructure
        .authorizeHttpRequests((authorize) -> authorize  // authorization
            .anyRequest().authenticated()
        );

    return http.build();
}
```

Wow, that's a lot of default security!

Most of these are set for you in a prototype bean that Spring Security manages. Some of them are specified separately by Spring Boot (more on that later). Because those defaults are set, when you ask for a reference to `HttpSecurity`, you typically only need to specify your authentication and authorization rules like so:

```java
@Bean
SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .httpBasic(withDefaults()) // authentication
        .authorizeHttpRequests((authorize) -> authorize  // authorization
            .anyRequest().authenticated()
        );

    return http.build();
}
```

In the above snippet, all of Spring Security's defense and infrastructural defaults are still in place; you only need to specify authentication (`httpBasic`) and authorization (`authorizeHttpRequests`).

### The Default OAuth 2.0 Resource Server Bean

Since our Cash Card application is an OAuth 2.0 Resource Server, it should instead declare `oauth2ResourceServer` for authentication instead of `httpBasic`, like this:

```java
@Bean
SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http
        .oauth2ResourceServer((oauth2) -> oauth2  // authentication
            .jwt(withDefaults())
        )
        .authorizeHttpRequests((authorize) -> authorize  // authorization
            .anyRequest().authenticated()
        );

    return http.build();
}
```

While not strictly necessary, you can see that the `HttpSecurity` object is there to help simplify construction of the filter chain.

Since the filter chain bean describes both authentication and authorization, it's important to remember that when you declare this bean, you must specify both. In other words, this overrides whatever default `SecurityFilterChain` bean Boot provides based on your application properties. You'll get to practice with an example of this shortly.

### So, Why Haven’t We Seen This Before?

This seems like a pretty important component, right? It is; it's the core of Spring Security configuration and nearly every application has one declared.

Why haven't we seen it yet? How is it that our Cash Card application in our labs work just fine without having implemented our own `SecurityFilterChain` bean?

The reason is simply because _Spring Boot publishes a default `SecurityFilterChain` bean if your app doesn't declare one of its own._

For example, when you added the `spring-security-oauth2-resource-server` dependency and the `spring.security.oauth2.resourceserver.jwt.issuer-uri` property, Spring Boot automatically published the default OAuth 2.0 Resource Server bean in the above code snippet.

This way, the application is secure by default, but still open for extension as needed.
