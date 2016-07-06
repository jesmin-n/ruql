require 'spec_helper'
require 'rspec/its'

describe Html5Renderer do
  describe 'when created' do
    subject { Html5Renderer.new(:fake_quiz) }
    its(:output) { is_expected.to eq('') }
  end
  describe 'with stylesheet link' do
    def rendering_with(opts)
      Html5Renderer.new(Quiz.new(''), opts).render_quiz.output
    end
    it 'should include CSS link with -c option' do
      expect(rendering_with('c' => 'foo.html')).
        to match /<link rel="stylesheet" type="text\/css" href="foo.html"/
    end
    it 'should include CSS link with --css option' do
      expect(rendering_with('css' => 'foo.html')).
        to match /<link rel="stylesheet" type="text\/css" href="foo.html"/
    end
    it 'should use ERB template if directed' do
      expect(rendering_with('template' => File.join(File.dirname(__FILE__),'fixtures','template.html.erb'))).
        to match /<body id="template">/
    end
  end
    
  describe 'rendering solutions' do
    before :each do
      @a = [
        Answer.new('aa',true,'This is right'),
        Answer.new('bb',false,'Nope'),
        Answer.new('cc',false)]
      @q = MultipleChoice.new('question', :answers => @a)
      @quiz = Quiz.new('foo', :questions => [@q])
      @output = Html5Renderer.new(@quiz,{'solutions' => true}).render_quiz.output
    end
    it 'should highlight correct answer' do
      expect(@output).to have_xml_element "//li[@class='correct']/p", :value => 'aa'
    end
    it 'should show explanations for incorrect answers' do
      expect(@output).to have_xml_element "//li[@class='incorrect']/p", :value => 'bb'
      expect(@output).to have_xml_element "//li[@class='incorrect']/p[@class='explanation']", :value => 'Nope'
    end
  end

  describe 'local variable' do
    require 'tempfile'
    def write_template(str)
      f = Tempfile.new('spec')
      f.write str
      f.close
      return f.path
    end
    before :each do
      @atts = {:title => 'My Quiz', :points => 20, :num_questions => 5} 
      @quiz = double('quiz', @atts.merge(:questions => []))
    end
    %w(title total_points num_questions).each do |var|
      it "should set '#{var}'" do
        value = @atts[var]
        expect(Html5Renderer.new(@quiz, 't' => write_template("#{var}: <%= #{value} %>")).render_quiz.output).
          to match /#{var}: #{value}/
      end
    end
  end

  describe 'rendering raw content' do
    before :each do
      @q = MultipleChoice.new '<tt>xx</tt>', :raw => true
      @q.answer '<b>cc</b>'
    end
    it 'should not escape HTML in the question' do
      expect(Html5Renderer.new(:fake).render_multiple_choice(@q,1).output).to match /<tt>xx<\/tt>/
    end
    it 'should not escape HTML in the answer' do
      expect(Html5Renderer.new(:fake).render_multiple_choice(@q,1).output).to match /<b>cc<\/b>/
    end
  end
  
  describe 'rendering multiple-choice question' do
    before :each do
      @a = [Answer.new('aa',true),Answer.new('bb',false), Answer.new('cc',false)]
      @q = MultipleChoice.new('question', :answers => @a)
      @h = Html5Renderer.new(:fake)
    end
    it 'should randomize option order if :randomize true' do
      @q.randomize = true
      runs = Array.new(10) { Html5Renderer.new(:fake).render_multiple_choice(@q,1).output }
      expect(runs.any? { |run| runs[0] != run }).to be_truthy
    end
    it 'should preserve option order if :randomize false' do
      @q.randomize = false
      runs = Array.new(10) { @h.render_multiple_choice(@q,1).output }
      expect(runs[0]).to match /.*aa.*bb.*cc/m
      expect(runs.all? { |run| runs[0] == run }).to be_truthy
    end
    it 'should not indicate solution' do
      expect(@h.render_multiple_choice(@q,1).output).not_to include '<li class="correct">'
    end
  end
end
