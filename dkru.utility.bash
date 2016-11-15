# dkru -- Docker utilities
# Author Nigel Greenway <github@futurepixels.co.uk>

__=' 
Docker utility function

A simple utility belt to help manage containers without having to use
things like `docker stop $(docker ps -aq)`.
'
dkru() {
  local OPTIND
  getopts ":lsrudh" ACTION
  getopts ":ci" OPTION

  case $ACTION in
    l)
      case $OPTION in
        c)
          docker ps -a|awk '{ if (NR!=1) { print "IMAGE:",$2,"\tNAME:",$NF } }'
          ;;
        i)
          docker images -a|awk '{ if (NR!=1) { print "REPOSITORY:",$1,"\tTAG:",$2 } }'
          ;;
        *)
          echo "Containers"
          docker ps -a|awk '{ if (NR!=1) { print "IMAGE:",$2,"\tNAME:",$NF } }'
          echo ""
          echo "Images"
          docker images -a|awk '{ if (NR!=1) { print "REPOSITORY:",$1,"\tTAG:",$2 } }'
          echo ""
          echo "pass -c for containers only or -i for images only"
          ;;
      esac
      ;;
    s)
      echo "Container raw status:"
      docker ps -a
      echo ""
      echo "Image raw status"
      docker images -a
      ;;
    r)
      shift
      case $OPTION in
        c)
          __detach_containers "$@"
          ;;
        i)
          __detach_images "$@"
          ;;
        *)
          echo "A simple script to manage Docker containers."
          echo ""
          echo "Options: ( Items within [] denote optional paremeters )"
          echo "-c [one two three]       Remove Docker containers (leave blank for all containers)"
          echo "-i [one two three]       Remove Docker images (leave blank for all images)"
          ;;
      esac
      ;;
    u)
      shift
      __start_containers "$@"
      ;;
    d)
      shift
      __stop_containers "$@"
      ;;
    *|h)
      echo "Docker utilities"
      echo ""
      echo "A simple script to manage Docker containers."
      echo ""
      echo "Options:"
      echo "-l         List Docker containers/images"
      echo "-r         Remove Docker containers/images"
      echo "-u         Run docker-compose up or docker start depending on the project implementation"
      echo "-d         Run docker-compose stop or docker stop depending on the project implementation"
      ;;
  esac


  #############
  ## Functions
  #############

  __='
  Remove all or specified Docker containers
  '
  __detach_containers() {

    if [[ "$#" -gt 0 ]]
    then
      for CONTAINER in $@
      do
        ## Check if the container is running
        if [[ $(__is_container_running $CONTAINER) -gt 0 ]]
        then
          echo "$CONTAINER is running, please stop the container first!"
          return
        fi
        docker rm "$CONTAINER"
      done
    else
      echo -n "Are you sure you want to remove all containers? [y/N]"
      read response
      case $response in
        [yY][eE][sS]|[yY] )
          docker rm $(docker ps -aq)
          ;;
        * )
          false
          ;;
      esac
    fi

  }

  __='
  Remove all or specified Docker images
  '
  __detach_images() {

    if [[ "$#" -gt 0 ]]
    then
      for IMAGE in $@
      do
          docker rmi "$IMAGE"
      done
    else
      echo -n "Are you sure you want to remove all images? [y/N]"
      read response
      case $response in
        [yY][eE][sS]|[yY] )
          docker rmi $(docker images -aq)
          ;;
        * )
          false
          ;;
      esac
      docker rmi $(docker images -aq)
    fi

  }

  __='
  Start containers
  '
  __start_containers() {

    CONTAINER=$1  
    if [[ -f $(which docker-compose) && -f 'docker-compose.yml' ]]
    then
      docker-compose up
    elif [[ -f $(which docker) ]]
    then
      __is_container_running "$CONTAINER"
      if [[ $(__is_container_running "$CONTAINER") -gt 0 ]]
      then
        echo "$CONTAINER is running already"
      else
        docker start $(docker ps -f STATUS=exited | grep "$CONTAINER" | awk '{ print $1 }')
      fi
    else
      echo "You don't seem to have `docker-compose` or the Docker engine installed?"
    fi

  }

  __='
  Stop containers
  '
  __stop_containers() {

    if [[ -f $(which docker-compose) && -f 'docker-compose.yml' ]]
    then
      docker-compose stop
    elif [[ -f $(which docker) ]]
    then

      if [[ "$#" -gt 0 ]]
      then
        for CONTAINER in $@
        do
          echo "Stopping $CONTAINER"
          docker stop "$CONTAINER"
        done
        clear
      else
        docker stop $(docker ps -aq)
      fi

    else
      echo "You don't seem to have `docker-compose` or the Docker engine installed?"
    fi      

  }

  __='
  Check if a container is in a running state
  '
  __is_container_running() {
    docker ps -af STATUS=running | grep -c "$1"
  }
}
