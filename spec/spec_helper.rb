require 'fileutils'
require 'rspec'
require 'pronto/shellcheck_runner'

RSpec.shared_context 'test repo' do
  let(:repo_path) { 'spec/fixtures/test-repo' }
  let(:git) { "#{repo_path}/git" }
  let(:dot_git) { "#{repo_path}/.git" }
  let(:repo) { Pronto::Git::Repository.new(repo_path) }

  before do
    FileUtils.mv(git, dot_git)
  end

  after do
    FileUtils.mv(dot_git, git)
  end
end
