FROM us.gcr.io/upc-dev/ruby-base-gcr:2.5.1

# Note: there's an ARG github_ssh_key which gets added when the upstream image is rebuilt,
#   It's required in order to bundle gems sourced from GitHub at build time.

MAINTAINER dpritchard@onekingslane.com

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --without test development oracledb --jobs 20 --retry 5

COPY . ./

## Move config files into place
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# compile assets
# we don't have any
# RUN ./bin/compile.sh

ENTRYPOINT ["bin/secrets-entrypoint.sh"]
CMD ["bin/server.sh"]
