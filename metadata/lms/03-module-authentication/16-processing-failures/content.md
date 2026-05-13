In this lesson, you'll learn how Spring Security handles authentication failures and how you can configure and customize that behavior.

## Remember Content Negotiation

Before we go to handling authentication failures, we're going to need to stretch back to the first step in this module to recall the principle of content negotiation (feel free to jump over there if you want to refresh your memory more deeply).

Basically, Spring Security will ask for authentication in different ways depending on who the client is.

Let's take the situation where no one is logged in and a URI that requires authentication is requested. In that case:

- _if_ the client is a browser, then Spring Security will show a login page
- _else, if_ the client is an HTTP Basic client, then Spring Security will respond with a 401 and a `WWW-Authenticate: Basic` response header
- _else, if_ the client is a Bearer Token client, then Spring Security will respond with a 401 and a `WWW-Authenticate: Bearer` response header

## Handling Authentication Failure

Another situation where this comes up is where authentication details are provided, but they are wrong. For example, the user gives the wrong password or the Bearer Token client provides an expired JWT.

Spring Security will act in the same way in these situations as with an unauthenticated request.

That's because both these cases – an unauthenticated request and a failed authentication – are both considered authentication failures.

Interesting! This means that these authentication failure responses do more than report a failure: They are also telling the client _how to try again_.

So, how does Spring Security do this? Let's now learn about what Spring Security terms "authentication entry points".

## `AuthenticationEntryPoint`

For each of the above scenarios, there's a corresponding `AuthenticationEntryPoint` implementation in Spring Security.

It goes like this:

- _if_ the client is a browser, then Spring Security will use its `LoginUrlAuthenticationEntryPoint`
- _else, if_ the client is an HTTP Basic client, then Spring Security will use its `BasicAuthenticationEntryPoint`
- _else, if_ the client is a Bearer Token client, then Spring Security will use its `BearerTokenAuthenticationEntryPoint`

Each entry point is how Spring Security provides both error and try-again information to the client. You can think of it as Spring Security taking you back to the "entry point" of the application.

Let's explore a couple of common entry point implementations and then see when you may run into them in day-to-day development.

### `LoginUrlAuthenticationEntryPoint`

In the case of a browser, if you go to an unauthenticated endpoint or if your credentials are wrong, Spring Security will redirect you to the login _entry point_ page shown below, or the point at which the user enters your application.

![Default Spring Security login page](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-secure-rest-api-oauth2/default-login-page.png "Default Spring Security login page")

You can find this functionality in Spring Security's `LoginUrlAuthenticationEntryPoint`.

### `BearerTokenAuthenticationEntryPoint`

In the case of a REST API Bearer Token client, the entry point and the error response are the same thing:

```shell
WWW-Authenticate: Bearer error="invalid_token",error_description="A description of the error", error_uri="[https://tools.ietf.org/html/rfc6750#section-3.1](https://tools.ietf.org/html/rfc6750#section-3.1)"
```

This entry point is describing what should happen next by providing information in the `WWW-Authenticate` header: To _enter_ this application, please provide a valid bearer token.

You can find this functionality in Spring Security's `BearerTokenAuthenticationEntryPoint`.

## Authentication Filters

We've learned a bit here about authentication entry points, but when does Spring Security know when to invoke one?

Remember the lesson about the filter chain? Let's recall the pseudocode for JWT authentication and see where this fits in:

```java
// NOTE: This is pseudocode, not real code!
if (!requestMatcher.matches(request)) {
    // skip this filter
} else {
    Authentication token = getAuthenticationRequest(request)
    try {
        Authentication result = authenticationManager.authenticate(token)
        saveToSecurityContextHolder(result);
        fireSuccessEvent(result);
        handleSuccess(result);
    } catch (AuthenticationException ex) {
        handleFailure(token); // <== Error handled here!
    }
}
```

As you can see by the `<== Error handled here!` comment in the code, if the JWT fails authentication, say because it is expired or because the audience is invalid, then the filter will invoke the correct authentication entry point.

## Customizing Error Handling

As with other Spring Security components, you don't have to configure anything to use the default implementations of authentication entry points. But, if these are not sufficient for your application you can provide your own authentication entry point or customize an existing one.

When might you do this? For example, it's true that `error_description` in the Bearer Token Usage specification is unclear on what to do if you have multiple errors to send back to the client. So, application developers need to make a choice: Given that Spring Security does not handle this situation verbosely, how should our authentication entry point represent multiple errors?

One option is to send multiple `WWW-Authenticate` headers like this:

```shell
WWW-Authenticate: Bearer error_code="invalid_token", error_description="The token is expired", error_uri="[https://tools.ietf.org/html/rfc6750#section-3.1](https://tools.ietf.org/html/rfc6750#section-3.1)"

WWW-Authenticate: Bearer error_code="invalid_token", error_description="The token audience is invalid", error_uri="[https://tools.ietf.org/html/rfc6750#section-3.1](https://tools.ietf.org/html/rfc6750#section-3.1)"
```

Or maybe you could comma-delimit all error messages and place them all in a single `error_description` like this:

```shell
WWW-Authenticate: Bearer error_code="invalid_token", error_description="The token is expired, the token audience is invalid", error_uri="[https://tools.ietf.org/html/rfc6750#section-3.1](https://tools.ietf.org/html/rfc6750#section-3.1)"
```

Or perhaps your application requires yet another multi-error scheme!

Because this is ambiguous in the Bearer Token Usage specification, it's a great place for the framework to take a back seat, inviting you to decide for yourself.
