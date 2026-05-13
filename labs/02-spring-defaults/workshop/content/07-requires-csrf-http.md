In this step, you'll call the `POST` endpoint and see how it differs in its behavior.

Try requesting the card creation endpoint `/cashcards` with the following:

```dashboard:open-dashboard
name: Terminal
```

```bash
[~/exercises] $ http -a user:<password-here> :8080/cashcards "Accept: application/json" amount=1 owner=sarah1
```

Even though the end user is authenticated, Spring Security denies the request like so:

```bash
HTTP/1.1 401
...
```

All requests require at least authentication by default, but `PUT`s, `POST`s, and `DELETE`s require a higher level of security to be allowed.

**_Note:_** Because of our earlier work with MockMvc, we've already proven that once a CSRF token is added, then the request passes. To keep things moving, then, we'll skip also proving this at the protocol level.

Because third-parties cannot read this header (remember the single point of origin policy we talked about in a previous course), Spring Security has confidence that when you present this header, it is coming from a trusted origin.
