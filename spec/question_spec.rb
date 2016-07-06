require 'spec_helper'

describe Question do
  describe 'tags' do
    it 'should be empty array by default' do
      expect(Question.new.question_tags).to be_empty
    end
    describe 'setting' do
      before(:each) { @q = Question.new }
      it 'single string tag' do
        @q.tags 'string'
        expect(@q.question_tags).to include 'string'
      end
      it 'single nonstring gets converted to string' do
        @q.tags 25
        expect(@q.question_tags).to include '25'
      end
      it 'array of strings or nonstrings' do
        @q.tags 'tag', 30
        expect(@q.question_tags).to include('tag')
        expect(@q.question_tags).to include('30')
      end
    end
  end
  describe 'uuid' do
    it 'should be negative 1 by default' do
      expect(Question.new.question_tags).to eq(-1)
    end
    describe 'setting' do
      before(:each) { @q = Question.new }
      it 'single nonstring gets converted to string' do
        @q.uuid 25
        expect(@q.uuid).to include '25'
      end
      it 'array of strings or nonstrings' do
        @q.uuid 'tag', 30
        expect(@q.uuid).to raise_error
      end
    end
  end
  describe 'comment' do
    it 'should be empty by default' do
      expect(Question.new.question_comment).to eq('')
    end
    it 'should be settable to a string' do
      @q = Question.new
      @q.comment 'comment'
      expect(@q.question_comment).to eq('comment')
    end
  end
  describe 'points' do
    it 'should be 1 by default' do
      expect(Question.new.points).to eq(1)
    end
    it 'should be overridable' do
      expect(Question.new(:points => 3).points).to eq(3)
    end
  end
  describe 'raw question' do
    subject { Question.new(:raw => true) }
    it { is_expected.to be_raw }
  end
  describe 'default explanation' do
    before(:each) do
      @q = Question.new
      @q.text 'question'
      @q.answer 'answer'
      @q.distractor 'distractor'
    end
    it 'if absent should mean no answers have explanation' do
      @q.answers.each do |ans|
        expect(ans.explanation).to be_nil
      end
    end
    it 'should apply when individual answers have no explanation' do
      @q.explanation 'expl'
      @q.answers.each do |ans|
        expect(ans.explanation).to eq('expl')
      end
    end
    it 'should not override per-answer explanation' do
      @q.answer 'new answer', :explanation => 'new explanation'
      @q.explanation 'expl'
      @q.answers.each do |ans|
        expect(ans.explanation).to eq(ans.answer_text =~ /new/ ? 'new explanation' : 'expl')
      end
    end
  end
end

    
