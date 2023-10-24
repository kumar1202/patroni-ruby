# frozen_string_literal: true

require_relative "patroni/version"
require_relative "patroni/client/base"
require_relative "patroni/http_methods"

module Patroni
  class Error < StandardError; end
end
