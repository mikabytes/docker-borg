FROM alpine

RUN apk add borgbackup bash openssh-client

# create .ssh folder, limited to root access
RUN mkdir -p /root/.ssh && chmod 0700 /root/.ssh

COPY entrypoint /entrypoint
RUN chmod ug+x /entrypoint

ENTRYPOINT [ "/entrypoint" ]
