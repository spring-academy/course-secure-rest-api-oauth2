There are many ways where authorization can be decided by an external entity.

As you know, this course focuses on the OAuth 2.0 story, which communicates those authorization decisions in the way of OAuth 2.0 scopes. And so far in the labs, we’ve been mocking those authorization decisions by way of using pre-minted JWTs.

In this final lesson, you’ll learn how to connect a resource server to an authorization server that will make authorization decisions and mint JWTs for us.

## Using an Authorization Server

To point your resource server at an authorization server, you need to add the `spring-security-oauth2-resource-server` dependency and add the `oauth2ResourceServer` DSL call to the filter chain definition.

In addition to this, the resource server needs to know where the authorization server is located. You can do this with a Spring Boot property, like so:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://example.org/oauth2
```

This is similar in nature to the `public-key-location` property you learned about early on in this course. The difference is that Spring Security can use the `issuer-uri` property to compute an Authorization Server endpoint that serves a set of public keys, effectively replacing the `public-key-location` property.

On startup, Spring Security uses this property to formulate an OIDC Discovery request to the authorization server. For example, it will take [https://example.org/oauth2](https://example.org/oauth23) and turn it into [https://example.org/oauth2/.well-known/openid-configuration](https://example.org/oauth2/.well-known/openid-configuration) which will have a result similar to the following:

```json
{
  // …
  “jwks_url” : “https://example.org/oauth2/jwks”
  // …
```

The `jwks_url` endpoint is the source that the resource server will use to retrieve, cache, and periodically re-retrieve the authorization server’s public keys throughout the life of the application.

What Spring Security does with this value is create the `JwtDecoder` bean you learned about during the Authentication module. It looks something like this:

```java
@Bean
JwtDecoder jwtDecoder() {
    return new SupplierJwtDecoder(() -> JwtDecoders.fromIssuerLocation(issuerUri).build());
}
```

**Note:** `SupplierJwtDecoder` is there to defer the call to the authorization server until the first request. This makes the decoder more resilient during restarts since then the authorization server doesn’t need to be running.

Once started, to talk to the resource server, you now must ask the authorization server for a token, using any of the _grant flows_ that it supports. The two most common for REST APIs are the authorization code grant flow and the client credentials grant flow. We’ll take a look at the client credentials grant flow in the next lab.

## But, I Don’t Have an Authorization Server

Sometimes a REST API’s needs are simple enough that the developer wants to have the REST API mint its own tokens. You, of course, can validate self-signed tokens, but first, ask yourself “why am I self-signing tokens?”

For example, a developer might want to give the user’s username and password to the REST API and exchange it for a JWT so as to not have to use the username and password over and over again. As long as that’s where it stops – and the JWT does not become a representation of the session – then [that’s fine](https://github.com/spring-projects/spring-security-samples/tree/main/servlet/spring-boot/java/jwt/login). While it’s out of scope for this course, you’ve already seen in the `CashCard` tests that you can use Spring Security’s `JwtEncoder` to assist with this.

Where things can become quite tricky is when you ask yourself: How do you know if the user is still logged in, if their session has expired, if they’ve logged out, or if they need to be forcibly removed? These are all _stateful_ questions. Since a JWT is _stateless_ and non-revocable, [you cannot use the JWT alone](https://developer.okta.com/blog/2017/08/17/why-jwts-suck-as-session-tokens) to make these kinds of security decisions.

And while you could add state into your design to address these concerns, remember that there already exist well-vetted security standards, like OIDC/OAuth 2.0, that Spring Security already supports. An authorization server, combined with Spring Security’s OAuth 2.0 Client support helps you to service these needs in a standards-based way.
