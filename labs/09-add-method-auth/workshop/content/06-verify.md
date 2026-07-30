Let's have some fun!

Let's verify that method security is behaving as we expect when we make real requests to our running API.

1. Inspect the tokens.

   Let's take a look at two tokens we've provided for you; one each for our good friends `sarah1` and `esuez5`.

   In the Terminal, review the contents of `sarah1`'s token, `SARAH_TOKEN`:

   ```dashboard:open-dashboard
   name: Terminal
   ```

   ```shell
   [~/exercises] $ jwt decode $SARAH_TOKEN

   Token header
   ------------
   {
     "typ": "JWT",
     "alg": "RS256"
   }

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

   Next, let's look at `esuez5`'s token, `ESUEZ_TOKEN`:

   ```shell
   [~/exercises] $ jwt decode $ESUEZ_TOKEN

   Token header
   ------------
   {
     "typ": "JWT",
     "alg": "RS256"
   }

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
     "sub": "esuez5"
   }
   ```

   We can see that both tokens have both read and write permissions, but only for the _specific `sub`_ in each: `sarah1` or `esuez5`.

   Let's use those tokens to fetch some cash cards!

1. Start the application.

   In one of the Terminal panes, start the application.

   ```shell
   [~/exercises] $ ./gradlew bootRun
   ...
   <==========---> 80% EXECUTING [7s]
   > :bootRun
   ```

1. Fetch cash cards for `sarah1`.

   Next, in the other Terminal pane, request one of `sarah1`'s cash cards using their token as follows:

   ```shell
   [~/exercises] $ http :8080/cashcards/99 "Authorization: Bearer $SARAH_TOKEN"
   HTTP/1.1 200
   ...
   {
       "amount": 123.45,
       "id": 99,
       "owner": "sarah1"
   }
   ```

   Nothing too exciting here! This works as expected because it's `sarah1` who is requesting their own data.

   Let's see what happens when `esuez5` requests the same data.

1. Try to fetch someone else's cash card.

   Let's have `esuez5` try to fetch one of `sarah1`'s cash cards:

   ```shell
   [~/exercises] $ http :8080/cashcards/99 "Authorization: Bearer $ESUEZ_TOKEN"
   HTTP/1.1 403
   ...
   WWW-Authenticate: Bearer error="insufficient_scope", error_description="The request requires higher privileges than provided by the access token.", error_uri="https://tools.ietf.org/html/rfc6750#section-3.1"
   ```

   Not today, my friend!

   We see `esuez5` receives a `403 Forbidden` status code, an error of `insufficient_scope`, and a descriptive message when trying to fetch someone else's cash card.

   Check out that nasty stack trace in the `bootRun` Terminal pane, too.

   ```shell
   ...
   2026-07-30T12:32:47.117Z TRACE 3891 --- [nio-8080-exec-3] o.s.s.w.a.ExceptionTranslationFilter     : Sending JwtAuthenticationToken [Principal=org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter$JwtAuthenticatedPrincipal@ad32e85a, Credentials=[PROTECTED], Authenticated=true, Details=WebAuthenticationDetails [RemoteIpAddress=0:0:0:0:0:0:0:1, SessionId=null], Granted Authorities=[SCOPE_cashcard:read, FactorGrantedAuthority [authority=FACTOR_BEARER, issuedAt=2026-07-30T11:32:47.117972Z], SCOPE_cashcard:write]] to access denied handler since access is denied

   org.springframework.security.authorization.AuthorizationDeniedException: Access Denied
            at org.springframework.security.authorization.method.ThrowingMethodAuthorizationDeniedHandler.handleDeniedInvocationResult(ThrowingMethodAuthorizationDeniedHandler.java:47) ~[spring-security-core-7.1.0.jar:7.1.0]
            at org.springframework.security.authorization.method.PostAuthorizeAuthorizationManager.handleDeniedInvocationResult(PostAuthorizeAuthorizationManager.java:115) ~[spring-security-core-7.1.0.jar:7.1.0]
            at org.springframework.security.authorization.method.AuthorizationManagerAfterMethodInterceptor.handlePostInvocationDenied(AuthorizationManagerAfterMethodInterceptor.java:201) ~[spring-security-core-7.1.0.jar:7.1.0]
   ...
   ```

   Here we see quite a few messages about `Access Denied`, too.

Thanks, method security!
