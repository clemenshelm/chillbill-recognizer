# ChillBill recognizer

To start recognition, you'll have to launch 2 processes:

1. The dispatcher daemon which will take care of starting workers for each incoming bill and communicating back the recoginition result
2. The Sidekiq worker process which will do the heavy lifting of bill recognition.

Starting the dispatcher daemon:

```shell
bundle exec ruby ./daemon.rb
```

Starting the Sidekiq worker process:

```shell
bundle exec sidekiq -r ./sidekiq.rb
```
