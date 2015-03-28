module Fias
  module Name
    module Synonyms
      def synonymize_and_mark_optional(name)
        tokens = Split.split(name)
        tokens.map! { |token| tokenize(name, token) }
        tokens.map { |token| Array.wrap(token) }
      end

      private

      def tokenize(name, token)
        synonyms(token)          ||
          bracketed(name, token) ||
          names(token)           ||
          initials(token)        ||
          annivesary(token)      ||
          numerals(token)        ||
          token
      end

      def synonyms(token)
        Fias.config.synonyms.find { |set| set.include?(token) }
      end

      def bracketed(name, token)
        match = name.match(IN_BRACKETS)
        [token, OPTIONAL] if match && match[1].include?(token)
      end

      def names(token)
        name = Fias.config.names.find { |n| n == token }
        [name, OPTIONAL] if name
      end

      def initials(token)
        return unless
          (token =~ Fias::INITIALS) && (token =~ Fias::SINGLE_INITIAL)

        [token, OPTIONAL]
      end

      def annivesary(token)
        return unless token =~ Fias::ANNIVESARIES

        ANNIVESARY_FORMS.map do |form|
          token.gsub(Fias::ANNIVESARIES, form)
        end
      end

      def numerals(token)
        numerals_for(token) if token =~ /^\d+/ && !(token =~ Fias::ANNIVESARIES)
      end

      def numerals_for(numeral)
        n = numeral.gsub(/[^\d]/, '')
        suffixes =
          NUMERAL_SUFFIXES.map { |suffix| ["#{n}#{suffix}", "#{n}-#{suffix}"] }
        suffixes.flatten + [n]
      end

      IN_BRACKETS      = /\((.*)\)/
      OPTIONAL         = ''
      NUMERAL_SUFFIXES = %w(й я е ая ий ый ой ые ое го)
      ANNIVESARY_FORMS =
        ['\1-летия', '\1-лет', '\1 летия', '\1 лет', '\1-летие', '\1 летие']
    end
  end
end