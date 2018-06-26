FROM alpine:3.7

# Install mysql(mariadb).
RUN apk add --update mysql=10.1.32-r0 mysql-client=10.1.32-r0 && \
    rm -f /var/cache/apk/*

# Expose port to access the database.
EXPOSE 3306

# Run database.
ENTRYPOINT ["/opt/entrypoint.sh"]
