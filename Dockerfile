FROM golang:1.19.2-alpine AS build
WORKDIR /go/src
COPY api.go .
RUN go mod init api \
    && go mod tidy \
    && go get -u github.com/go-sql-driver/mysql github.com/gin-gonic/gin \
    && go build -o goapi api.go

FROM alpine:latest
RUN mkdir /app
COPY --from=build /go/src/goapi /app/goapi
CMD /app/goapi