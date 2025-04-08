In this lab, we've provided some support code for you to assist with minting tokens in the tests.

Specifically, note the `@TestConfiguration` class at the bottom of `CashCardSpringSecurityTests`, a new test class we'll use to test some Spring Security internals. It publishes a `JwtEncoder` bean that will do the work of signing and serializing the token.

```editor:select-matching-text
file: ~/exercises/src/test/java/example/cashcard/CashCardSpringSecurityTests.java
text: "@TestConfiguration"
description:
```

Also, take a look at these already-included methods that use the `JwtEncoder` bean:

```editor:select-matching-text
file: ~/exercises/src/test/java/example/cashcard/CashCardSpringSecurityTests.java
text: "private String mint"
description:
```

```java
private String mint() {
    return mint(consumer -> {});
}

private String mint(Consumer<JwtClaimsSet.Builder> consumer) {
    JwtClaimsSet.Builder builder = JwtClaimsSet.builder()
        .issuedAt(Instant.now())
        .expiresAt(Instant.now().plusSeconds(100000))
        .subject("sarah1")
        .issuer("http://localhost:9000")
        .audience(Arrays.asList("cashcard-client"))
        .claim("scp", Arrays.asList("cashcard:read", "cashcard:write"));
    consumer.accept(builder);

    JwtEncoderParameters parameters = JwtEncoderParameters.from(builder.build());

    return this.jwtEncoder.encode(parameters).getTokenValue();
}
```

What the code is doing is providing a set of defaults that our tests can override and set to invalid values to demonstrate that Spring Security correctly rejects those tokens.

Now that you've reviewed the minting code, let's put it to use in our tests.

