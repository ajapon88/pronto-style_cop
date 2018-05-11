require 'pronto/style_cop/version'
require 'pronto/style_cop/config'
require 'pronto'

module Pronto
  class StyleCop < Runner
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
      violations = []
      definitions.each do |definition|
        v = run_stylecop(patch, definition)
        violations.concat(v)
      end

      violations
        .uniq(&:to_s)
        .map do |violation|
        patch.added_lines
          .select { |line| line.new_lineno == violation[:line_number] }
          .map { |line| new_message(violation, line) }
      end
    end

    def new_message(violation, line)
      path = line.patch.delta.new_file[:path]
      Message.new(path, line, :warning, violation[:message], nil, self.class)
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
      settings = ENV.fetch('STYLECOP_SETTINGS', nil)
      settings = './Settings.StyleCop' if settings.nil? && File.exist?('./Settings.StyleCop')
      settings
    end

    def definitions
      @config.style_cop_definitions
    end

    def run_stylecop(patch, definition)
      Dir.chdir(git_repo_path) do
        Tempfile.create do |f|
          file_path = patch.new_file_full_path.to_s
          args = []
          args.push("-set '#{settings}'") unless settings.nil?
          args.push("-flags '#{definition.join(',')}'") unless definition.nil? || definition.empty?
          args.push("-cs '#{file_path}'")
          command = "StyleCopCLI #{args.join(' ')}"
          ret = `#{command} -out '#{f.path}'`
          status = $?
          raise ret unless status.success? || status.exitstatus == 2
          parse_stylecop_violation(f.path)
        end
      end
    end

    def parse_stylecop_violation(violation_file)
      File.open(violation_file) do |f|
        doc = REXML::Document.new(f)
        violations = []
        doc.elements.each('StyleCopViolations/Violation') do |violation|
          attributes = violation.attributes
          line_number = attributes['LineNumber'].to_i
          message = "[#{attributes['RuleId']}] #{violation.text.strip}"
          violations.push(line_number: line_number, message: message)
        end
        violations
      end
    end
  end
end
