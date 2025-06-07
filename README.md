# Bauble

[![Gem Version](https://badge.fury.io/rb/bauble_core.svg)](https://badge.fury.io/rb/bauble_core)

Bauble lets you build and deploy Ruby-based Lambda function applications using pure Ruby code. It uses Pulumi for the actual deployments and automatically bundles your Ruby gems into Lambda Layers.

## Features

- 💎 **Ruby as IaC**: Use pure Ruby code to define your AWS infrastructure instead of YAML, JSON, or other DSLs
- 📦 **Dependency Management**: Automatic bundling of gems and shared code
- 🛠️ **Reliable Deployments**: Uses Pulumi as the underlying deployment mechanism while you focus on writing Ruby
- 🧩 **Modular Resources**: Create Lambda functions, API Gateways, EventBridge rules, SQS queues, and more
- 🔄 **Multiple Environments**: Support for multiple deployment stacks (dev, staging, production)

## Prerequisites

- Ruby 3.0.0 or higher
- [Pulumi CLI](https://www.pulumi.com/docs/get-started/install/) installed and configured
- AWS credentials configured (via AWS CLI, environment variables, or Pulumi configuration)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bauble_core'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install bauble_core
```

## Quick Start

### Creating a New Project

You can quickly scaffold a new Bauble project using the CLI:

```
$ bauble new my-lambda-project
```

This will create a basic project structure with example files to get you started.

### Project Structure

A typical Bauble project has the following structure:

```
my-lambda-project/
├── app/                # Your Lambda function code
│   └── hello_world.rb  # Example Lambda function
├── infra/              # Infrastructure definition
│   └── app.rb          # Main application definition
├── bauble.json         # Bauble configuration
└── Gemfile             # Ruby dependencies
```

### Define Your Infrastructure

In the `infra/app.rb` file, define your AWS resources:

```ruby
require 'bauble'

# Initialize your application
app = Bauble::Application.new(
  name: 'my-lambda-app',
  code_dir: 'app'  # Directory containing your Lambda code
)

# Create an IAM role for your Lambda
role = Bauble::Resources::LambdaRole.new(
  app,
  name: 'lambda-role'
)

# Define a Lambda function
Bauble::Resources::RubyFunction.new(
  app,
  role: role,
  name: 'hello-world',
  handler: 'app/hello_world.handler'  # Path to your handler function
)

# Add API Gateway (optional)
api = Bauble::Resources::ApiGatewayV2.new(
  app,
  name: 'api-gateway'
)

# Connect Lambda to API Gateway (optional)
api.add_route(
  method: 'GET',
  path: '/hello',
  function: lambda_function
)
```

### Write Your Lambda Function

In `app/hello_world.rb`:

```ruby
# frozen_string_literal: true

def handler(event:, context:)
  {
    statusCode: 200,
    body: JSON.generate({
      message: "Hello from Bauble Lambda!"
    })
  }
end
```

### Deploy Your Application

Deploy your application with:

```
$ bauble up
```

If you have multiple stacks defined, specify the stack:

```
$ bauble up --stack dev
```

### Preview Changes

To preview changes without deploying:

```
$ bauble preview
```

### Destroy Resources

To destroy all deployed resources:

```
$ bauble destroy
```

## Advanced Usage

### Multiple Stacks

Bauble supports multiple deployment environments through stacks:

```ruby
app = Bauble::Application.new(
  name: 'my-lambda-app',
  code_dir: 'app',
  stacks: ['dev', 'staging', 'prod']
)
```

### EventBridge Rules

Create EventBridge rules to trigger your Lambda functions on a schedule:

```ruby
Bauble::Resources::EventBridgeRule.new(
  app,
  name: 'scheduled-rule',
  schedule_expression: 'rate(1 hour)',
  target_function: your_lambda_function
)
```

### SQS Queues

Create SQS queues and connect them to Lambda functions:

```ruby
queue = Bauble::Resources::SqsQueue.new(
  app,
  name: 'process-queue'
)

# Connect queue to Lambda (Lambda will be triggered when messages are in queue)
Bauble::Resources::RubyFunction.new(
  app,
  role: role,
  name: 'process-message',
  handler: 'app/process_message.handler',
  event_source: queue
)
```

## Configuration

### bauble.json

The `bauble.json` file in your project root configures your application:

```json
{
  "entrypoint": "infra/app.rb"
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/la-jamesh/bauble.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
