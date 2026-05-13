By the end of this lab, you'll know how to add OAuth 2.0 scope-based authorization rules to any HTTP request pattern in your application.

### Review the Security Configuration

To get started, open and review the `SecurityFilterChain` bean declaration in the `CashCardApplication` class.

```editor:select-matching-text
file: ~/exercises/src/main/java/example/cashcard/CashCardApplication.java
text: "SecurityFilterChain appSecurity"
description:
```

```java
@Bean
SecurityFilterChain appSecurity(HttpSecurity http,
      AuthenticationEntryPoint entryPoint)
      throws Exception {
   http
      .authorizeHttpRequests((authorize) -> authorize
         .anyRequest().authenticated()
      )
      .oauth2ResourceServer((oauth2) -> oauth2
         .authenticationEntryPoint(entryPoint)
         .jwt(Customizer.withDefaults())
      );
   return http.build();
}
```

As you already know, the `HttpSecurity` bean is used to configure the application's request-based security. So far we used it to add our custom `entryPoint`.

It's also configured to _require that all requests be authenticated_.

Before we move on, take a moment to run all the tests to ensure everything is passing:

```dashboard:open-dashboard
name: Terminal
```

```shell
[~/exercises] $ ./gradlew test
...
BUILD SUCCESSFUL in 12s
```

Looks like everything is in a great starting place!

Now, let's add security scopes to our API.
