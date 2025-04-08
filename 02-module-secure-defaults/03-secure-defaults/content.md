In this section, you're going to learn about some of Spring Security's defaults and how this relates to you applying the principles of _Secure by Default_ and _Principle of Least Privilege_ to your applications.

_Secure by Default_ is a principle that encourages you to ensure that your default settings are secure. In this way, if an application finds itself in production with the defaults, it isn't a security vulnerability.

_Principle of Least Privilege_ is a principle that encourages you to think about each piece of data as a privilege to possess and to give end users the lowest privileges possible that let them do their work well.

Spring Security embraces both of these philosophies to automatically secure REST APIs.

## Spring Security Defaults

When Spring Security is on the classpath, Spring Boot works to configure your application with the following defaults for a REST API:

- Requires authentication for all requests
- Responds with secure headers for all requests
- Requires CSRF mitigation for all requests with side-effects
- Allows for HTTP Basic authentication with a default user
- Responds RESTfully to security failures
- Protects against malicious requests with an application firewall

Let's look at each of these one at a time and tie them back to the principles of Secure by Default and Principle of Least Privilege.

## Requires Authentication for All Requests

Whether the endpoint is you-generated or Boot-generated, all requests across all dispatches require authentication.

Regardless of the nature of the endpoint, Spring Security applies a Servlet Filter that inspects every request and rejects it if the request is unauthenticated.

This is one of Spring Security's secure defaults.

### Servlets, Filters, and Dispatchers

To understand this a bit better, we need to cover a small amount of Servlet API terminology.

The Java Servlet API is the module in Java for processing HTTP requests inside of an application. Using servlet terminology, a given HTTP request can pass through multiple _dispatches_. Each dispatch can be intercepted by multiple _filters_ on its way to a single _servlet_.

A _servlet_ handles HTTP requests and yields an HTTP response. You can think of a servlet like a "mini-server".

A _filter_ intercepts HTTP requests to handle cross-cutting concerns. Typically, filters either enrich the request in some way or they deny the request, preventing it from reaching the servlet.

A _dispatch_ represents a single pass an HTTP request makes through a set of filters and its target servlet. Typically, an HTTP request first passes through the REQUEST dispatch, but can also subsequently pass through the ERROR dispatch, the FORWARD dispatch, and others.

In Spring terms, Spring MVC constitutes a single servlet, Spring Security constitutes a set of filters, and Spring Boot ships with an embedded container that performs the various dispatches needed to service a single request.

All of this means that Spring Security defaults require that every _dispatch_ be authenticated.

### Security Benefits

The nice thing about this arrangement is that it doesn't matter who created the endpoint. If it is you, Boot, or a third-party, Spring Security's servlet filter intercepts the request before any servlet (a "mini-server") can process it.

This means that when you include Spring Security even non-existent endpoints will return a `401 Unauthorized` HTTP response status code instead of, say, a `404 Not Found` – the default Spring Boot response for non-existent endpoints. The reason for this strict policy is because of the _Principle of Least Privilege_. This principle says that you should offer only the information that the end user is privileged to know.

So what's the big deal? What's so privileged about a non-existent endpoint?

