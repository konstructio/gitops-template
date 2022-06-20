#!/usr/bin/env bash
export GITLAB_TOKEN=$1
gitlab-rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: [:write_registry, :write_repository, :api], name: 'Automation token'); token.set_token(ENV['GITLAB_TOKEN']); token.save!"
