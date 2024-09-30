# frozen_string_literal: true

require 'aws-record'

# post model
class Post
  include Aws::Record

  set_table_name 'my-bauble-app-posts'

  string_attr :id, hash_key: true
end
