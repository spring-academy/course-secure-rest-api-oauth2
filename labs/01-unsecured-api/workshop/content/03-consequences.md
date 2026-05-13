Neglecting to secure our API's endpoints has at least three consequences:

- The content is **_public_** - you can't control who sees the information
- The content is **_anonymous_** - you can't know who is asking
- The content is **_unprotected_** - bad actors can take advantage of Browser-based vulnerabilities

### Public Content

Because the content is public, any user with access to the network location can command the API and see the data. While this can be mitigated somewhat with network security, practically speaking, most REST APIs are often exposed to the public internet through browsers or API gateways. Even if they weren't exposed to the public internet, the real threat of server-side request forgery ([SSRF](https://owasp.org/Top10/A10_2021-Server-Side_Request_Forgery_%28SSRF%29/)) should give us pause if we are considering leaving any of our production APIs open like this.

### Anonymous Content

Because the content is anonymous, we can't decide if the user is known, trustworthy, and authorized. Practically speaking, it is also trickier to show that user's specific content because their identifier is not in any of the request material.

You just saw this point in action when you first queried the API. It shows both `sarah` and `esuez5`'s content; it's a poor user experience. But! It can be alleviated by requiring authentication.

### Unprotected Content

And because the content is unprotected, when this REST API is exposed to a browser, it may make the application as a whole vulnerable to [CSRF](https://owasp.org/www-community/attacks/csrf), [MITM](https://owasp.org/www-community/attacks/Manipulator-in-the-middle_attack), [XSS](https://owasp.org/www-community/attacks/xss/) and other attacks without additional intervention.

In security terms, this application can neither _authenticate_ nor _authorize_ requests and it cannot mitigate common security vulnerabilities.

Let's investigate each of these in more detail.
