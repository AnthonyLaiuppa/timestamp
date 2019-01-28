CGO_ENABLED=0 GIN_MODE=release GOOS=linux go build -a -installsuffix cgo -o main ../src/golang/timestamp.go
docker build -t example/timestamp -f Dockerfile.scratch .
#docker push example/timestamp #in order to get it in our docker repo
#docker run -it example/timestamp