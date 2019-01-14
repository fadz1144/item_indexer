FROM us.gcr.io/upc-dev/ruby-base-gcr:2.5.1

# Note: there's an ARG github_ssh_key which gets added when the upstream image is rebuilt,
#   It's required in order to bundle gems sourced from GitHub at build time.

MAINTAINER dpritchard@onekingslane.com

COPY Gemfile Gemfile.lock ./
RUN gem install bundler --force && bundle install --without test development oracledb --jobs 20 --retry 5

RUN mkdir -p /bbb/app/log && \
    mkdir -p /bbb/app/tmp && \
    chmod u+rwx log tmp

COPY --from=us.gcr.io/upc-dev/deployment-scripts:V1 /builder/bin ./bin
COPY . ./

## Move config files into place
COPY nginx/nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["bin/entrypoint.sh"]
CMD ["bin/start_service.sh"]
