# mojo docker container

build docker runner image
```
docker build --build-arg userid=$(id -u) --build-arg groupid=$(id -g) \
  --build-arg username=$(id -un) \
  --build-arg mojo_auth=mut_0000000000b840bf88cbb83a8b93cc5d \
  --build-arg https_proxy=http://<any-http-proxy> \
  -t mojo-runner .
```

and run hello world
``
docker run -it mojo-runner
```

```
$ mojo
Welcome to Mojo! 🔥
Expressions are delimited by a blank line.
Type `:mojo help` for further assistance.
1> print("Hello, world!")
2.
Hello, world!
```
