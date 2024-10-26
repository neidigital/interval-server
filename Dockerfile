FROM node:18 AS build

ADD package.json yarn.lock ./
# install without running the postinstall script
RUN yarn install


COPY . .

# run the scripts after the install
RUN yarn build
RUN yarn pkg

# @interval/server is not available in the folder `release`

FROM node:18-alpine
RUN apk update && apk add --no-cache postgresql-client
# RUN npm i --save-prod -g @interval/server

# copy the built files from the previous stage
COPY --from=build /release /release
# install the package globally from the built files
RUN npm i --save-prod -g /release

EXPOSE 3000

CMD [ "interval-server", "start"]
