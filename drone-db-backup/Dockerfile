FROM alpine:3.7

# Arguments.
ARG TZ=UTC
## gdrive@2.1.0 from https://github.com/prasmussen/gdrive
ARG GDRIVE_DOWNLOAD_URL=https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download
ARG GDRIVE_BIN_PATH=/usr/local/bin/gdrive-linux-x64
ENV GDRIVE_BIN_PATH=${GDRIVE_BIN_PATH}

# Install packages.
RUN apk add --update curl mysql-client=10.1.32-r0 logrotate=3.13.0-r0 postfix=3.2.4-r1

# Download gdrive.
RUN curl -L -o ${GDRIVE_BIN_PATH} ${GDRIVE_DOWNLOAD_URL}
RUN chmod +x ${GDRIVE_BIN_PATH}
RUN ${GDRIVE_BIN_PATH} version

# Set timezone for crond.
RUN apk --update add tzdata && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
    apk del tzdata && \
    rm -rf /var/cache/apk/*

# Encrypt SMTP transaction.
RUN echo 'smtp_tls_security_level = may' >> /etc/postfix/main.cf

# Run postfix and crond
CMD ["sh", "-c", "postfix start; crond -L /dev/stdout -f;"]
