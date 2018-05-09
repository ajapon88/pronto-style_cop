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
  end
end
