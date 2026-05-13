Spring Security activates HTTP Basic by default since it is a straightforward way to get started. It has its limitations, though.

At a high level, these limitations are:

- Long-term Credentials
- Authorization Bypass, and
- Sensitive Data Exposure

Before going over them, consider a common arrangement of an application that uses HTTP Basic between a client and a REST API:

![Client and REST API communication](https://raw.githubusercontent.com/spring-academy/spring-academy-assets/main/courses/course-secure-rest-api-oauth2/client-and-rest-api.svg "Client and REST API communication")

In this diagram, there is a client application that uses your username and password to talk to a REST API on your behalf. An example of this is a third-party budgeting application that wants to call our fictional Cash Card REST API and import transactions.

## Long-Term Credentials

To understand this first limitation, consider this: When was the last time you changed the password on your least-frequently-used online account? In many cases, the answer is on the order of years!

If a REST API takes your username and password as credentials, then that means that anyone who obtains your username and password can impersonate you for as long as your password is valid. This includes bad actors as well as third-party applications.

Even if you could possibly change all your passwords in all systems on a weekly basis, which of your accounts would you be okay with granting access to a bad actor for a whole week? (Hint! The answer is none!)

Given that, the primary limitation of HTTP Basic is it uses a long-term credential that requires the end user to change it.

## Authorization Bypass

Another limitation is that when you give your REST API username and password to a third-party client, that application is now in possession of your username and password.

While that may seem obvious, it does mean that you need to now ask: Do you trust that application to only use your username and password for purposes that you want them to? Additionally, you are left to trust that application to not get compromised by bad actors whom you do not trust.

Imagine, for example, our fictional third-party budgeting application. It makes sense that you may want it to read cash card information from the REST API. But do you want it to also add and delete cash cards? Maybe not!

It would be nice if there were a way to have a credential that, in addition to being short-term, also indicated which things you authorize the client to do with your data.

## Sensitive Data Exposure

Remember that HTTP Basic is stateless. Whenever a third-party client application calls the REST API, it needs to hand over your username and password each and every time you make an HTTP request.

Also, it means that the client application needs to hold your username and password in plain text somewhere so that it can hand them repeatedly to the REST API.

This means that a single HTTP request being intercepted or a single memory dump of a client application could reveal your password!

So, in addition to having a short-term credential that is smart enough to authorize specific actions, your password should not be held (plaintext or otherwise) by any third-party anywhere. Ever.

Let's go to one more lesson to describe a solution to this problem before putting all of this into practice in Spring Security.
