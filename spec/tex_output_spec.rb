require 'spec_helper'

describe TexOutput do
  include TexOutput
  describe 'converting special characters' do
    {'a_b' => 'a\textunderscore{}b',
      'a##' => 'a\#\#',
      '#{$var}' => '\#\{\$var\}'}.each_pair do |orig, escaped|
      it "should escape '#{orig}'" do
        expect(to_tex(orig)).to eq(escaped)
      end
    end
    it 'should replace <tt> with \verb{}' do
      expect(to_tex('A bit of <tt>code_here</tt>')).to eq(
        'A bit of \texttt{code\textunderscore{}here}'
      )
    end
    it 'should replace multiline <pre> with Verbatim environment' do
      expect(to_tex('Code here:
<pre>
  I haz
    teh codez
</pre>
And more:
<pre>
  More codez
</pre>
End of code.')).to  eq('Code here:
\begin{Verbatim}
  I haz
    teh codez
\end{Verbatim}
And more:
\begin{Verbatim}
  More codez
\end{Verbatim}
End of code.')
    end
  end
end
