FROM golang:1.16-buster AS build

## Build
WORKDIR /app

COPY ./go.mod ./
RUN go get github.com/go-redis/redis/v8 \
    && go get github.com/julienschmidt/httprouter \
    && go get go.uber.org/zap \
    && go get github.com/prometheus/client_golang/prometheus/promhttp \
    && go mod download

COPY ./*.go ./

RUN go build -o /docker-gs-devops-test

## Deploy
##
FROM gcr.io/distroless/base-debian10

WORKDIR /

COPY --from=build /docker-gs-devops-test /docker-gs-devops-test

EXPOSE 8080

USER nonroot:nonroot

ENTRYPOINT ["/docker-gs-devops-test"]