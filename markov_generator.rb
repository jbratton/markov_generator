class MarkovGenerator
  attr_accessor :input_text, :prefix_size, :ignore_case

  END_PUNCTUATION = %w[. ? !]
  OTHER_PUNCTUATION = %w[, ; : -]
  PUNCTUATION = [END_PUNCTUATION, OTHER_PUNCTUATION].flatten

  def initialize(input_text, prefix_size = 2, ignore_case = true)
    @input_text = input_text
    @prefix_size = prefix_size
    @ignore_case = ignore_case

    @prefix_map = Hash.new {|h, k| h[k] = []}

    build_map
  end

  def build_map
    words = input_text.split
    words = words.map(&:downcase) if ignore_case

    words.each_cons(prefix_size + 1) do |words|
      prefix_map[words[0..-2].join(' ')] << words[-1]
    end
  end

  def build_sentence(max_length = 10)
    sentence = prefix_map.keys.sample.split

    while sentence.length < max_length
      next_key = sentence[-2, 2].join(' ')
      next_word = prefix_map[next_key].sample

      break if next_word.nil?
      sentence << next_word
    end

    sentence = sentence.join(' ').capitalize

    # capitalize letters that follow sentence ending punctuation
    sentence.gsub!(/([#{END_PUNCTUATION.join}]) ([a-z])/) {|| "#{$1} #{$2.upcase}" }

    # get rid of non-final punctuation at the end
    sentence.gsub!(/[#{OTHER_PUNCTUATION.join}]$/, '')

    # add some end punctuation if it isn't there already
    sentence << END_PUNCTUATION.sample unless END_PUNCTUATION.include? sentence[-1]

    sentence
  end

  private
  attr_accessor :prefix_map
end
