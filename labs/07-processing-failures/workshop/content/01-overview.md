In this lab, you're going to learn hands-on how Spring Security processes authentication failures. By the end, you'll have a custom authentication entry point that gives more helpful information to the OAuth 2.0 client when something goes wrong during a request.

### An Invalid JWT

We've provide an invalid token named... well, `INVALID_TOKEN`.

Give it a look using the `jwt` command line tool.

```dashboard:open-dashboard
name: Terminal
```

```shell
[~/exercises] $ jwt decode ${INVALID_TOKEN}
...
Token claims
------------
{
  "aud": "https://wrong.example.org",
  "exp": 1672556400,
  "iss": "https://issuer.example.org",
  "scope": [
    "cashcard:read"
  ],
  "sub": "sarah1"
}
```

As you can see, not only is the expiry old (as you may know, `1672556400` represents January 1, 2023!), but the audience is _also_ different from the one we configured in a previous lab as `cashcard-client`:

What will happen when we attempt to use this invalid token for requests to our API?

Let's find out.
