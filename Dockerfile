FROM swift:5.2.5
WORKDIR /app
ADD . ./

ARG API_KEY
ENV API_KEY=$API_KEY

RUN apt-get -y update
RUN apt-get -y install libssl-dev
RUN apt-get -y install libz-dev

RUN swift package clean

RUN swift build -c debug -Xlinker -E

EXPOSE 8080
ENTRYPOINT ["./.build/debug/tmdb"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0"]
