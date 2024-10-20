# frozen_string_literal: true

require 'bauble/cli/commands/preview'
require 'thor'

describe Bauble::Cli::Commands::Preview do
  let(:thor_class) do
    Class.new(Thor) do
      include Bauble::Cli::Commands::Preview

      attr_accessor :app

      def initialize(app)
        super([])
        @app = app
      end
    end
  end

  let(:app) do
    double(
      'App',
      stacks: [double(name: 'test-stack')],
      change_current_stack: nil,
      bundle: nil,
      template: 'template_content'
    )
  end

  let(:pulumi) do
    instance_double(Bauble::Cli::Pulumi, create_or_select_stack: nil, preview: nil, init!: nil, create_pulumi_yml: nil)
  end
  let(:options) { { stack: nil } }
  let(:thor_instance) { thor_class.new(app) }

  before do
    allow(thor_instance).to receive(:options).and_return(options)
    allow(thor_instance).to receive(:pulumi).and_return(pulumi)
    allow(Bauble::Cli::Logger).to receive(:logo)
    allow(Bauble::Cli::Logger).to receive(:block_log)
    allow(Bauble::Cli::Logger).to receive(:nl)
    allow(Bauble::Cli::Logger).to receive(:log)
    allow(Bauble::Cli::Logger).to receive(:error)
  end

  describe '#preview' do
    context 'when no stacks are found' do
      before { allow(app).to receive(:stacks).and_return([]) }

      it 'raises an error' do
        expect { thor_instance.preview }.to raise_error('No stacks found')
      end
    end

    context 'when multiple stacks are defined and no stack option is provided' do
      before do
        allow(app).to receive(:stacks).and_return([
                                                    double(name: 'stack1'),
                                                    double(name: 'stack2')
                                                  ])
      end

      it 'logs an error and exits with status 1' do
        expect(Bauble::Cli::Logger).to receive(:error).with('Must provide a stack when multiple are defined')
        expect { thor_instance.preview }.to raise_error(SystemExit) do |e|
          expect(e.status).to eq(1)
        end
      end
    end

    context 'when a stack is provided' do
      let(:options) { { stack: 'test-stack' } }

      it 'changes the current stack' do
        expect(app).to receive(:change_current_stack).with('test-stack')
        thor_instance.preview
      end

      it 'bundles assets' do
        expect(Bauble::Cli::Logger).to receive(:block_log).with('Bundling assets...')
        expect(app).to receive(:bundle)
        thor_instance.preview
      end

      it 'creates the Pulumi template' do
        expect(pulumi).to receive(:create_pulumi_yml).with('template_content')
        thor_instance.preview
      end

      it 'initializes Pulumi' do
        expect(pulumi).to receive(:init!)
        thor_instance.preview
      end

      it 'creates or selects the stack' do
        expect(pulumi).to receive(:create_or_select_stack).with('test-stack')
        thor_instance.preview
      end

      it 'runs the Pulumi preview' do
        expect(Bauble::Cli::Logger).to receive(:block_log).with('Running Pulumi preview...')
        expect(pulumi).to receive(:preview)
        thor_instance.preview
      end

      it 'logs the completion' do
        expect(Bauble::Cli::Logger).to receive(:log).with("Preview complete\n")
        thor_instance.preview
      end
    end
  end
end
