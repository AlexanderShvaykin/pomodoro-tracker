require_relative 'lib/ruby/pomodoro/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-pomodoro"
  spec.version       = Ruby::Pomodoro::VERSION
  spec.authors       = ["Alexander Shvaykin"]
  spec.email         = ["skiline.alex@gmail.com"]

  spec.summary       = %q{CLI pomodoro-tracker}
  spec.homepage      = "https://github.com/AlexanderShvaykin"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/AlexanderShvaykin"
  spec.metadata["changelog_uri"] = "https://github.com/AlexanderShvaykin"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency 'terminal-notifier'
  spec.add_runtime_dependency 'tty-cursor'
  spec.add_runtime_dependency 'tty-editor'
end
