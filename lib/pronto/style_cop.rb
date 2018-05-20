require 'pronto/style_cop/version'
require 'pronto/style_cop/config'
require 'pronto'
require 'tempfile'
require 'parallel'
require 'set'

module Pronto
  class StyleCop < Runner
    STYLECOP_COMMAND = 'StyleCopCLI'.freeze

    def initialize(patches, commit = nil)
      super
      @config.extend(StyleCopConfig)
    end

    def run
      return [] unless @patches

      @patches.select { |patch| valid_patch?(patch) }
        .map { |patch| inspect(patch) }
        .flatten.compact
    end

    def valid_patch?(patch)
      return false unless patch.additions > 0
      csharp_file?(patch.new_file_full_path)
    end

    def inspect(patch)
      Parallel.map(definitions, in_processes: parallel) { |definition| run_stylecop(patch, definition) }
        .each_with_object(Set.new) { |violations, result| result.merge(violations) }
        .map do |violation|
        patch.added_lines
          .select { |line| line.new_lineno == violation[:line_number] }
          .map { |line| new_message(violation, line) }
      end
    end

    def new_message(violation, line)
      path = line.patch.delta.new_file[:path]
      Message.new(path, line, :warning, "[#{violation[:rule_id]}] #{violation[:message]}", nil, self.class)
    end

    private

    def git_repo_path
      @git_repo_path ||= Rugged::Repository.discover(File.expand_path(Dir.pwd)).workdir
    end

    def csharp_file?(path)
      cs_file?(path)
    end

    def cs_file?(path)
      File.extname(path) == '.cs'
    end

    def settings
      @settings ||= begin
        puts "deprecation environment variable 'STYLECOP_SETTINGS'" if ENV.key?('STYLECOP_SETTINGS')

        settigns = ENV.fetch('PRONTO_STYLECOP_SETTINGS', nil)
        settigns = ENV.fetch('STYLECOP_SETTINGS', nil) if settigns.nil? # deprecation
        settigns = './Settings.StyleCop' if settigns.nil? && File.exist?('./Settings.StyleCop')
        settigns
      end
    end

    def definitions
      @definitions ||= @config.style_cop_definitions
    end

    def parallel
      @parallel ||= begin
        parallel = @config.style_cop_parallel
        parallel = nil if parallel < 0
        parallel
      end
    end

    def run_stylecop(patch, definition)
      Dir.chdir(git_repo_path) do
        Tempfile.create do |f|
          file_path = patch.new_file_full_path.to_s
          opt = stylecop_options(definition)
          ret = `'#{STYLECOP_COMMAND}' #{opt.join(' ')} -cs '#{file_path}' -out '#{f.path}'`
          raise ret unless stylecop_success?($?)
          parse_stylecop_violation(f.path)
        end
      end
    end

    def stylecop_options(definition)
      opt = []
      opt.push("-set '#{settings}'") unless settings.nil?
      opt.push("-flags '#{definition.join(',')}'") unless definition.nil? || definition.empty?
      opt
    end

    def stylecop_success?(status)
      status.success? || status.exitstatus == 2
    end

    def parse_stylecop_violation(violation_file)
      violations = Set.new
      File.open(violation_file) do |f|
        doc = REXML::Document.new(f)
        doc.elements.each('StyleCopViolations/Violation') do |violation|
          attributes = violation.attributes
          line_number = attributes['LineNumber'].to_i
          rule_id = attributes['RuleId']
          message = violation.text.strip
          violations.add(line_number: line_number, rule_id: rule_id, message: message)
        end
      end
      violations
    end
  end
end
