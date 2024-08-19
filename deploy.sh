BRANCH_NAME=$1
IMAGE_NAME=hca610/hello-action:$BRANCH_NAME

# Get random unused port
while
  PORT=$(shuf -n 1 -i 49152-65535)
  netstat -atun | grep -q "$PORT"
do
  continue
done

echo "\n------------------------- PULL IMAGE ------------------------- "
docker pull hca610/hello-action:$BRANCH_NAME

echo "\n------------------ REMOVE CONTAINER AND OLD IMAGE ------------------ "
docker rm -f $(docker ps -q --filter ancestor=$IMAGE_NAME)

echo "\n--------------- RUN NEW CONTAINER ON PORT $PORT --------------- "
docker run -d --name app-$BRANCH_NAME -p $PORT:5000 $IMAGE_NAME
