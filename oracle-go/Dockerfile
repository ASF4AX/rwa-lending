FROM golang:1.24-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /bin/oracle ./cmd/oracle

FROM alpine:3.19
COPY --from=build /bin/oracle /bin/oracle
EXPOSE 8088
CMD ["/bin/oracle"]
