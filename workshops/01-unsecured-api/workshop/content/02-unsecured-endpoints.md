Please start the application in one of the Terminal panes:

```dashboard:open-dashboard
name: Terminal
```

```shell
[~/exercises] $ ./gradlew bootRun
...
<==========---> 80% EXECUTING [1m 15s]
> IDLE
> IDLE
> IDLE
> IDLE
> :bootRun
```

Once the application is running, use the other Terminal pane to make requests to the applications REST API.

Request the `/cashcards/` endpoint like so:

```bash
[~/exercises] $ http :8080/cashcards
```

**_Note:_** The above command is using [HTTPie](https://httpie.org). It is equivalent to but more awesome than `curl`.

You should see the following JSON in the output:

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
  },
  {
    "amount": 150.0,
    "id": 101,
    "owner": "esuez5"
  }
]
```

While our application works, it clearly does not secure its requests!

So, what's the big deal?
