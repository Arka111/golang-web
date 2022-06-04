FROM golang:1.17.0-alpine3.14 as builder
WORKDIR /go/src/app
ADD *.go .
RUN go mod init 
RUN  go build -o ./web

# generate clean, final image for end users
FROM alpine:3.14.2
COPY --from=builder /go/src/app/web .
EXPOSE 8080
# executable
CMD [ "./web" ]
