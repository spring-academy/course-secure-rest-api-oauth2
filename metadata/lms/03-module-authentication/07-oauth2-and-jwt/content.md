In this lesson, you'll learn about OAuth 2.0 Bearer Authentication with JWTs and how it addresses the limitations you discovered with HTTP Basic in the previous lesson.

## OAuth 2.0

Recall that one primary security concern is that passwords are long-term highly-sensitive credentials. It would be better to have credentials that last for only a few minutes. But, it is unrealistic for us humans to constantly change our passwords so often and still get anything done!

[OAuth 2.0](https://datatracker.ietf.org/doc/html/rfc6749) – an industry-standard protocol for authorization that has been adopted by thousands of companies and used in millions of applications – provides a framework for doing exactly this.

In brief, OAuth 2.0 describes three actors:

- The Client Application, which wants to access your data and provide you services - often a web, mobile, or desktop application.
- The Resource Server, which holds and secures your data - often a REST API.
- The Authorization Server, which authorizes a client to access your data.

![OAuth 2.0 Flow](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-secure-rest-api-oauth2/oauth-flow.svg "OAuth 2.0 Flow")

These three actors interact with each other in the following way:

1. The client application asks the authorization server for permission to command the resource server.
2. The authorization server decides whether to grant permission (more on this later).
3. If the authorization server grants permission, it creates or "mints" an _access token_ that expires after a short amount of time. This access token describes what permissions the client was granted
4. The client makes a request to the resource server, including the access token.
5. The resource server verifies that the access token has the right permissions and responds accordingly.

As you can see, the client application never sees your password.

The resource server still needs to authenticate the principal, though; this is where the access token becomes so important. While tokens are safer than passwords, they perform the same important security function of being a credential and thus need to be kept safe.

How do we securely create and manage them? Let's learn about that now.

## JSON Web Tokens

[JSON Web Token](https://datatracker.ietf.org/doc/html/rfc7519) (JWT) is an industry standard format for encoding access tokens. In other words, when an authorization server mints an access token, it can write it in the widely-adopted JWT format.

A decoded JWT at its most basic is a set of _headers_ and _claims_:

- _Headers_ contain metadata about the token, like how a resource server should process it.
- _Claims_ are facts that the token is asserting, like what principal the token represents. They are called "claims" because they still need to be verified by the resource server – the JWT "claims" these facts to be true.

An example might look like this:

```json
{
  "typ": "JWT",
  "alg": "RS256"
}
```

+headers

```json
{
  "aud": "https://cashcard.example.org",
  "exp": 1689364985,
  "iat": 1689361385,
  "iss": "https://issuer.example.org",
  "scp": ["cashcard:read", "cashcard:write"],
  "sub": "sarah1"
}
```

+claims

Look at all that data! What does it all mean? Let's look at just a few of them now:

- The _iss_ claim identifies the authorization server that minted the token.
- The _exp_ claim indicates when the token expires.
- The _scp_ claim indicates the set of permissions the authorization server granted.
- The _sub_ claim is a reference to the principal the token represents.

A critical piece of information is the JWT's signature. Think of a signature as your signature on a contract. A good signature can only be produced by one entity, which provides us with what's called _non-repudiation_, or proof that the contract was signed by you and only you.

In cryptography, a signature also provides _message integrity_, or proof that the message wasn't altered by anyone afterward. You can in this case think of the no-tamper seal on a can or a jar at the store. If the seal is broken, you shouldn't buy it from the store since it means someone may have tampered with it.

Part of the minting process is for the authorization server to sign the JWT. Then, the resource server verifies that signature. This lets the resource server confirm the integrity of the request in addition to the principal's identity.

### Cautionary Note: Stateful JWTs

It's a common temptation to want to use the JWT in stateful ways, like representing a session. Since this authentication scheme is stateless (like HTTP Basic), this is almost always a bad idea.

Consider for example that a JWTs expiry cannot be updated, but a session's expiry is updated on each request. Also consider that a person can log out and thus the session can be expired, but a JWT can't be expired (since its expiry cannot be edited). These important mismatches appear when we try to use a stateless token in stateful ways like session management.

## Spring Security Support

Spring Security has support for all three actors. In this course, we'll focus on its resource server support, which aligns well with REST APIs. We'll configure the application to recognize and parse JWTs, verify them, and formulate the principal accordingly.

For resource servers, let's review the steps you learned previously about how Spring Security processes authentication:

1. _It parses the request material into a credential._ Spring Security looks for `Authorization: Bearer ${JWT}`.
2. _It tests that credential._ Spring Security uses a `JwtDecoder` instance to query the authorization server for keys, uses those keys to verify the JWTs signature, and validates it's from a trusted issuer and is still within its expiry window.
3. _If the credential passes it translates that credential into a principal and authorities._ Spring Security stores the JWT's claims as the principal. It takes the `scope` claim and parses each individual value into a permission with the pattern `SCOPE_${value}`.

This principal and authorities are then stored by Spring Security and accessible for the remainder of the request.
