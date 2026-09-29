# STAGE 1: Build Environment
FROM rust:1.80 AS builder
WORKDIR /app

# Install SQLite build dependencies
RUN apt-get update && apt-get install -y libsqlite3-dev

COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

COPY src ./src
RUN touch src/main.rs
RUN cargo build --release

# STAGE 2: Runtime Environment
FROM debian:bookworm-slim
WORKDIR /app

# Install runtime SQLite library and SSL certificates
RUN apt-get update && apt-get install -y libsqlite3-0 ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/kooshpotify /app/kooshpotify

# Set environment variable for the database URL (pointing to our volume)
ENV DATABASE_URL=sqlite:///app/data/kooshpotify.db

CMD ["./kooshpotify"]
