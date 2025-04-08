So far, we've been validating against JWTs that are minted and provided for you, as part of the environment. For example, you've been reviewing the token with the `jwt decode` command in the Terminal.

```dashboard:open-dashboard
name: Terminal
```

```shell
[~/exercises] $ jwt decode $LOCAL_TOKEN
...
Token claims
------------
{
    "aud": "cashcard-client",
    "exp": 1698215644,
    "iat": 1698179644,
    "iss": "https://issuer.example.org",
    "scope": [
    "cashcard:read",
    "cashcard:write"
    ],
    "sub": "sarah1"
}
```

In addition, we've been programmatically minting tokens by using `CashCardSpringSecurityTests.mint(...)` in our tests. For example:

```editor:select-matching-text
file: ~/exercises/src/test/java/example/cashcard/CashCardSpringSecurityTests.java
text: "shouldShowAllTokenValidationErrors"
description:
```

```java
@Test
void shouldShowAllTokenValidationErrors() throws Exception {
    String expired = mint((claims) -> claims
            .audience(List.of("https://wrong"))
            .issuedAt(Instant.now().minusSeconds(3600))
            .expiresAt(Instant.now().minusSeconds(3599))
    );
    ...
}
```

This has been very convenient. Free JWTs for everyone!

However, this isn't a very realistic scenario.

Normally, an application would communicate with an Authorization Server, which would mint and provide tokens to API clients.

So, how about if we run a real Authentication Server and validate against it? Sounds fun, right?

Then let's do it!
