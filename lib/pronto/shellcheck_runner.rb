require 'pronto'
require 'shellwords'

module Pronto
  class ShellCheckRunner < Runner
    extend Forwardable

    EXTENSION = /^\..*sh$/
    SHEBANG = %r{^#!/.*sh}
    SHELLCHECK_PRONTO_LEVELS = {
      'style' => :info,
      'info' => :info,
      'error' => :error,
      'warning' => :warning
    }.freeze

    def_delegator self, :shellcheckable?

    def run
      return [] if !@patches || @patches.count.zero?

      @patches
        .select { |patch| patch.additions > 0 && shellcheckable?(patch.new_file_full_path) }
        .reduce([]) { |results, patch| results.concat(inspect(patch)) }
    end

    class << self
      def shellcheckable?(path)
        path_has_extension?(path) || file_has_shebang?(path)
      end

      def path_has_extension?(path)
        !(EXTENSION =~ path.extname).nil?
      end

      def file_has_shebang?(path)
        shebang = File.readlines(path).first
        !(SHEBANG =~ shebang).nil?
      end
    end

    private :shellcheckable?
    private

      def repo_path
        @repo_path ||= @patches.first.repo.path
      end

      def inspect(patch)
        offences = run_shellcheck(patch).reject do |offence|
          if offence['code'] == 1071
            $stderr.puts "Skipped #{offence['file']}"
            $stderr.puts "Reason: #{offence['message']} (SC#{offence['code']})"
            true
          else
            false
          end
        end

        offences
          .reduce([]) do |messages, offence|
            messages.concat(
              patch
                .added_lines
                .select { |line| line.new_lineno == offence['line'] }
                .map { |line| new_message(offence, line) }
            )
          end
      end

      def new_message(offence, line)
        path = line.patch.delta.new_file[:path]
        level = SHELLCHECK_PRONTO_LEVELS[offence['level']]
        message = "[SC#{offence['code']}](https://github.com/koalaman/shellcheck/wiki/SC#{offence['code']}): #{offence['message']}"

        Message.new(path, line, level, message, nil, self.class)
      end

      def run_shellcheck(patch)
        Dir.chdir(repo_path) do
          escaped_file_path = Shellwords.escape(patch.new_file_full_path.to_s)
          JSON.parse(
            `shellcheck #{shellcheck_opts} -f json #{escaped_file_path}`
          )
        end
      end

      def shellcheck_opts
        ENV['SHELLCHECK_OPTS']
      end
  end
end
