FROM golang:1.22-alpine AS build
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN go build -o /bin/oracle ./cmd/oracle

FROM alpine:3.19
WORKDIR /app
COPY --from=build /bin/oracle /bin/oracle
EXPOSE 8088
CMD ["/bin/oracle"]

