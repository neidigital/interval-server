FROM node:18 AS build
WORKDIR /app
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
COPY --from=build /app/release /release
WORKDIR /release
# install the package globally from the built files
RUN yarn install --production

EXPOSE 3000
ENTRYPOINT ["node", "/release/dist/src/entry.js" ]
CMD [ "start" ]
