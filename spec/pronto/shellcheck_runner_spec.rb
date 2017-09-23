require 'spec_helper'

module Pronto
  describe ShellCheckRunner do
    let(:shellcheck) { described_class.new(patches) }
    let(:patches) { [] }

    describe '#run_results' do
      subject(:run_results) { shellcheck.run }

      context 'when patches are nil' do
        let(:patches) { nil }

        it 'returns an empty array' do
          expect(run_results).to eq []
        end
      end

      context 'when there are no patches' do
        let(:patches) { [] }

        it 'returns an empty array' do
          expect(run_results).to eq []
        end
      end

      context 'when a patch has issues' do
        include_context 'test repo'

        let(:patches) { repo.diff('master') }
        let(:stderr) { StringIO.new }

        before { $stderr = stderr }
        after { $stderr = STDERR }

        it 'returns correct number of errors' do
          expect(run_results.count).to be 6
        end

        describe 'message counts' do
          it 'has 4 error messages' do
            errors = run_results.select { |message| message.level == :error }
            expect(errors.count).to be 2
          end

          it 'has 4 warning message' do
            warnings = run_results.select { |message| message.level == :warning }
            expect(warnings.count).to be 2
          end

          it 'has 4 info messages' do
            infos = run_results.select { |message| message.level == :info }
            expect(infos.count).to be 2
          end
        end

        describe 'messages per file' do
          let(:file_message_counts) do
            Hash[
              run_results
                .group_by(&:path)
                .map { |file, messages| [file, messages.count] }
            ]
          end

          it 'has 3 messages for script.sh' do
            expect(file_message_counts['script.sh']).to be 3
          end

          it 'has 3 messages for shebang-sh' do
            expect(file_message_counts['shebang-sh']).to be 3
          end
        end

        it 'has correct first message' do
          expect(run_results.first.msg)
            .to eq "[SC2084](https://github.com/koalaman/shellcheck/wiki/SC2084): Remove '$' or use '_=$((expr))' to avoid executing output."
        end

        context "when shellcheck encounters a shell it doesn't support" do
          it 'logs to stderr' do
            expect { shellcheck.run }.to output(/shebang-zsh/).to_stderr
          end
        end

        describe 'excluding results with SHELLCHECK_OPTS' do
          before do
            allow(ENV).to receive(:[]).and_call_original
            allow(ENV)
              .to receive(:[])
              .with('SHELLCHECK_OPTS')
              .and_return shellcheck_opts
          end

          context 'when SHELLCHECK_OPTS is not present in the environment' do
            let(:shellcheck_opts) { nil }

            it 'does not exclude any codes' do
              expect(run_results.map(&:msg).any? { |msg| msg =~ /SC2084/ })
                .to be true
            end
          end

          context 'when SHELLCHECK_OPTS is present in the environment' do
            let(:shellcheck_opts) { '-e SC2084' }

            it 'excludes the specified codes' do
              expect(run_results.map(&:msg).any? { |msg| msg =~ /SC2084/ })
                .to be false
            end
          end
        end
      end
    end

    describe '::shellcheckable' do
      let(:path) { Pathname.new("#{repo}/#{filename}") }
      let(:repo) { './spec/fixtures/test-repo' }

      context "when the path's extension ends in 'sh'" do
        let(:filename) { 'script.sh' }

        it 'returns true' do
          expect(described_class.shellcheckable?(path)).to be true
        end
      end

      context 'when the path has no extension' do
        context "and the shebang includes 'sh'" do
          let(:filename) { 'shebang-sh' }

          it 'returns true' do
            expect(described_class.shellcheckable?(path)).to be true
          end
        end
      end
    end
  end
end
