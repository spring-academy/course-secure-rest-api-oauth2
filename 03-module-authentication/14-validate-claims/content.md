In this lesson, you'll learn more about customizing the authentication process, specifically regarding validating JWT claims.

## Authenticating a JWT

To orient your thinking, recall the three steps you learned earlier in this module about the authentication process:

1. Parse the credentials
2. **Validate the credentials**
3. Construct the corresponding principal and authorities

Right now, we're talking about **Step 2.**

## Validating a JWT

By default, Spring Security authenticates each JWT by:

1. Validating the signature, and
2. Checking that the current time is between the timestamps in the `iat` (Issued At) and `exp` (Expires At) claims.

In addition to the defaults, Spring Security can validate the issuer (the `iss` claim) and the audience (the `aud` claim). Since there's no way that Spring Security can know these values by default, they both need to be configured.

Boot provides properties to simplify adding these two validation steps. The first is `issuer-uri`:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://issuer.example.org
```

And the second is `audiences`:

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          audiences: https://cashcard.example.org
```

As you can see, the `issuer-uri` represents the endpoint that is minting the JWT, something like the "From" address in an email. `audiences` represents the endpoint that is receiving the JWT, something like the "To" address in an email. The first property indicates that the application only trusts JWTs "From" `https://issuer.example.org`. The second property is about the application's discipline to only "read email" that is sent "To" it.

## Custom Validation

If you want to customize validation further, in general you can look at `AuthenticationManager` as we already talked about in The Big Picture lesson.

For authenticating JWTs, there is a more specific component called `JwtDecoder`. The class hierarchy is like this:

![JwtDecoder hierarchy](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-secure-rest-api-oauth2/jwtdecoder-hierarchy.png "JwtDecoder hierarchy")

Each `JwtDecoder` instance takes care of verifying the signature and validating the claims. Because Spring Security uses the Nimbus library by default, the default implementation of `JwtDecoder` is called `NimbusJwtDecoder`. You can learn more about the Nimbus library through the Links section of this lesson.

You can specify custom validation steps by creating your own `NimbusJwtDecoder` like so:

```java
@Bean
JwtDecoder jwtDecoder(String issuer, String audience) {
    OAuth2TokenValidator<Jwt> defaults = JwtValidators.createDefaultWithIssuer(issuer);
    OAuth2TokenValidator<Jwt> audiences = new JwtClaimValidator<List<String>>(AUD,
        (aud) -> aud != null && aud.contains(audience));
    OAuth2TokenValidator<Jwt> all = new DelegatingOAuth2TokenValidator<>(defaults, audiences);
    NimbusJwtDecoder jwtDecoder = NimbusJwtDecoder.withIssuerLocation(issuer).build();
    jwtDecoder.setOAuth2TokenValidator(all);
    return jwtDecoder;
}
```

Note that this replaces the `issuer-uri` and `audiences` Boot properties.

Spring Security ships with both a `JwtDecoder` and `JwtEncoder` API, and we'll learn more about the `JwtEncoder` one in the next lab.