For security purposes, even which URIs are valid is privileged information. You can imagine if someone requested _index.jsp_ or _/admin_. If Spring Security returned a `404` in those cases instead of a `401`, that would mean `404` is a hint to a bad actor that a given endpoint exists! The bad actor can use this hint to enumerate the REST APIs valid URIs, figure out underlying vulnerable technologies, and [accelerate their attack](https://owasp.org/www-project-top-ten/2017/A9_2017-Using_Components_with_Known_Vulnerabilities).

Okay, so now that every request requires authentication, you might be wondering... How am I supposed to command any of my APIs? If they require authentication, shouldn't there be a username and password or something?

Hang on. We'll get there momentarily. First, though, let's talk about some defenses that Spring Security puts into place.

## Responds With Secure Headers for All Requests

HTTP headers allow a client and server to exchange additional information between each other in an HTTP request and response. Whether a request is authenticated or not, Spring Security always responds with certain headers by default. Each header defaults to the most secure value available.

### Caching Headers

The first are cache control headers. One class of browser-based vulnerabilities is that HTTP responses get cached in the browser. For example, suppose your REST API returned the following:

```json
[
  {
    "amount": 123.45,
    "id": 99,
    "owner": "sarah1"
  },
  {
    "amount": 1.0,
    "id": 100,
    "owner": "sarah1"
  }
]
```

Then that response could be cached in the browser for later retrieval by a bad actor on the user's local machine. Or, more practically, even if an end user loses access themselves or revokes it from the client application, the browser may still be able to retrieve that sensitive data from its cache.

Spring Security applies secure settings for _Cache-Control_ and other headers to mitigate this class of vulnerabilities.

### Strict Transport Security Header

The second is the Strict Transport Security header. This header forces a browser to upgrade requests to HTTPS for a specified period of time.

**_NOTE:_** Since this is intended for HTTPS requests, it isn't written by default for an HTTP request. Given that, you might not see it in your local testing over HTTP.

HTTPS has long been shown to be a critical component of secure deployments. Man-in-the-middle attacks make it possible for the data passing between the end user and the REST API to be viewed and modified.

Such attacks are mitigated by HTTPS, and the Strict Transport Security header tells the browser to not send any requests to this REST API over HTTP. Instead, any HTTP requests should be automatically upgraded by the browser to HTTPS.

### Content Type Options

The third and final header that we'll talk about at this point is the `X-Content-Type-Options` header. This header tells browsers to not try to guess the content type of a response.

A common place where bad actors hide is where the HTTP protocol is fuzzy and applications try to understand, disambiguate, and guess the intent of the request or response. A browser, for example, may look at a response that starts with `<html>` and reasonably guess that the content type is `text/html` – that is, a web page. Sometimes this guessing is unsafe. For example, it is possible for an image to contain scripting content and the browser can be tricked into guessing and executing `steal-my-password.jpg` as JavaScript. Crazy, right?

Spring Security addresses this by issuing a secure setting for `X-Content-Type-Options` by default.

## Requires CSRF Mitigation for All Requests With Side-Effects

Another place where REST APIs are at risk is the ability for third-party web sites to make requests to them without the user's consent.

This is possible since browsers, by default, send all cookies and HTTP Basic authentication details automatically to any non-XHR endpoint.

For example, take a look at this request for a so-called image:

```html
<img src="https://mybank.example.org/account/32?transfer=25&toAccount=45" />
```

Yikes! This request will be executed by the browser. This works because the browser has no way of knowing whether the URL points to an image until the response comes back. By then, the damage has already been done.

As you can imagine, browsers even make this request on third-party websites. Browsers, by default, will send all of `mybank.example.org`'s cookies and HTTP Basic credentials to it by default as well. This means that if your user is logged in, a third-party application can command your REST API without further protection.

Because of that, Spring Security automatically protects these endpoints with side-effects, like POSTs, PUTs, and DELETEs. It does this by sending a special token to the client that it should use on subsequent requests. The token is transmitted in such a way that third parties cannot see it. So when it is returned, Spring Security believes that it is legitimately from the client.

## Allows HTTP Basic Authentication With a Default User

You've been wondering about this, haven't you?

Spring Security generates a default user called `user`. Its password is generated, though, on each startup.

The reason for that is so that if you accidentally deploy Spring Security defaults to production, no one can use the default username and password to command your application. This is another classic instance of creating an application that is _Secure By Default_ or, in other words, an application whose default settings are secure.

To find out the password, you can look at the Boot startup logs for this string:

```bash
Using generated security password: fc7e0357-7d82-4a9c-bae7-798887f7d3b3
```

The UUID in that string is the password. It will be different for each time the application starts up.

As stated, Spring Security, by default, will accept this username and password using the HTTP Basic authentication standard, which you'll have an opportunity to practice with in just a moment.

## Responds RESTfully to Security Failures

Spring Security responds with a `401 Unauthorized` status code when credentials are wrong or missing from the request. It also, by default, will send the appropriate headers to indicate the kind of authentication that is expected. The implied meaning of a `401` is that the request is _unauthenticated_.

It responds with a `403 Forbidden` status code when credentials are good, but the request isn't authorized, like when an end user tries to perform an admin-only request. The implied meaning of a `403` is that the request is _unauthorized_.

## Protects Against Malicious Requests With an Application Firewall

There are myriad other ways that a bad actor may try and misuse your REST API. With many of them, the best practice is to reject the request outright.

Spring Security helps you with this by adding an application firewall that, by default, rejects requests that contain double encoding and several unsafe characters like carriage returns and linefeeds. Using Spring Security's firewall helps mitigate entire classes of vulnerabilities.
