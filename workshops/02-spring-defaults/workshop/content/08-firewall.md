In this last step, you'll briefly put on your white hat to try and break your application by sending a malicious payload.

One way you might try and confuse your application into giving you access to an endpoint is by making a request that in the beginning matches a permitted endpoint, but then simplifies into an unauthorized endpoint.

Hypothetically, Spring Security could be configured to require administrative rights to request the `/admin/**` endpoints, and everything else can be requested by any authenticated user. In that case, a user would not be able to request the `/admin` endpoint.

Let's try it.

1.  Request `/admin`.

    What do you think will happen when you request `/admin`?

    ```dashboard:open-dashboard
    name: Terminal
    ```

    ```bash
    [~/exercises] $ http :8080/admin
    HTTP/1.1 401
    ```

    Here we see the familiar `401` response, just as we received with `/non-existent-endpoint` or any other similar non-existent endpoint. No surprises here!

    But, what would happen if we tried to guess a more nested administrative function?

1.  Try to trick the app.

    Would something like the following let us in?

    ```bash
    [~/exercises] $ http :8080/admin%2Faction
    ```

    What's going on here? What's that weird `%2F`?

    Here the bad actor is adding an encoded "slash" or `/` into the URL as `%2F`, thus attempting to access `/admin/action`. The bad actor's guess is that if the request is `/admin/action`, then maybe Spring Security will compare it to the pattern `/admin/**` and let it pass.

    Thankfully, Spring Security's firewall rejects the request by default. If you try the above, you should see a response like the following:

    ```bash
    HTTP/1.1 400
    ...
    ```

    Because encoding a slash is a common way to try and bypass authorization expressions, it rejects the request outright as a `400 Bad Request`.

    Thanks, Spring Security!
