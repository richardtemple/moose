module Moose
  module Core
    class Runner
      class << self
        def invoke
          trap_interrupt
          configuration_options_instance.parse_args
          ::Moose.require_files!
          configure_from_options
          ::Moose.run!(run_options)
        end

        private

        def run_options
          configuration_options_instance.moose_run_args
        end

        def configure_from_options
          configuration_options_instance.configure_from_options
        end

        def configuration_options_instance
          @configuration_options_instance ||= ConfigurationOptions.new(ARGV)
        end

        def trap_interrupt
          trap('INT') do
            exit!(1) if Moose.world.wants_to_quit
            Moose.world.wants_to_quit = true
            STDERR.puts "\nExiting... Interrupt again to exit immediately."
          end
        end
      end
    end
  end
end
