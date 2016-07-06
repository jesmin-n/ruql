require 'spec_helper'

describe 'question with true answer' do
  before :each do ; @q = TrueFalse.new('true', true, :explanation => 'why') ; end
  it 'should have True as correct answer' do
    expect(@q.correct_answer.answer_text).to eq('True')
  end
  it 'should have explanation for False answer' do
    expect(@q.incorrect_answer.explanation).to eq('why')
  end
  it 'should not have explanation for correct answer' do
    expect(@q.correct_answer.explanation).to be_nil
  end
end
