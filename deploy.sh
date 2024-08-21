BRANCH_NAME=$1
IMAGE_NAME=hca610/hello-action:$BRANCH_NAME
CONTAINER_NAME=app-$BRANCH_NAME

CURRENT_IMAGE_ID=$(docker images -q $IMAGE_NAME)

echo "\n------------------------- PULL IMAGE ------------------------- "
docker pull hca610/hello-action:$BRANCH_NAME > /dev/null

REMOTE_IMAGE_ID=$(docker images -q $IMAGE_NAME)

if [ "$CURRENT_IMAGE_ID" = "$REMOTE_IMAGE_ID" ]; then
    echo "Not found new version of image for $BRANCH_NAME branch"
    exit
fi

echo "\n--------------------- CHECK CONTAINER STATUS --------------------- "
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  port_mapping=$(docker port $CONTAINER_NAME 5000)
  PORT=$(echo "$port_mapping" | grep -oP '\d{5,5}' | head -n 1)

  echo "Container $CONTAINER_NAME is running on port $PORT"
else
  echo "Container $CONTAINER_NAME is not running"

  # Get random unused port
  while
    PORT=$(shuf -n 1 -i 55500-55599)
    netstat -atun | grep -q "$PORT"
  do
    continue
  done
fi


echo "\n------------------ STOP AND REMOVE CONTAINER ------------------ "
docker rm -f $CONTAINER_NAME

echo "\n--------------- RUN NEW CONTAINER ON PORT $PORT --------------- "
docker run -d --name $CONTAINER_NAME -p $PORT:5000 $IMAGE_NAME

echo "\n---------------------- REMOVE OLD IMAGE ---------------------- "
echo "docker rmi $CURRENT_IMAGE_ID"
docker rmi $CURRENT_IMAGE_ID

echo "\n------------------ DEPLOYMENT SUCCESSFUL ------------------ "
echo "Branch name: $BRANCH_NAME"
echo "Image name: $IMAGE_NAME"
echo "Container name: $CONTAINER_NAME"
echo "Port: $PORT"
echo "Current image id: $CURRENT_IMAGE_ID"
echo "New image id: $REMOTE_IMAGE_ID"