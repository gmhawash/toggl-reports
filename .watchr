#!/usr/bin/env ruby
if __FILE__ == $0
  puts "Run with: watchr #{__FILE__}. \n\nRequired gems: watchr rev"
  exit 1
end

class Base
  class << self
    def run(cmd)
      sleep(2)
      puts("%s %s [%s]" % ["|\n" * 5 , cmd , Time.now.to_s])
      $last_test = cmd
      system(cmd)
    end

    def run_last_test
      run($last_test)
    end

  end
end

class Specs < Base
  class << self
    def run_all_specs
      tags = "--tag #{ARGV[1]}" if ARGV[1]
      run "bundle exec rake -s spec SPEC_OPTS='--order rand #{tags.to_s}'"
    end

    def run_single_spec *spec
      if ARGV[1].to_i > 0
        tags = ''
        spec = spec.first + ":#{ARGV[1]}"
      else
        tags = "--tag #{ARGV[1]}" if ARGV[1]
        spec = spec.join(' ')
      end
      run "bundle exec rspec  #{spec} --order rand #{tags}"
    end

    def rules(scope)
      scope.watch( '^spec/.*_spec\.rb'     ) { |m| run_single_spec(m[0] ) }
      [
        '^spec/spec_helper\.rb',
        '^lib/.*\.rb',
      ].each do |regex|
        scope.watch( regex ) { |m| run_last_test }
      end
    end
  end
end

class Cukes < Base
  class << self
    def run_cucumber_scenario scenario_path
      if scenario_path !~ /.*\.feature$/
        scenario_path = $last_scenario
      end
      $last_scenario = scenario_path
      run "bundle exec script/cucumber #{scenario_path} --tags @dev"
    end

    def rules(scope)
      scope.watch( '^features/.*\.feature' ) { |m| run_cucumber_scenario(m[0]) }
      scope.watch( '^features/step_definitions/.*' ) { |m| run_last_test }
    end
  end
end

Specs.rules(self)
Cukes.rules(self)

# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
#watch( '^test_harness/.*'                        ) { |m| run_last_test }
#watch( '^app/(.*)\.rb'                            ) { |m| run_single_spec("spec/%s_spec.rb" % m[1]) }
#watch( '^app/views/(.*)\.haml'                    ) { |m| run_single_spec("spec/views/%s.haml_spec.rb" % m[1]) }
#watch( '^lib/(.*)\.rb'                            ) { |m| run_single_spec("spec/other/%s_spec.rb" % m[1] ) }
#watch( '^features/*/.*'                           ) { |m| run_cucumber_scenario(m[0]) }
#watch( '^test-harness/*/.*'                       ) { |m| run_cucumber_scenario(m[0]) }
#watch( '^algorithm/*/.*'                       ) { |m| run_last_test}
#watch( '^circuit/*/.*'                       ) { |m| run_last_test}


# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all tests ---\n\n"
  run_all_specs
end

# Ctrl-T
Signal.trap('TSTP') do
  puts " --- Running last test --\n\n"
  run_cucumber_scenario nil
end

# Ctrl-C
Signal.trap('INT') { abort("\n") }

puts "Watching.." 
