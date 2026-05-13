To generate JWTs, public and private keys are needed for encoding and decoding.

Specifically, our application needed the public key to decode the JWT whenever we sent it in our requests. We can see this `public-key-location` configuration in our `application.yml`:

```editor:select-matching-text
file: ~/exercises/src/main/resources/application.yml
text: "public-key-location"
description:
```

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          public-key-location: classpath:authz.pub
          audiences: cashcard-client
          ...
```

But, when using an Authorization Server, this is no longer the case!

Our application will defer to an Authorization Server to handle both the _encoding and decoding_ of JWTs for us.

This means that your local configuration will change, because the Authorization Server will mint the tokens instead.

### Set the `issuer-uri`

We need to tell our application _where_ the Authorization Server is running.

Let's decide now to run our Authentication Server at URI `http://localhost:9000`.

In `application.yml`, remove the unneeded `public-key-location` property, and provide the `issuer-uri` property to point to the Authorization Server: `http://localhost:9000`.

You'll end with the following configuration:

```editor:select-matching-text
file: ~/exercises/src/main/resources/application.yml
text: "public-key-location"
description:
```

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:9000
          audiences: cashcard-client
```

That's it for the configuration changes. Easy!

Let's make some API requests now that we've configured our API to use an authorization server.
