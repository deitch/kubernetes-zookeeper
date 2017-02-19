FROM zookeeper

COPY docker-entrypoint-wrapper.sh /

ENTRYPOINT ["/docker-entrypoint-wrapper.sh"]
CMD ["zkServer.sh", "start-foreground"]
