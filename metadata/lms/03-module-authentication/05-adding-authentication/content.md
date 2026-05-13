In this module, you will learn about Spring Security as a framework for authenticating requests. This means confirming:

- The _caller's identity_ - who made the request, sometimes called the _client_ or the _agent_
- The _principal's identity_ - who the request is about, often an end user
- The _request's integrity_ - proof that the request wasn't modified by an intermediary

Each of those can be quite complex to ensure, which is why turning to security protocols and frameworks for support is strategically important.

**_Note:_** _Principal_ is a generic term that represents "who" is making the request. For the most part in this course, the "who" is the end user. The reason we use _principal_ is because sometimes the "who" is not a person but instead another machine.

## Content Negotiation

Spring Security's default settings confirm the principal's identity using the Form Login and HTTP Basic authentication schemes. It uses content negotiation to select between the two.

For example, if a browser navigates to an unauthenticated endpoint in your API, then, by default, Spring Security redirects to its stock login page which looks like this:

![Default Spring Security login page](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-secure-rest-api-oauth2/default-login-page.png "Default Spring Security login page")

On the other hand, if someone makes an unauthenticated REST request like this one:

```bash
[~/exercises] $ http :8080
```

Then, Spring Security uses the `WWW-Authenticate` header to indicate which authentication scheme it expects:

```bash
WWW-Authenticate: Basic
```

Instead, if the REST request supplies an `Authorization` header following the HTTP Basic scheme:

```bash
[~/exercises] $ http :8080 "Authorization: Basic dXNlcjpwYXNzd29yZA=="
```

**_Note:_** HTTPie's `http` command will add the `Authorization: Basic` header for you if you pass it the `-a` parameter. Above we've added the header manually for educational purposes.

Spring Security sees the _Basic_ scheme and exercises its HTTP Basic authentication support.

Let's explore this process in more detail.

## Authentication Process

To break this down a little further, you can think of Spring Security's authentication support in three parts, regardless of which authentication scheme it uses:

1. It parses the request material into a credential.
2. It tests that credential.
3. If the credential passes it translates that credential into a principal and authorities.

In the above case, you can see these three steps in action:

1. Spring Security decodes the Base64-encoded username and password. The password is the _credential_ in this case.
2. It tests this username and password against a user store. Specifically, with passwords, it hashes the password and compares it to the user's password hash.
3. If the passwords match, it loads the corresponding user and permissions and stores them in its security context. The resulting user is the _principal_ that we mentioned earlier.

All authentication schemes follow this general approach in Spring Security, and we'll see another example shortly.

## Authentication Result

In Spring Security terms, the result is an `Authentication` instance. As a class, it is modeled in the following way:

**Authentication**

- Principal ("who")
- Credentials ("proof")
- Authorities ("permissions")

Your application can retrieve this `Authentication` instance by various means that we'll see later on.

## Subsequent Requests

Some authentication schemes are stateful, while others are stateless. _Stateful_ means that your application remembers information about previous requests. _Stateless_ means that your application remembers nothing about any previous requests.

The two default authentication schemes are good examples of each. Form Login is an example of a stateful authentication scheme. It stores the logged in user in a session. So long as the session's identifier is returned on subsequent requests, then the end user doesn't need to provide credentials again. For many websites, this is why you do not need to log in with every new page you visit on the site (phew!).

HTTP Basic is an example of a stateless authentication scheme. Since it remembers nothing from previous requests, you need to give it the username and password on every request.

**_Note:_** Remember that Spring Security activates HTTP Basic and Form Login authentication schemes by default. You can specify them and others directly with a custom `SecurityFilterChain` instance, which you'll learn more about in a future module. For now, though, we'll rely on Spring Boot's autoconfiguration to make the right decisions for us.

We'll see these principles at work in an upcoming lab. Before that, though, let's learn in the next lesson some of HTTP Basic's limitations so we can prepare for a more modern authentication scheme.
