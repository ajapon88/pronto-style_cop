require 'pronto/style_cop/version'
require 'pronto/style_cop/config'
require 'pronto'
require 'style_cop'

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
      violations = run_stylecop(patch)

      violations.sort.map do |violation|
        patch.added_lines
          .select { |line| line.new_lineno == violation.line_number }
          .map { |line| new_message(violation, line) }
      end
    end

    def new_message(violation, line)
      path = line.patch.delta.new_file[:path]
      level = level(violation)

      Message.new(path, line, level, "[#{violation.rule_id}] #{violation.message}", nil, self.class)
    end

    def level(_violation)
      :warning
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
      ENV.fetch('STYLE_COP_SETTINGS', nil)
    end

    def definitions
      @config.style_cop_definitions
    end

    def run_stylecop(patch)
      path = patch.new_file_full_path.to_s
      definitions.each_with_object([]) do |definition, violations|
        violations.concat(::StyleCop.stylecop(file: path, settings: settings, flags: definition))
      end.uniq
    end
  end
end
