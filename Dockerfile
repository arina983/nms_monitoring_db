
FROM postgres:15-alpine

ENV POSTGRES_DB=network_monitoring
ENV POSTGRES_USER=nms_user
ENV POSTGRES_PASSWORD=user_password

EXPOSE 5432
