Last, take a look at the logs for the following line:

```bash
Set SecurityContextHolder to JwtAuthenticationToken [...]
```

Inside the braces, observe the details of the `Authentication` instance that was created. They should look something like this:

```bash
JwtAuthenticationToken [Principal=org.springframework.security.oauth2.jwt.Jwt@da5265e9, Credentials=[PROTECTED], Authenticated=true, Details=WebAuthenticationDetails [RemoteIpAddress=127.0.0.1, SessionId=null], Granted Authorities=[SCOPE_cashcard:read, SCOPE_cashcard:write]]
```

As you can see, the authentication instance that was created contains:

- A _principal_, which is the set of claims
- A _credential_, which is the original, signed JWT, and
- A set of _authorities_, which are each scope prefixed by `SCOPE_`

You can see that the authentication instance is for our Cash Card application: `SCOPE_cashcard:read` and `SCOPE_cashcard:write`.
