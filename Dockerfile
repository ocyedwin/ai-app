# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t ai_app .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name ai_app ai_app

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 ffmpeg && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile




# Final stage for app image
FROM nvidia/cuda:12.6.2-cudnn-devel-ubuntu24.04 AS final

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 ffmpeg \
    # additional packages in base but not final
    libyaml-dev tzdata \
    # my packages 
    nfs-common iputils-ping sudo wget && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    echo "export PATH=/opt/conda/bin:$PATH" > /etc/profile.d/conda.sh
ENV PATH=/opt/conda/bin:$PATH

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Copy Ruby installation from base image
COPY --from=base /usr/local/bin/ruby /usr/local/bin/
COPY --from=base /usr/local/lib/ruby /usr/local/lib/ruby
COPY --from=base /usr/local/include/ruby-3.3.0 /usr/local/include/ruby-3.3.0
COPY --from=base /usr/local/lib/libruby* /usr/local/lib/
COPY --from=base /usr/local/bin/bundle /usr/local/bin/
COPY --from=base /usr/local/bin/bundler /usr/local/bin/

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1001 rails && \
    useradd rails --uid 1001 --gid 1001 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1001:1001

RUN conda init bash && \
    echo 'export PATH=/opt/conda/bin:$PATH' >> ~/.bashrc && \
    . ~/.bashrc && \
    conda create -n app_env python=3.10 -y && \
    echo "conda activate app_env" >> ~/.bashrc

# Use SHELL command to ensure conda is initialized for each RUN command
SHELL ["conda", "run", "-n", "app_env", "/bin/bash", "-c"]

COPY sigclip/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
