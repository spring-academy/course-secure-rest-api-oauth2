In the previous lab you configured our application to be an OAuth 2.0 resource server and authenticated http requests using a JWT we supply in an environment variable.

Feel free to inspect the JWT now in the Terminal.

```dashboard:open-dashboard
name: Terminal
```

```shell
[~/exercises] $ jwt decode $TOKEN
...
✻ Payload
{
  "sub": "sarah1",
  "aud": "https://cashcard.example.org",
  "iss": "https://issuer.example.org",
  "exp": 1716239022,
  "iat": 1516239022,
  "scp": [
    "cashcard:read",
    "cashcard:write"
  ]
}
```

While you're at it, run the tests to verify they all still pass.

```shell
[~/exercises] $ ./gradlew test
...
BUILD SUCCESSFUL in 12s
```

Looking good so far!
