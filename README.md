# mojo docker container

run something like
```
docker build --build-arg userid=$(id -u) --build-arg groupid=$(id -g) \
  --build-arg username=$(id -un) \
  --build-arg mojo_auth=mut_0000000000b840bf88cbb83a8b93cc5d \
  --build-arg https_proxy=http://<any-http-proxy> \
  -t mojo-runner .
```
