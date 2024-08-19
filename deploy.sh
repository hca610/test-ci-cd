BRANCH_NAME=$1
IMAGE_NAME=hca610/hello-action:$BRANCH_NAME
CONTAINER_NAME=app-$BRANCH_NAME

CURRENT_IMAGE_ID=$(docker images -q $IMAGE_NAME)

# Get random unused port
while
  PORT=$(shuf -n 1 -i 49152-65535)
  netstat -atun | grep -q "$PORT"
do
  continue
done

echo "\n------------------------- PULL IMAGE ------------------------- "
docker pull hca610/hello-action:$BRANCH_NAME

NEW_IMAGE_ID=$(docker images -q $IMAGE_NAME)

echo "\n------------------ STOP AND REMOVE CONTAINER ------------------ "
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

echo "\n--------------- RUN NEW CONTAINER ON PORT $PORT --------------- "
docker run -d --name $CONTAINER_NAME -p $PORT:5000 $IMAGE_NAME

if [ "$CURRENT_IMAGE_ID" != "$NEW_IMAGE_ID" ]; then
    echo "\n------------------ REMOVE OLD IMAGE ------------------ "
    echo "docker rmi $CURRENT_IMAGE_ID"
    docker rmi $CURRENT_IMAGE_ID
fi

echo "Branch name: $BRANCH_NAME"
echo "Image name: $IMAGE_NAME"
echo "Container name: $CONTAINER_NAME"
echo "Port: $PORT"
echo "Current image id: $CURRENT_IMAGE_ID"
echo "New image id: $NEW_IMAGE_ID"