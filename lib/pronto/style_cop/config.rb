module Pronto
  module StyleCopConfig
    def style_cop
      @config_hash.fetch('style_cop', {})
    end

    def style_cop_definitions
      definitions = style_cop.fetch('definitions', [[]])
      definitions = [[]] if definitions.nil? || definitions.empty?
      definitions
        .collect { |definition| definition.instance_of?(Array) ? definition : [definition] }
    end

    def style_cop_parallel
      if ENV['PRONTO_STYLECOP_PARALLEL'].nil?
        style_cop.fetch('parallel', 1)
      else
        return nil if ENV['PRONTO_STYLECOP_PARALLEL'].empty?
        ENV['PRONTO_STYLECOP_PARALLEL'].to_i
      end
    end
  end
end
