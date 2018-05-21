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
      Parallel.map(definitions, in_processes: parallel) { |definition| stylecop(patch, definition) }
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
        settigns.nil? ? nil : File.expand_path(settigns, '.')
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

    def stylecop(patch, definition)
      @style_cop = {} if @style_cop.nil?
      @style_cop[definition] ||= run_stylecop(definition)
      source = relative_repo_path(patch.new_file_full_path.to_s)
      @style_cop[definition].fetch(source, Set.new)
    end

    def run_stylecop(definition)
      Tempfile.create do |f|
        opt = stylecop_options(definition)
        ret = `'#{STYLECOP_COMMAND}' #{opt.join(' ')} -r -cs '#{File.join(git_repo_path, '/*')}' -out '#{f.path}'`
        raise ret unless stylecop_success?($?)
        parse_stylecop_violation(f.path)
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
      violations = {}
      File.open(violation_file) do |f|
        doc = REXML::Document.new(f)
        doc.elements.each('StyleCopViolations/Violation') do |violation|
          attributes = violation.attributes
          source = relative_repo_path(attributes['Source'])
          line_number = attributes['LineNumber'].to_i
          rule_id = attributes['RuleId']
          message = violation.text.strip
          violations[source] = Set.new unless violations.include?(source)
          violations[source].add(line_number: line_number, rule_id: rule_id, message: message)
        end
      end
      violations
    end

    def relative_repo_path(path)
      Pathname.new(path).relative_path_from(Pathname.new(git_repo_path)).to_s
    end
  end
end
