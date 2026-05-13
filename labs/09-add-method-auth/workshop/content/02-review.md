Let's refresh our memory on what authorization rules we've already declared.

Go to the `CashCardApplication` class and take a look at the `SecurityFilterChain` bean declaration where you added request-level authorization:

```editor:select-matching-text
file: ~/exercises/src/main/java/example/cashcard/CashCardApplication.java
text: "SecurityFilterChain appSecurity"
description:
```

```java
@Bean
SecurityFilterChain appSecurity(
   HttpSecurity http,
   AuthenticationEntryPoint entryPoint) throws Exception {
   http
      .authorizeHttpRequests((authorize) -> authorize
         .requestMatchers(HttpMethod.GET,"/cashcards/**")
            .hasAuthority("SCOPE_cashcard:read")
         .requestMatchers("/cashcards/**")
            .hasAnyAuthority("SCOPE_cashcard:write")
         .anyRequest().authenticated()
      )
      .oauth2ResourceServer((oauth2) -> oauth2
         .authenticationEntryPoint(entryPoint)
         .jwt(Customizer.withDefaults())
      );
   return http.build();
}

```

What the above snippet says is this:

> "If the request is `GET /cashcards`, require read access; else if it's any other `/cashcards` request, require write access; at least require authentication for any other request".

While the above rules are good, they are not enough and leave a pretty big security hole: _Anyone_ with `cashcard:read` permissions can use our `GET cashcards/<id>` API endpoint and retrieve any cash card, _even if that cash card doesn't belong to them!_

Yikes! That's not good.

This is the kind of scenario we can lock down with method authorization.
