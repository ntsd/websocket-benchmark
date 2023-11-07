FROM golang:1.21-alpine

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY server.go .

RUN GOOS=linux go build -o /server-bin

EXPOSE 9001

CMD ["/server-bin"]
