FROM golang:1.23-alpine AS build
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN go build -ldflags="-w -s" -o server .

FROM alpine:3.21
RUN addgroup -S appgroup && adduser -S appuser -G appgroup && \
    apk add --no-cache wget
COPY --from=build /app/server /server
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1
USER appuser
CMD ["/server"]
