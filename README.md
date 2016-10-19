# dkru
A utility function to ease the pain of managing docker containers

This helps negate situations like:

```shell
$ docker stop $(docker ps -aq)
89c5f621ee7c
f55bb41ebc88
$ docker rm $(docker ps -aq)
89c5f621ee7c
f55bb41ebc88
$
```

Admittedly, this can be negated slightly by the following:


```shell
$ docker stop $(docker ps -aq)
89c5f621ee7c
f55bb41ebc88
$ ^stop^rm
89c5f621ee7c
f55bb41ebc88
$
```

## Listing containers and images

`dkru -l` will list all containers and images
`dkru -lc` will list all containers
`dkru -li` will list all images

## Removal of containers and images

`dckr -rc` will remove all _non running_ containers
`dckr -rc container_name_1 container_name_2` will only remove `container_name_1` and `container_name_2` __if__ they are not running

`dckr -ri` will remove all images
`dckr -ri image_name_1 image_name_2` will only remove `image_name_1` and `image_name_2`

## Starting containers

`dkru -u` will start all containers
`dkru -u container_name_1` will start `container_name_1` only

## Stopping containers

`dkru -d` will stop all containers
`dkru -d container_name_1` will stop `container_name_1` only