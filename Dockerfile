FROM zookeeper:3.4.9

COPY docker-entrypoint-wrapper.sh /

ENTRYPOINT ["/docker-entrypoint-wrapper.sh"]
CMD ["zkServer.sh", "start-foreground"]
