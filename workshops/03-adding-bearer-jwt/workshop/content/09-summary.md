In this lab, you changed the authentication scheme for your REST API and transformed it into an OAuth 2.0 Resource Server. Notice that doing this was a matter of changing a dependency and some configuration. In future modules, we'll see how to do some of this programmatically, but for now, the Spring Boot autoconfiguration details work great for us.

Now that you are authenticated, it's time to use the principal inside the application to look up different data for different users.
