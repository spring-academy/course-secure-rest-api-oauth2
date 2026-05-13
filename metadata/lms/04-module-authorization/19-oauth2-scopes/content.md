In this lesson, you'll learn about how authorization is represented in OAuth 2.0 and how that maps to Spring Security.

## The `scp` Claim

Recall the JWT that you've already seen a few times to this point:

```json
{
  "aud": "https://cashcard.example.org",
  "exp": 1686871416,
  "iat": 1686867816,
  "iss": "https://issuer.example.org",
  "scp": ["cashcard:read", "cashcard:write"],
  "sub": "sarah1"
}
```

The `scp` claim is sometimes seen as the "scope" claim. It is the set of permissions that this token has. Spring Security checks these values against the authorization rules that you declare in your application.

### Scope Naming Standards

Just kidding! There are no standard conventions for scope names, but in this course we'll follow a common _convention_ `resourcename:operation`. So, you can interpret `cashcard:read` as "the permission to perform cash card read operations".

While in practice these can be as fine-grained as needed – like `cashcard:remove`, `cashcard:update`, and `cashcard:close-account` – we'll just stick with `:read` and `:write`.

## Requesting Authority

Remember consent pages? For example, if you log into a third-party site with a Google account, you're likely to see an intermediate page that asks you which things you are okay with the third-party doing with your data. It sometimes looks like this:

![Consent page example](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-secure-rest-api-oauth2/submit-consent.png "Consent page example")

Generally speaking, each box corresponds to a different value in the `scp`, or "scope" list.

In the diagram here:

![OAuth 2.0 Flow](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-secure-rest-api-oauth2/oauth-flow.svg "OAuth 2.0 Flow")

This is the "Step 2" that we said we were going to talk about later - good job making it so far!

What happens is this:

1. The client knows what parts of your data it needs in order to function. So, it asks the authorization server for permission to access or operate on that data.
2. The authorization server in turn _asks you_ the end user if you are okay with it.
3. If you say "yes", then the authorization server creates a JWT whose `scp` claim reflects which permissions you decided to grant.

## Granting Authority

In Spring Security terms, scopes are _granted authorities_, or the authorities (permissions) that the end user _granted_ to the client application.

For a JWT like this:

```json
{
  "aud": "https://cashcard.example.org",
  "exp": 1686871416,
  "iat": 1886867816,
  "iss": "https://issuer.example.org",
  "scp": ["cashcard:read", "cashcard:write"],
  "sub": "sarah1"
}
```

Spring Security would authenticate the JWT and then _grant_ two authorities to the `Authentication` instance; `SCOPE_cashcard:read` and `SCOPE_cashcard:write`.

### About Prefixes

The `SCOPE_` prefix is there because authorities can come from multiple sources. If it starts with `SCOPE_` then it likely came from a JWT. If it starts with `ROLE_` it likely came from a database. Also, you can use these prefixes strategically, like saying that this `ROLE_` authority implies these _n_ `SCOPE_` authorities.

So, if you wanted to say that `/cashcards` requires the `cashcard:read` authority, then you could specify this on the `/cashcard` Spring MVC method like so:

```java
@GetMapping("/cashcards")
@PreAuthorize("hasAuthority('SCOPE_cashcard:read')")
public ResponseEntity<Iterable<CashCard>> findAll(@CurrentOwner String owner) {
    // ...
}
```

Then, if an end user doesn't grant that permission to the client application, when the client application calls your REST API, that request will be blocked.